-- Loads books.csv (goodbooks-10k) into the catalog tables of library.db.
-- Run after schema.sql: sqlite3 library.db ".read load_books.sql"

PRAGMA foreign_keys = ON;

-- The table doesn't exist yet, so .import creates it from the CSV header (all TEXT columns).
.import --csv --schema temp books.csv staging_books

BEGIN;

INSERT INTO books (book_id, goodreads_book_id, isbn, title, original_title,
                   publication_year, language_code, average_rating, ratings_count, image_url)
SELECT CAST(book_id AS INTEGER),
       CAST(goodreads_book_id AS INTEGER),
       -- The CSV stored ISBNs as numbers, dropping leading zeros; pad back to 10 characters.
       CASE WHEN isbn = '' THEN NULL ELSE substr('0000000000' || isbn, -10) END,
       title,
       NULLIF(original_title, ''),
       -- Years look like "2008.0".
       CASE WHEN original_publication_year = '' THEN NULL
            ELSE CAST(CAST(original_publication_year AS REAL) AS INTEGER) END,
       NULLIF(language_code, ''),
       CAST(average_rating AS REAL),
       CAST(ratings_count AS INTEGER),
       image_url
FROM temp.staging_books;

-- The authors column is a comma-separated list, e.g. "J.K. Rowling, Mary GrandPré".
CREATE TEMP TABLE split_authors AS
WITH RECURSIVE split (book_id, rest, name, author_order) AS (
    SELECT CAST(book_id AS INTEGER), authors || ', ', NULL, 0
    FROM temp.staging_books
    UNION ALL
    SELECT book_id,
           substr(rest, instr(rest, ', ') + 2),
           trim(substr(rest, 1, instr(rest, ', ') - 1)),
           author_order + 1
    FROM split
    WHERE rest <> ''
)
SELECT book_id, name, author_order FROM split WHERE name <> '';

INSERT OR IGNORE INTO authors (name)
SELECT DISTINCT name FROM split_authors ORDER BY name;

INSERT OR IGNORE INTO book_authors (book_id, author_id, author_order)
SELECT s.book_id, a.author_id, s.author_order
FROM split_authors s
JOIN authors a ON a.name = s.name
ORDER BY s.book_id, s.author_order;

COMMIT;

DROP TABLE temp.split_authors;
DROP TABLE temp.staging_books;
