-- Library Management System Database
-- Created by [Your Name] on [Date]

-- Enable strict SQL mode
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

-- Create database
DROP DATABASE IF EXISTS library_db;
CREATE DATABASE library_db;
USE library_db;

-- Members table (Patrons of the library)
CREATE TABLE members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    join_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    membership_status ENUM('active', 'expired', 'suspended') DEFAULT 'active',
    address TEXT,
    CONSTRAINT chk_email CHECK (email LIKE '%@%.%')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Authors table
CREATE TABLE authors (
    author_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    birth_year SMALLINT,
    nationality VARCHAR(50),
    biography TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Publishers table
CREATE TABLE publishers (
    publisher_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address TEXT,
    contact_email VARCHAR(100),
    website VARCHAR(255)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Books table
CREATE TABLE books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    isbn VARCHAR(17) UNIQUE NOT NULL,
    title VARCHAR(255) NOT NULL,
    publisher_id INT NOT NULL,
    publication_year SMALLINT,
    edition SMALLINT DEFAULT 1,
    category VARCHAR(50),
    language VARCHAR(30) DEFAULT 'English',
    page_count INT,
    description TEXT,
    FOREIGN KEY (publisher_id) REFERENCES publishers(publisher_id) ON UPDATE CASCADE,
    CONSTRAINT chk_isbn CHECK (LENGTH(isbn) = 13 OR LENGTH(isbn) = 17)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Book-Author relationship (Many-to-Many)
CREATE TABLE book_authors (
    book_id INT NOT NULL,
    author_id INT NOT NULL,
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES authors(author_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Book copies inventory
CREATE TABLE book_copies (
    copy_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    acquisition_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    status ENUM('available', 'checked_out', 'lost', 'damaged') DEFAULT 'available',
    shelf_location VARCHAR(20) NOT NULL,
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Loans table
CREATE TABLE loans (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    copy_id INT NOT NULL,
    member_id INT NOT NULL,
    checkout_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    due_date DATE NOT NULL,
    return_date DATETIME,
    late_fee DECIMAL(10,2) DEFAULT 0.00,
    FOREIGN KEY (copy_id) REFERENCES book_copies(copy_id) ON UPDATE CASCADE,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON UPDATE CASCADE,
    CONSTRAINT chk_due_date CHECK (due_date > checkout_date),
    CONSTRAINT chk_return_date CHECK (return_date IS NULL OR return_date >= checkout_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Fines table
CREATE TABLE fines (
    fine_id INT AUTO_INCREMENT PRIMARY KEY,
    loan_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    issue_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    payment_date DATE,
    status ENUM('unpaid', 'paid', 'waived') DEFAULT 'unpaid',
    FOREIGN KEY (loan_id) REFERENCES loans(loan_id) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create indexes for performance
CREATE INDEX idx_books_title ON books(title);
CREATE INDEX idx_members_email ON members(email);
CREATE INDEX idx_loans_member ON loans(member_id);
CREATE INDEX idx_loans_dates ON loans(checkout_date, due_date);

COMMIT;
