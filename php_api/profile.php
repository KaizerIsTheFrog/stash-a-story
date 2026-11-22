<?php
require 'config.php';
requireMethod('GET');
$user = requireUser();
respond(200, ['success' => true, 'user' => [
    'name' => $user['name'], 'email' => $user['email'],
    'role' => $user['role'], 'created_at' => $user['created_at'],
]]);