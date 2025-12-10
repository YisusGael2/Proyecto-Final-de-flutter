<?php
date_default_timezone_set('America/Mexico_City');
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
error_reporting(0);

// 1. CONEXIÓN DIRECTA (Segura y sin errores de include)
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "parking_db";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die(json_encode(array("encontrado" => false, "mensaje" => "Error Conexión BD")));
}

// 2. RECIBIMOS EL CÓDIGO DE BARRAS (Ya no la placa)
$codigo = isset($_POST['codigo_barra']) ? $_POST['codigo_barra'] : '';

// 3. OBTENER LA TARIFA (Corregido según tu imagen: id=1, precio_hora)
$sql_conf = "SELECT precio_hora FROM configuracion WHERE id = 1";
$res_conf = $conn->query($sql_conf);
$tarifa_actual = 15.00; 

if ($res_conf && $res_conf->num_rows > 0) {
    $fila = $res_conf->fetch_assoc();
    $tarifa_actual = floatval($fila['precio_hora']);
}

// 4. BUSCAR EL TICKET POR CÓDIGO DE BARRAS
$sql = "SELECT * FROM tickets WHERE codigo_barra = '$codigo' AND estado = 'pendiente'";
$result = $conn->query($sql);

if ($result && $result->num_rows > 0) {
    $row = $result->fetch_assoc();
    
    $entrada = new DateTime($row['hora_entrada']);
    $ahora = new DateTime();
    $diferencia = $entrada->diff($ahora);

    $horas = $diferencia->h + ($diferencia->days * 24);
    $minutos = $diferencia->i;
    
    // Regla de cobro
    $horas_a_cobrar = $horas;
    if ($minutos > 0 || ($horas == 0 && $minutos > 0)) {
        $horas_a_cobrar++;
    }

    $total = $horas_a_cobrar * $tarifa_actual;

    $respuesta = array(
        "encontrado" => true,
        "codigo_barra" => $row['codigo_barra'], // Devolvemos el código
        "placa" => $row['placa'],
        "modelo" => $row['modelo'], 
        "color" => $row['color'],
        "hora_entrada" => $row['hora_entrada'],
        "hora_salida" => $ahora->format('Y-m-d H:i:s'),
        "tiempo_transcurrido" => "$horas hrs $minutos min",
        "total" => $total,
        "tarifa_usada" => $tarifa_actual
    );

} else {
    $respuesta = array("encontrado" => false, "mensaje" => "Código no encontrado o ya pagado");
}

echo json_encode($respuesta);
$conn->close();
?>