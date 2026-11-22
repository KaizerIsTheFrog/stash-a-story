<?php
// for initial setup of the database and librarian account, run only once
require 'config.php';

$pw = 'CHANGE_ME_BEFORE_RUNNING';   // placeholder only


$pdo = db();

// Safe to run even if the tables already exist
$pdo->exec('CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT "borrower",
    created_at TEXT NOT NULL
)');

$pdo->exec('CREATE TABLE IF NOT EXISTS sessions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    token_hash TEXT NOT NULL UNIQUE,
    created_at INTEGER NOT NULL,
    expires_at INTEGER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
)');

// Create the librarian acc
$email = 'librarian@stashastory.test';
$hash  = password_hash($pw, PASSWORD_DEFAULT);

$check = $pdo->prepare('SELECT id FROM users WHERE email = ?');
$check->execute([$email]);

if ($check->fetch()) {
    $ins = $pdo->prepare('INSERT INTO users (name, email, password_hash, role, created_at) VALUES (?, ?, ?, "librarian", ?)');
    $ins->execute(['Head Librarian', $email, $hash, date('c')]);
    $msg = 'Librarian account created.';
}

echo json_encode(['success' => true, 'message' => $msg]);