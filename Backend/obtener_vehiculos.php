<?php
// 1. Configuración para que SIEMPRE responda JSON (evita el error de <br>)
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
error_reporting(0); // Ocultar errores feos de PHP

// 2. CONEXIÓN DIRECTA (Así aseguramos que los datos son los correctos)
$servername = "localhost";
$username = "root";
$password = "";      // En XAMPP suele ser vacío
$dbname = "parking_db"; // Tu nombre correcto

$conn = new mysqli($servername, $username, $password, $dbname);

// 3. VERIFICACIÓN DE ERROR EN FORMATO JSON
if ($conn->connect_error) {
    // Si falla, le mandamos el error a la App disfrazado de vehículo para que lo leas
    echo json_encode([
        ["modelo" => "ERROR CONEXION", "color" => "Revisa pass/db"]
    ]);
    exit();
}

// 4. CONSULTA
$sql = "SELECT * FROM vehiculos_frecuentes";
$result = $conn->query($sql);

$vehiculos = array();

// 5. SI LA TABLA EXISTE PERO ESTÁ VACÍA
if ($result && $result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        $vehiculos[] = $row;
    }
} else {
    // Si no hay carros, avisamos
    $vehiculos[] = ["modelo" => "LISTA VACIA", "color" => "Inserta datos en BD"];
}

// 6. ENVIAR RESPUESTA FINAL
echo json_encode($vehiculos);

$conn->close();
?>