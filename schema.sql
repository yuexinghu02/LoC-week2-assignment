-- Schema for library.db: a small lending library.
-- Run with: sqlite3 library.db ".read schema.sql"
-- SQLite only enforces foreign keys when each connection runs PRAGMA foreign_keys = ON.

PRAGMA foreign_keys = ON;

-- The catalog: one row per title (a "work"), not per physical copy.
CREATE TABLE books (
    book_id           INTEGER PRIMARY KEY,
    goodreads_book_id INTEGER UNIQUE,
    isbn              TEXT,
    title             TEXT NOT NULL,
    original_title    TEXT,
    publication_year  INTEGER,
    language_code     TEXT,
    average_rating    REAL CHECK (average_rating BETWEEN 0 AND 5),
    ratings_count     INTEGER CHECK (ratings_count >= 0),
    image_url         TEXT
);

CREATE TABLE authors (
    author_id INTEGER PRIMARY KEY,
    name      TEXT NOT NULL UNIQUE
);

-- A book can have several authors, and an author several books.
CREATE TABLE book_authors (
    book_id      INTEGER NOT NULL REFERENCES books (book_id) ON DELETE CASCADE,
    author_id    INTEGER NOT NULL REFERENCES authors (author_id),
    author_order INTEGER NOT NULL DEFAULT 1,
    PRIMARY KEY (book_id, author_id)
);

CREATE TABLE members (
    member_id  INTEGER PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name  TEXT NOT NULL,
    email      TEXT UNIQUE,
    phone      TEXT,
    joined_on  TEXT NOT NULL DEFAULT (date('now'))
);

-- The physical books on the shelves; a title can have many copies.
CREATE TABLE copies (
    copy_id     INTEGER PRIMARY KEY,
    book_id     INTEGER NOT NULL REFERENCES books (book_id),
    acquired_on TEXT NOT NULL DEFAULT (date('now')),
    condition   TEXT NOT NULL DEFAULT 'good'
                CHECK (condition IN ('new', 'good', 'worn', 'damaged')),
    status      TEXT NOT NULL DEFAULT 'available'
                CHECK (status IN ('available', 'on_loan', 'lost', 'retired'))
);

CREATE TABLE loans (
    loan_id     INTEGER PRIMARY KEY,
    copy_id     INTEGER NOT NULL REFERENCES copies (copy_id),
    member_id   INTEGER NOT NULL REFERENCES members (member_id),
    loaned_on   TEXT NOT NULL DEFAULT (date('now')),
    due_on      TEXT NOT NULL DEFAULT (date('now', '+21 days')),
    returned_on TEXT,
    CHECK (due_on >= loaned_on),
    CHECK (returned_on IS NULL OR returned_on >= loaned_on)
);

CREATE INDEX idx_book_authors_author ON book_authors (author_id);
CREATE INDEX idx_copies_book ON copies (book_id);
CREATE INDEX idx_loans_member ON loans (member_id);
CREATE INDEX idx_books_title ON books (title);
-- A copy can only be out on one open loan at a time.
CREATE UNIQUE INDEX idx_loans_one_open_per_copy ON loans (copy_id) WHERE returned_on IS NULL;
