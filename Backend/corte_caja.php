<?php
date_default_timezone_set('America/Mexico_City');
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
error_reporting(0);

// --- CONEXIÓN DIRECTA ---
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "parking_db";
$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die(json_encode(array("success" => false, "mensaje" => "Error BD")));
}

$fecha_inicio = $_POST['fecha_inicio']; // Formato YYYY-MM-DD
$fecha_fin = $_POST['fecha_fin'];       // Formato YYYY-MM-DD

// Consulta: Traer tickets PAGADOS en el rango de fechas
// Usamos DATE(hora_salida) para comparar solo la parte de la fecha, ignorando la hora exacta
$sql = "SELECT * FROM tickets 
        WHERE estado = 'pagado' 
        AND DATE(hora_salida) BETWEEN '$fecha_inicio' AND '$fecha_fin' 
        ORDER BY hora_salida DESC";

$result = $conn->query($sql);

$tickets = array();
$total_suma = 0.00;

if ($result && $result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        $tickets[] = $row;
        // Vamos sumando el dinero
        $total_suma += floatval($row['total_cobrado']);
    }
}

// Devolvemos la lista y el gran total
echo json_encode(array(
    "success" => true,
    "total_dinero" => $total_suma,
    "total_autos" => count($tickets),
    "lista" => $tickets
));

$conn->close();
?>