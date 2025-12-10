<?php
header("Access-Control-Allow-Origin: *"); // PERMITE CONEXIÓN DESDE CUALQUIER LADO
header("Access-Control-Allow-Headers: *");
header("Content-Type: application/json; charset=UTF-8");
include 'conexion.php';

// Recibimos los datos que envía Flutter
$usuario = $_POST['usuario'];
$password = $_POST['password'];

// Buscamos el usuario en la BD
$sql = "SELECT * FROM usuarios WHERE usuario = '$usuario'";
$result = $connect->query($sql);

if ($result->num_rows > 0) {
    $row = $result->fetch_assoc();
    
    if (password_verify($password, $row['password'])) {
        echo json_encode(array(
            "success" => true,
            "user_data" => $row
        ));
    } else {
        echo json_encode(array(
            "success" => false,
            "message" => "Contraseña incorrecta"
        ));
    }
} else {
    echo json_encode(array(
        "success" => false,
        "message" => "Usuario no encontrado"
    ));
}
?>