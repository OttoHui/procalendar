<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Accept');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['ok' => false, 'error' => 'Only POST requests are allowed.']);
    exit;
}

$raw = file_get_contents('php://input');
$data = json_decode($raw, true);
if (!is_array($data)) {
    http_response_code(400);
    echo json_encode(['ok' => false, 'error' => 'Request body must be valid JSON.']);
    exit;
}

$host = getenv('DB_HOST') ?: '127.0.0.1';
$db   = getenv('DB_NAME') ?: 'quad_sync';
$user = getenv('DB_USER') ?: 'root';
$pass = getenv('DB_PASS') ?: '';

$mysqli = new mysqli($host, $user, $pass, $db);
if ($mysqli->connect_errno) {
    http_response_code(500);
    echo json_encode(['ok' => false, 'error' => 'Database connection failed: ' . $mysqli->connect_error]);
    exit;
}

$token = isset($data['token']) ? trim((string)$data['token']) : '';
$deviceId = isset($data['deviceId']) ? trim((string)$data['deviceId']) : 'unknown-device';

if ($token === '') {
    $mysqli->close();
    http_response_code(400);
    echo json_encode(['ok' => false, 'error' => 'Missing sync token.']);
    exit;
}

$action = isset($data['action']) ? strtolower((string)$data['action']) : 'push';

if ($action === 'pull') {
    $stmt = $mysqli->prepare('SELECT snapshot, updated_at, device_id FROM quad_sync WHERE token = ? LIMIT 1');
    $stmt->bind_param('s', $token);
    $stmt->execute();
    $result = $stmt->get_result();
    $row = $result->fetch_assoc();
    $stmt->close();
    $mysqli->close();

    if (!$row) {
        echo json_encode(['ok' => true, 'snapshot' => ['events' => [], 'labels' => [], 'settings' => []], 'updatedAt' => null, 'deviceId' => null]);
        exit;
    }

    echo json_encode([
        'ok' => true,
        'snapshot' => json_decode($row['snapshot'], true) ?: ['events' => [], 'labels' => [], 'settings' => []],
        'updatedAt' => $row['updated_at'],
        'deviceId' => $row['device_id'],
    ]);
    exit;
}

if ($action !== 'push') {
    $mysqli->close();
    http_response_code(400);
    echo json_encode(['ok' => false, 'error' => "Unsupported action: {$action}"]);
    exit;
}

$snapshot = $data['snapshot'] ?? null;
if (!is_array($snapshot)) {
    $mysqli->close();
    http_response_code(400);
    echo json_encode(['ok' => false, 'error' => 'Missing snapshot payload.']);
    exit;
}

$encoded = json_encode($snapshot, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);
if ($encoded === false) {
    $mysqli->close();
    http_response_code(500);
    echo json_encode(['ok' => false, 'error' => 'Could not encode the calendar snapshot.']);
    exit;
}

$stmt = $mysqli->prepare('INSERT INTO quad_sync (token, device_id, snapshot, updated_at) VALUES (?, ?, ?, NOW()) ON DUPLICATE KEY UPDATE device_id = VALUES(device_id), snapshot = VALUES(snapshot), updated_at = NOW()');
$stmt->bind_param('sss', $token, $deviceId, $encoded);
if (!$stmt->execute()) {
    $stmt->close();
    $mysqli->close();
    http_response_code(500);
    echo json_encode(['ok' => false, 'error' => 'Failed to save the sync payload.']);
    exit;
}

$stmt->close();

$stmt = $mysqli->prepare('SELECT snapshot, updated_at, device_id FROM quad_sync WHERE token = ? LIMIT 1');
$stmt->bind_param('s', $token);
$stmt->execute();
$result = $stmt->get_result();
$row = $result->fetch_assoc();
$stmt->close();
$mysqli->close();

if (!$row) {
    http_response_code(500);
    echo json_encode(['ok' => false, 'error' => 'Sync stored but the snapshot could not be read back.']);
    exit;
}

echo json_encode([
    'ok' => true,
    'snapshot' => json_decode($row['snapshot'], true) ?: ['events' => [], 'labels' => [], 'settings' => []],
    'updatedAt' => $row['updated_at'],
    'deviceId' => $row['device_id'],
]);
