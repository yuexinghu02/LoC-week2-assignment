-- Made-up members, shelf copies and loans for library.db.
-- Run after schema.sql and load_books.sql: sqlite3 library.db ".read seed_data.sql"
-- Dates are fixed, so "overdue" depends on when you query: as of 2026-10-22,
-- loan 11 is overdue and loans 12 and 13 are still out but not yet due.

PRAGMA foreign_keys = ON;

BEGIN;

-- Sam Rivera (member 6) has never borrowed anything.
INSERT INTO members (member_id, first_name, last_name, email, phone, joined_on) VALUES
    (1, 'Maria', 'Lopez',     'maria.lopez@example.com',     '555-0101', '2026-07-20'),
    (2, 'James', 'Okafor',    'james.okafor@example.com',    '555-0102', '2026-07-22'),
    (3, 'Priya', 'Natarajan', 'priya.natarajan@example.com', '555-0103', '2026-08-01'),
    (4, 'Tom',   'Becker',    'tom.becker@example.com',      '555-0104', '2026-08-15'),
    (5, 'Aiko',  'Tanaka',    'aiko.tanaka@example.com',     '555-0105', '2026-08-30'),
    (6, 'Sam',   'Rivera',    'sam.rivera@example.com',      '555-0106', '2026-10-01');

-- One physical copy each of ten catalog titles.
INSERT INTO copies (copy_id, book_id, acquired_on, condition, status) VALUES
    (1,  1,  '2026-07-15', 'good', 'available'),  -- The Hunger Games
    (2,  2,  '2026-07-15', 'worn', 'available'),  -- Harry Potter and the Sorcerer's Stone
    (3,  4,  '2026-07-15', 'good', 'on_loan'),    -- To Kill a Mockingbird
    (4,  5,  '2026-07-15', 'good', 'available'),  -- The Great Gatsby
    (5,  7,  '2026-07-15', 'new',  'available'),  -- The Hobbit
    (6,  10, '2026-07-15', 'good', 'available'),  -- Pride and Prejudice
    (7,  11, '2026-07-15', 'good', 'available'),  -- The Kite Runner
    (8,  14, '2026-07-15', 'new',  'available'),  -- Animal Farm
    (9,  19, '2026-07-15', 'good', 'on_loan'),    -- The Fellowship of the Ring
    (10, 22, '2026-07-15', 'new',  'on_loan');    -- The Lovely Bones

INSERT INTO loans (loan_id, copy_id, member_id, loaned_on, due_on, returned_on) VALUES
    (1,  1,  1, '2026-08-03', '2026-08-24', '2026-08-20'),
    (2,  2,  2, '2026-08-05', '2026-08-26', '2026-08-25'),
    (3,  3,  3, '2026-08-12', '2026-09-02', '2026-09-05'),  -- returned 3 days late
    (4,  4,  1, '2026-08-25', '2026-09-15', '2026-09-10'),
    (5,  1,  4, '2026-09-01', '2026-09-22', '2026-09-18'),
    (6,  5,  5, '2026-09-03', '2026-09-24', '2026-09-20'),
    (7,  6,  2, '2026-09-10', '2026-10-01', '2026-09-28'),
    (8,  7,  3, '2026-09-15', '2026-10-06', '2026-10-02'),
    (9,  8,  4, '2026-09-20', '2026-10-11', '2026-10-09'),
    (10, 2,  5, '2026-09-29', '2026-10-20', '2026-10-14'),
    (11, 9,  4, '2026-09-22', '2026-10-13', NULL),          -- overdue
    (12, 3,  2, '2026-10-10', '2026-10-31', NULL),          -- still out
    (13, 10, 1, '2026-10-15', '2026-11-05', NULL);          -- still out

COMMIT;
