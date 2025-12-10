<?php
// 1. Encabezados para permitir acceso
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

// 2. CONEXIÓN DIRECTA (Para eliminar el error de $conn)
$servername = "localhost";
$username = "root";
$password = "";      
$dbname = "parking_db"; // <--- Confirma que este es el nombre exacto

$conn = new mysqli($servername, $username, $password, $dbname);

// 3. Verificamos si la conexión falló
if ($conn->connect_error) {
    // Si falla, mostramos el error en formato JSON
    die(json_encode([["placa" => "ERROR", "modelo" => "Revisa la BD", "color" => "Conexión fallida"]]));
}

// 4. LA CONSULTA: Traer solo los pendientes
$sql = "SELECT * FROM tickets WHERE estado = 'pendiente' ORDER BY hora_entrada DESC";
$result = $conn->query($sql);

$tickets = array();

if ($result && $result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        $tickets[] = $row;
    }
}

// 5. Devolver resultado
echo json_encode($tickets);

$conn->close();
?>