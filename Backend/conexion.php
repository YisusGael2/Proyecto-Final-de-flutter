<?php
// conexion.php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Origin, X-Requested-With, Content-Type, Accept');
header('Content-Type: application/json; charset=UTF-8');

$host = "localhost"; 
$user = "root";      // Usuario por defecto de XAMPP
$pass = "";          // Contraseña por defecto (vacía)
$db   = "parking_db";

$connect = new mysqli($host, $user, $pass, $db);

if($connect->connect_error){
    // Si falla, enviamos un JSON de error para que Flutter sepa qué pasó
    echo json_encode(array(
        "success" => false,
        "message" => "Error de conexión: " . $connect->connect_error
    ));
    exit();
}
// Si no hay error, el script continúa silenciosamente listo para ser incluido en otros archivos
?>