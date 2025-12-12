<?php
date_default_timezone_set('America/Mexico_City');
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
error_reporting(0);

// CONEXIÓN
$conn = new mysqli("localhost", "root", "", "parking_db");

if ($conn->connect_error) {
    die(json_encode(array("encontrado" => false, "mensaje" => "Error Conexión BD")));
}

$codigo = isset($_POST['codigo_barra']) ? $_POST['codigo_barra'] : '';

// 1. OBTENEMOS TARIFA NORMAL Y PRECIO DE BOLETO PERDIDO
$sql_conf = "SELECT precio_hora, precio_boleto_perdido FROM configuracion WHERE id = 1";
$res_conf = $conn->query($sql_conf);
$tarifa_actual = 15.00; 
$precio_perdido = 100.00; // Valor por defecto

if ($res_conf && $res_conf->num_rows > 0) {
    $fila = $res_conf->fetch_assoc();
    $tarifa_actual = floatval($fila['precio_hora']);
    // Si existe el dato en la BD lo usamos, si no, se queda en 100
    if(isset($fila['precio_boleto_perdido'])) {
        $precio_perdido = floatval($fila['precio_boleto_perdido']);
    }
}

// 2. BUSCAR EL TICKET
$sql = "SELECT * FROM tickets WHERE codigo_barra = '$codigo' AND estado = 'pendiente'";
$result = $conn->query($sql);

if ($result && $result->num_rows > 0) {
    $row = $result->fetch_assoc();
    
    // CÁLCULOS DE TIEMPO
    $entrada = new DateTime($row['hora_entrada']);
    $ahora = new DateTime();
    $diferencia = $entrada->diff($ahora);

    $horas = $diferencia->h + ($diferencia->days * 24);
    $minutos = $diferencia->i;
    
    $horas_a_cobrar = $horas;
    if ($minutos > 0 || ($horas == 0 && $minutos > 0)) {
        $horas_a_cobrar++;
    }

    $total_normal = $horas_a_cobrar * $tarifa_actual;

    $respuesta = array(
        "encontrado" => true,
        "codigo_barra" => $row['codigo_barra'],
        "placa" => $row['placa'],
        "modelo" => $row['modelo'], 
        "color" => $row['color'],
        "hora_entrada" => $row['hora_entrada'],
        "hora_salida" => $ahora->format('Y-m-d H:i:s'),
        "tiempo_transcurrido" => "$horas hrs $minutos min",
        "total" => $total_normal,
        "tarifa_usada" => $tarifa_actual,
        "precio_boleto_perdido" => $precio_perdido // <--- AQUÍ ENVIAMOS EL DATO NUEVO
    );

} else {
    $respuesta = array("encontrado" => false, "mensaje" => "Código no encontrado o ya pagado");
}

echo json_encode($respuesta);
$conn->close();
?>