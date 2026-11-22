<?php
require 'config.php';
requireMethod('POST');

$in = input();
$name    = trim($in['name'] ?? '');
$email   = strtolower(trim($in['email'] ?? ''));
$pass    = $in['password'] ?? '';
$confirm = $in['confirm_password'] ?? '';

if ($name === '' || $email === '' || $pass === '' || $confirm === '')
    respond(422, ['success' => false, 'message' => 'All fields are required']);
if (!filter_var($email, FILTER_VALIDATE_EMAIL))
    respond(422, ['success' => false, 'message' => 'Invalid email format']);
if (strlen($pass) < 6)
    respond(422, ['success' => false, 'message' => 'Password must be at least 6 characters']);
if ($pass !== $confirm)
    respond(422, ['success' => false, 'message' => 'Passwords do not match']);

$pdo = db();
$check = $pdo->prepare('SELECT id FROM users WHERE email = ?');
$check->execute([$email]);
if ($check->fetch())
    respond(409, ['success' => false, 'message' => 'Email already registered']);

// Role is assigned by the server
$stmt = $pdo->prepare('INSERT INTO users (name, email, password_hash, role, created_at) VALUES (?, ?, ?, "borrower", ?)');
$stmt->execute([$name, $email, password_hash($pass, PASSWORD_DEFAULT), date('c')]);

respond(201, ['success' => true, 'message' => 'Account created successfully']);