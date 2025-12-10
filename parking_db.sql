-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 10-12-2025 a las 14:50:27
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `parking_db`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `configuracion`
--

CREATE TABLE `configuracion` (
  `id` int(11) NOT NULL,
  `precio_hora` decimal(10,2) NOT NULL DEFAULT 10.00,
  `tolerancia_minutos` int(11) DEFAULT 5,
  `mensaje_ticket` varchar(255) DEFAULT 'Gracias por su preferencia',
  `nombre_estacionamiento` varchar(100) DEFAULT 'Mi Parking'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `configuracion`
--

INSERT INTO `configuracion` (`id`, `precio_hora`, `tolerancia_minutos`, `mensaje_ticket`, `nombre_estacionamiento`) VALUES
(1, 10.00, 5, 'Gracias por su preferencia', 'Mi Parking');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tickets`
--

CREATE TABLE `tickets` (
  `id` int(11) NOT NULL,
  `codigo_barra` varchar(50) NOT NULL,
  `placa` varchar(20) NOT NULL,
  `modelo` varchar(50) DEFAULT NULL,
  `color` varchar(30) DEFAULT NULL,
  `hora_entrada` datetime NOT NULL,
  `hora_salida` datetime DEFAULT NULL,
  `tiempo_total` varchar(20) DEFAULT NULL,
  `tarifa_aplicada` decimal(10,2) NOT NULL,
  `total_cobrado` decimal(10,2) DEFAULT 0.00,
  `estado` enum('pendiente','pagado') DEFAULT 'pendiente',
  `usuario_entrada_id` int(11) DEFAULT NULL,
  `usuario_salida_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `tickets`
--

INSERT INTO `tickets` (`id`, `codigo_barra`, `placa`, `modelo`, `color`, `hora_entrada`, `hora_salida`, `tiempo_total`, `tarifa_aplicada`, `total_cobrado`, `estado`, `usuario_entrada_id`, `usuario_salida_id`) VALUES
(1, 'LUN081225001', 'HDGDHDG', 'MAZDA', 'ROJO', '2025-12-07 19:33:47', '2025-12-10 07:20:34', NULL, 15.00, 600.00, 'pagado', NULL, NULL),
(2, 'DOM071225002', 'JFHASHDF', 'bocho', 'gris', '2025-12-07 19:47:10', '2025-12-07 20:28:25', NULL, 15.00, 15.00, 'pagado', NULL, NULL),
(3, 'DOM071225003', 'HKDJFJD', 'Nissan Tsuru', 'Blanco', '2025-12-07 19:54:57', '2025-12-07 20:28:10', NULL, 15.00, 15.00, 'pagado', NULL, NULL),
(4, 'DOM071225004', 'JDFJFUF', 'VW Jetta', 'Gris', '2025-12-07 19:58:36', '2025-12-07 20:27:55', NULL, 15.00, 15.00, 'pagado', NULL, NULL),
(5, 'DOM071225005', 'JFGHDUD', 'Chevrolet Aveo', 'Rojo', '2025-12-07 19:59:07', '2025-12-07 20:26:21', NULL, 15.00, 15.00, 'pagado', NULL, NULL),
(6, 'DOM071225006', 'JDJFJFJ', 'Nissan Tsuru', 'Blanco', '2025-12-07 20:03:29', '2025-12-07 20:26:50', NULL, 15.00, 15.00, 'pagado', NULL, NULL),
(7, 'DOM071225007', 'HOLAAA', 'mazda', 'rojo', '2025-12-07 20:35:31', '2025-12-10 07:21:09', NULL, 15.00, 590.00, 'pagado', NULL, NULL),
(8, 'DOM071225008', 'WIWICHO', 'Chevrolet Aveo', 'Rojo', '2025-12-07 20:39:44', '2025-12-10 07:21:20', NULL, 15.00, 590.00, 'pagado', NULL, NULL),
(9, 'DOM071225009', 'WIRIWI', 'Moto Italika', 'Negra', '2025-12-07 20:59:02', '2025-12-07 21:03:45', NULL, 20.00, 20.00, 'pagado', NULL, NULL),
(10, 'DOM071225010', 'IEIUEY', 'VW Jetta', 'Gris', '2025-12-07 21:06:48', '2025-12-08 11:36:43', NULL, 20.00, 525.00, 'pagado', NULL, NULL),
(11, 'DOM071225011', 'HJGHJD', 'Moto Italika', 'Negra', '2025-12-07 21:07:31', '2025-12-10 07:21:38', NULL, 35.00, 590.00, 'pagado', NULL, NULL),
(12, 'DOM071225012', 'JHJKHJKD', 'Bocho', 'Blanco', '2025-12-07 21:15:28', '2025-12-08 11:53:33', NULL, 35.00, 300.00, 'pagado', NULL, NULL),
(24, 'MIE101225001', 'JHGJHDGADJ', 'pulsar rs200', 'blanca', '2025-12-10 07:17:18', NULL, NULL, 10.00, 0.00, 'pendiente', NULL, NULL),
(25, 'MIE101225002', 'VNVBVNV', 'Nissan Tsuru', 'Blanco', '2025-12-10 07:18:30', NULL, NULL, 40.00, 0.00, 'pendiente', NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios`
--

CREATE TABLE `usuarios` (
  `id` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `usuario` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `rol` enum('admin','empleado') DEFAULT 'empleado',
  `activo` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `usuarios`
--

INSERT INTO `usuarios` (`id`, `nombre`, `usuario`, `password`, `rol`, `activo`) VALUES
(1, 'Administrador', 'admin', '$2y$10$8uYsuOQfhHwT3v3jUaUH4.uC98m7KtxjIxdL3dSzFT79YxC99dXra', 'admin', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `vehiculos_frecuentes`
--

CREATE TABLE `vehiculos_frecuentes` (
  `id` int(11) NOT NULL,
  `modelo` varchar(50) NOT NULL,
  `color` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `vehiculos_frecuentes`
--

INSERT INTO `vehiculos_frecuentes` (`id`, `modelo`, `color`) VALUES
(1, 'Nissan Tsuru', 'Blanco'),
(2, 'VW Jetta', 'Gris'),
(3, 'Chevrolet Aveo', 'Rojo'),
(5, 'Bocho', 'Blanco'),
(6, 'pulsar rs200', 'blanca');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `configuracion`
--
ALTER TABLE `configuracion`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `tickets`
--
ALTER TABLE `tickets`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `codigo_barra` (`codigo_barra`),
  ADD KEY `usuario_entrada_id` (`usuario_entrada_id`),
  ADD KEY `usuario_salida_id` (`usuario_salida_id`);

--
-- Indices de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `usuario` (`usuario`);

--
-- Indices de la tabla `vehiculos_frecuentes`
--
ALTER TABLE `vehiculos_frecuentes`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `configuracion`
--
ALTER TABLE `configuracion`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `tickets`
--
ALTER TABLE `tickets`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `vehiculos_frecuentes`
--
ALTER TABLE `vehiculos_frecuentes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `tickets`
--
ALTER TABLE `tickets`
  ADD CONSTRAINT `tickets_ibfk_1` FOREIGN KEY (`usuario_entrada_id`) REFERENCES `usuarios` (`id`),
  ADD CONSTRAINT `tickets_ibfk_2` FOREIGN KEY (`usuario_salida_id`) REFERENCES `usuarios` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
