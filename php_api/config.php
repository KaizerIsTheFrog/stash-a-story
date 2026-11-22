<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Auth-Token');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { http_response_code(204); exit; }

// Database connection (path comes from StudentWebHost's SQLite Manager)
function db(): PDO {
    static $pdo = null;
    if ($pdo === null) {
        $dbPath = '/opt/studentwebhost/data/hosting-sandbox/private/kaiserthefrog/databases/sttpk2143.sqlite';

        if (!is_file($dbPath)) {
            respond(500, ['success' => false, 'message' => 'Database missing: check the path in SQLite Manager']);
        }

        $pdo = new PDO('sqlite:' . $dbPath);
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        $pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
        $pdo->exec('PRAGMA busy_timeout = 5000');
        $pdo->exec('PRAGMA foreign_keys = ON');
    }
    return $pdo;
}

function respond(int $code, array $body): void {
    http_response_code($code);
    echo json_encode($body);
    exit;
}

function input(): array {
    $data = json_decode(file_get_contents('php://input'), true);
    return is_array($data) ? $data : [];
}

function requireMethod(string $method): void {
    if ($_SERVER['REQUEST_METHOD'] !== $method) {
        respond(405, ['success' => false, 'message' => 'Method not allowed']);
    }
}

function bearerToken(): ?string {
    $h = $_SERVER['HTTP_AUTHORIZATION']
        ?? $_SERVER['REDIRECT_HTTP_AUTHORIZATION']
        ?? $_SERVER['HTTP_X_AUTH_TOKEN']
        ?? '';
    if (stripos($h, 'Bearer ') === 0) $h = substr($h, 7);
    $h = trim($h);
    return $h !== '' ? $h : null;
}

function requireUser(): array {
    $token = bearerToken();
    if (!$token) respond(401, ['success' => false, 'message' => 'Not authenticated']);

    $stmt = db()->prepare(
        'SELECT u.id, u.name, u.email, u.role, u.created_at
         FROM sessions s JOIN users u ON u.id = s.user_id
         WHERE s.token_hash = ? AND s.expires_at > ?'
    );
    $stmt->execute([hash('sha256', $token), time()]);
    $user = $stmt->fetch();
    if (!$user) respond(401, ['success' => false, 'message' => 'Session invalid or expired']);
    return $user;
}