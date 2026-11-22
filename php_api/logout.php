<?php
require 'config.php';
requireMethod('POST');
requireUser();
$stmt = db()->prepare('DELETE FROM sessions WHERE token_hash = ?');
$stmt->execute([hash('sha256', bearerToken())]);
respond(200, ['success' => true, 'message' => 'Logged out']);