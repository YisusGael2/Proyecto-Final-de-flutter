<?php
// generar_hash.php
$password_texto_plano = "12345";

// Esto crea el hash seguro
$password_encriptada = password_hash($password_texto_plano, PASSWORD_DEFAULT);

echo "Copia este código y pégalo en tu base de datos:<br><br>";
echo "<b>" . $password_encriptada . "</b>";
?>