# library.db Summary

## Entity-Relationship Diagram

```mermaid
erDiagram
    books ||--o{ book_authors : "written by"
    authors ||--o{ book_authors : "writes"
    books ||--o{ copies : "shelved as"
    copies ||--o{ loans : "lent in"
    members ||--o{ loans : "borrows"

    books {
        INTEGER book_id PK
        INTEGER goodreads_book_id UK
        TEXT isbn
        TEXT title "NOT NULL"
        TEXT original_title
        INTEGER publication_year
        TEXT language_code
        REAL average_rating "0 to 5"
        INTEGER ratings_count ">= 0"
        TEXT image_url
    }
    authors {
        INTEGER author_id PK
        TEXT name UK "NOT NULL"
    }
    book_authors {
        INTEGER book_id PK, FK "ON DELETE CASCADE"
        INTEGER author_id PK, FK
        INTEGER author_order "default 1"
    }
    members {
        INTEGER member_id PK
        TEXT first_name "NOT NULL"
        TEXT last_name "NOT NULL"
        TEXT email UK
        TEXT phone
        TEXT joined_on "default today"
    }
    copies {
        INTEGER copy_id PK
        INTEGER book_id FK "NOT NULL"
        TEXT acquired_on "default today"
        TEXT condition "new, good, worn, damaged"
        TEXT status "available, on_loan, lost, retired"
    }
    loans {
        INTEGER loan_id PK
        INTEGER copy_id FK "one open loan per copy"
        INTEGER member_id FK "NOT NULL"
        TEXT loaned_on "default today"
        TEXT due_on "default today + 21 days"
        TEXT returned_on "NULL while out"
    }
```

PNG version ([erd.png](erd.png)):

![ERD of library.db](erd.png)

## Tables

| Table | Purpose | Rows |
|---|---|---|
| `books` | Catalog of titles, loaded from goodbooks-10k `books.csv` | 10,000 |
| `authors` | One row per author | 5,841 |
| `book_authors` | Links books to their authors (many-to-many) | 13,209 |
| `members` | Library patrons (made-up sample data) | 6 |
| `copies` | Physical copies on the shelves | 10 |
| `loans` | Borrowing history and open loans | 13 |

## Relationships

- A **book** has one or more **authors**, and an author can write many books, linked through `book_authors`.
- A **book** can have many physical **copies**; each copy belongs to exactly one book.
- A **member** can have many **loans**, and a **copy** can be lent many times, but only one open loan per copy at a time (`idx_loans_one_open_per_copy`).

## Files

- `schema.sql` creates the tables and indexes.
- `load_books.sql` imports `books.csv` into `books`, `authors` and `book_authors`.
- `seed_data.sql` adds the sample members, copies and loans.
- `erd.mmd` is the Mermaid source for the diagram above.
