<?php
date_default_timezone_set('America/Mexico_City');
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
error_reporting(0);

// 1. CONEXIÓN DIRECTA
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "parking_db";
$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die(json_encode(array("success" => false, "message" => "Error BD")));
}

$placa = isset($_POST['placa']) ? $_POST['placa'] : '';
$modelo = isset($_POST['modelo']) ? $_POST['modelo'] : '';
$color = isset($_POST['color']) ? $_POST['color'] : '';

// 2. OBTENER TARIFA
$sql_conf = "SELECT precio_hora FROM configuracion WHERE id = 1";
$res_conf = $conn->query($sql_conf);
$precio_actual = "15.00"; 

if ($res_conf && $res_conf->num_rows > 0) {
    $fila = $res_conf->fetch_assoc();
    $precio_actual = $fila['precio_hora'];
}

// 3. GENERAR CÓDIGO
$dias = ['Sun'=>'DOM','Mon'=>'LUN','Tue'=>'MAR','Wed'=>'MIE','Thu'=>'JUE','Fri'=>'VIE','Sat'=>'SAB'];
$dia_actual = $dias[date('D')]; 
$fecha_codigo = date('dmy');    

$hoy = date('Y-m-d');
$sql_count = "SELECT COUNT(*) as total FROM tickets WHERE DATE(hora_entrada) = '$hoy'";
$res_count = $conn->query($sql_count); // <--- Aquí fallaba antes (usabas connect)
$row_count = $res_count->fetch_assoc();
$consecutivo = $row_count['total'] + 1; 

$secuencia = str_pad($consecutivo, 3, "0", STR_PAD_LEFT);
$codigo_barra = $dia_actual . $fecha_codigo . $secuencia;

// 4. INSERTAR
$fecha_entrada = date("Y-m-d H:i:s");
$sql = "INSERT INTO tickets (codigo_barra, placa, modelo, color, hora_entrada, estado, tarifa_aplicada) 
        VALUES ('$codigo_barra', '$placa', '$modelo', '$color', '$fecha_entrada', 'pendiente', '$precio_actual')";

if ($conn->query($sql) === TRUE) { // <--- Aquí también fallaba
    echo json_encode(array(
        "success" => true,
        "message" => "Entrada registrada",
        "ticket" => array(
            "codigo" => $codigo_barra,
            "placa" => $placa,
            "modelo" => $modelo, 
            "color" => $color,
            "entrada" => date("d/m/Y H:i:s"),
            "tarifa" => $precio_actual
        )
    ));
} else {
    echo json_encode(array("success" => false, "message" => "Error SQL: " . $conn->error));
}

$conn->close();
?>