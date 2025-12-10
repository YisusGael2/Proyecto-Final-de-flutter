# Sistema de Control de Parking 🚗

Sistema completo para gestionar entradas, salidas y cobros de un estacionamiento.

## Tecnologías 
- **App Móvil:** Flutter (Dart)
- **Backend:** PHP (Nativo)
- **Base de Datos:** MySQL

## Funcionalidades 
- Registro de entrada con generación de ticket virtual.
- Cálculo automático de tarifa por tiempo.
- Corte de caja con reportes por fecha.
- Automatización de tarifas dinámicas.

## Instalación 

### Backend
1. Instala XAMPP.
2. Mueve la carpeta `backend_api` a `C:/xampp/htdocs/`.
3. Importa el archivo `database.sql` en phpMyAdmin.
4. Configura tu IP en los archivos PHP si usas dispositivo físico.

### App Móvil
1. Abre la carpeta `app_movil` en VS Code.
2. Ejecuta `flutter pub get`.
3. Corre la app con `flutter run`.