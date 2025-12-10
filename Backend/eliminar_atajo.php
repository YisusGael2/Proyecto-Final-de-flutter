<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
error_reporting(0);

// CONEXIÓN
$conn = new mysqli("localhost", "root", "", "parking_db");

$id = $_POST['id'];

if ($conn->query("DELETE FROM vehiculos_frecuentes WHERE id = $id") === TRUE) {
    echo json_encode(array("success" => true, "mensaje" => "Atajo eliminado"));
} else {
    echo json_encode(array("success" => false, "mensaje" => "Error: " . $conn->error));
}
$conn->close();
?>