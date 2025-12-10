<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
error_reporting(0);

// Conexión
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "parking_db";
$conn = new mysqli($servername, $username, $password, $dbname);

$nueva_tarifa = $_POST['tarifa'];

if(empty($nueva_tarifa)) {
    die(json_encode(array("success" => false, "mensaje" => "Tarifa vacía")));
}

// ACTUALIZAMOS LA TABLA SEGÚN TU IMAGEN (precio_hora, id=1)
$sql = "UPDATE configuracion SET precio_hora = '$nueva_tarifa' WHERE id = 1";

if ($conn->query($sql) === TRUE) {
    echo json_encode(array("success" => true, "mensaje" => "Tarifa actualizada a $$nueva_tarifa"));
} else {
    echo json_encode(array("success" => false, "mensaje" => "Error BD: " . $conn->error));
}
$conn->close();
?>