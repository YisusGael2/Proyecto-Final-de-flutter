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
    die(json_encode(array("success" => false, "mensaje" => "Error Conexión BD")));
}
// ------------------------

$placa = $_POST['placa'];
$total = $_POST['total'];
$hora_salida = date("Y-m-d H:i:s");

// Actualizamos a PAGADO
$sql = "UPDATE tickets SET 
        hora_salida = '$hora_salida', 
        total_cobrado = '$total', 
        estado = 'pagado' 
        WHERE placa = '$placa' AND estado = 'pendiente'";

if ($conn->query($sql) === TRUE) {
    echo json_encode(array("success" => true, "mensaje" => "Cobro registrado"));
} else {
    echo json_encode(array("success" => false, "mensaje" => "Error SQL: " . $conn->error));
}

$conn->close();
?>