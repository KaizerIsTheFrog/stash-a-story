<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

$dataDir = __DIR__ . '/data';
if (!is_dir($dataDir)) { @mkdir($dataDir, 0755, true); }

// test only
$sqliteOk = false;
$sqliteError = null;
try {
    $pdo = new PDO('sqlite:' . $dataDir . '/test.db');
    $pdo->exec('CREATE TABLE IF NOT EXISTS ping (id INTEGER PRIMARY KEY, t TEXT)');
    $pdo->exec("INSERT INTO ping (t) VALUES ('" . date('c') . "')");
    $sqliteOk = true;
} catch (Throwable $e) {
    $sqliteError = $e->getMessage();
}

$headers = function_exists('getallheaders') ? getallheaders() : [];

echo json_encode([
    'success'        => true,
    'message'        => 'Stash A Story API is reachable',
    'server_time'    => date('c'),
    'php_version'    => PHP_VERSION,
    'pdo_sqlite'     => extension_loaded('pdo_sqlite'),
    'sqlite_write'   => $sqliteOk,
    'sqlite_error'   => $sqliteError,
    'method'         => $_SERVER['REQUEST_METHOD'],
    'auth_header_received' => isset($headers['Authorization']) || isset($headers['X-Auth-Token']),
], JSON_PRETTY_PRINT);