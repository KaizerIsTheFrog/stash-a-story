<?php
require 'config.php';
requireMethod('POST');

$in = input();
$email = strtolower(trim($in['email'] ?? ''));
$pass  = $in['password'] ?? '';

if ($email === '' || $pass === '')
    respond(422, ['success' => false, 'message' => 'Email and password are required']);

$stmt = db()->prepare('SELECT * FROM users WHERE email = ?');
$stmt->execute([$email]);
$user = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$user || !password_verify($pass, $user['password_hash']))
    respond(401, ['success' => false, 'message' => 'Invalid email or password']);

$token = bin2hex(random_bytes(32));
$now = time();
$ins = db()->prepare('INSERT INTO sessions (user_id, token_hash, created_at, expires_at) VALUES (?, ?, ?, ?)');
$ins->execute([$user['id'], hash('sha256', $token), $now, $now + 7 * 24 * 3600]);

respond(200, [
    'success' => true,
    'message' => 'Login successful',
    'token'   => $token,
    'user'    => ['name' => $user['name'], 'email' => $user['email'], 'role' => $user['role']],
]);