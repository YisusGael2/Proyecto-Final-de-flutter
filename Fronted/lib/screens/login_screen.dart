import 'dart:convert';
import 'home_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores para capturar texto
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  
  bool _isLoading = false;

  Future<void> login() async {
    setState(() {
      _isLoading = true;
    });

    // OJO: Si usas emulador Android usa 10.0.2.2
    // Si usas celular físico, usa la IP de tu PC (ej. 192.168.1.50)
    // Detectamos si es Web (Chrome) o App (Android)
     String host = kIsWeb ? 'localhost' : '10.0.2.2';

     var url = Uri.parse('http://$host/parking_api/login.php');

    try {
      var response = await http.post(url, body: {
        "usuario": _userController.text,
        "password": _passController.text,
      });

      var data = jsonDecode(response.body);

     if (data['success'] == true) {
        // EN LUGAR DE SOLO MOSTRAR MENSAJE, NAVEGAMOS:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(userData: data['user_data']),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${data['message']}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error de conexión: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Definimos colores locales para mantener el estilo estéril
    final Color primaryDark = const Color(0xFF263238); // Gris Oscuro
    final Color surfaceColor = const Color(0xFFECEFF1); // Gris muy claro (Fondo)

    return Scaffold(
      backgroundColor: surfaceColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. Icono o Logo (Estilo Minimalista)
              Icon(
                Icons.local_parking_rounded,
                size: 100,
                color: primaryDark,
              ),
              const SizedBox(height: 10),
              Text(
                "SISTEMA DE CONTROL DE VEHÍCULOS",
                style: TextStyle(
                  color: primaryDark,
                  fontSize: 16,
                  letterSpacing: 2.0, // Espaciado elegante
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),

              // 2. Tarjeta de Login (Card)
              Card(
                elevation: 4,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Text(
                        "Iniciar Sesión",
                        style: TextStyle(
                          color: Colors.blueGrey[800],
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 30),
                      
                      // Input Usuario
                      TextField(
                        controller: _userController,
                        decoration: InputDecoration(
                          labelText: "Usuario",
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Input Password
                      TextField(
                        controller: _passController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Contraseña",
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Botón Grande
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryDark,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  "INGRESAR",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              Text(
                "v1.0.0 - Modo Seguro",
                style: TextStyle(color: Colors.blueGrey[400], fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}