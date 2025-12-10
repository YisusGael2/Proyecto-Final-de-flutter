<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
error_reporting(0);

// CONEXIÓN
$conn = new mysqli("localhost", "root", "", "parking_db");

$modelo = $_POST['modelo'];
$color = $_POST['color'];

if ($conn->query("INSERT INTO vehiculos_frecuentes (modelo, color) VALUES ('$modelo', '$color')") === TRUE) {
    echo json_encode(array("success" => true, "mensaje" => "Atajo agregado"));
} else {
    echo json_encode(array("success" => false, "mensaje" => "Error: " . $conn->error));
}
$conn->close();
?>