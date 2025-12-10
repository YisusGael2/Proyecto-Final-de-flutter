import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login_screen.dart'; 
import 'ingreso_screen.dart';
import 'salida_screen.dart';
import 'corte_screen.dart';
import 'package:flutter/foundation.dart'; 
import 'atajos_screen.dart';

class HomeScreen extends StatefulWidget {
  final Map userData; 

  const HomeScreen({super.key, required this.userData});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List tickets = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTickets(); 
  }

  // --- CORRECCIÓN IMPORTANTE AQUÍ ---
  Future<void> fetchTickets() async {
    String host = kIsWeb ? 'localhost' : '10.0.2.2';
    
    // CAMBIO 1: Usamos el archivo correcto, NO login.php
    var url = Uri.parse('http://$host/parking_api/obtener_pendientes.php'); 
    
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          tickets = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        // Si hay error 404 o 500, quitamos el cargando
        print("Error servidor: ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error conexión: $e");
      // Importante: Quitamos el cargando para que no se quede pegado el spinner
      setState(() => isLoading = false);
    }
  }

  void _cerrarSesion() {
    Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

   void _cambiarTarifa() {
    TextEditingController _tarifaController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Nueva Tarifa por Hora"),
          content: TextField(
            controller: _tarifaController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Precio",
              prefixText: "\$ ",
              border: OutlineInputBorder()
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text("Cancelar")
            ),
            ElevatedButton(
              onPressed: () async {
                if (_tarifaController.text.isNotEmpty) {
                  // Enviamos al servidor
                  String host = kIsWeb ? 'localhost' : '10.0.2.2';
                  var url = Uri.parse('http://$host/parking_api/actualizar_tarifa.php');
                  
                  try {
                    var response = await http.post(url, body: {"tarifa": _tarifaController.text});
                    // Cerramos dialogo
                    Navigator.pop(context);
                    
                    // Mostramos confirmación
                    ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(content: Text("Tarifa actualizada correctamente"), backgroundColor: Colors.green)
                    );
                  } catch (e) {
                    print(e);
                  }
                }
              }, 
              child: const Text("GUARDAR")
            )
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryDark = const Color(0xFF263238);
    final Color accentGreen = const Color(0xFF455A64); 
    final Color accentRed = const Color(0xFF5D4037);   

    return Scaffold(
      backgroundColor: const Color(0xFFECEFF1), 
      appBar: AppBar(
        title: const Text("Control de Vehiculos", style: TextStyle(color: Colors.white, fontSize: 18)),
        backgroundColor: primaryDark,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() => isLoading = true); // Mostramos spinner al recargar
              fetchTickets();
            }, 
          ),
          
          // --- MENÚ DESPLEGABLE CON LAS NUEVAS OPCIONES ---
          PopupMenuButton<String>(
            iconColor: Colors.white,
            onSelected: (value) {
              if (value == 'logout') _cerrarSesion();
              if (value == 'tarifa') {
                _cambiarTarifa();
              }
              if (value == 'atajos') {
                 Navigator.push(
    context, 
    MaterialPageRoute(builder: (context) => const AtajosScreen())
    );
              }
              if (value == 'cortes') {
                 // NAVEGAR AL CORTE DE CAJA
                 Navigator.push(
                   context, 
                   MaterialPageRoute(builder: (context) => const CorteScreen())
                 );
              }
            },
            itemBuilder: (context) => [
              // Sección Configuración
              const PopupMenuItem(
                value: 'tarifa', 
                child: Row(children: [Icon(Icons.attach_money, color: Colors.grey), SizedBox(width: 10), Text("Cambiar Tarifa")])
              ),
              const PopupMenuItem(
                value: 'atajos', 
                child: Row(children: [Icon(Icons.flash_on, color: Colors.grey), SizedBox(width: 10), Text("Editar Atajos")])
              ),
              const PopupMenuDivider(),
              // Sección Sistema
              const PopupMenuItem(value: 'cortes', child: Text("Cortes de Caja")),
              const PopupMenuItem(
                value: 'logout', 
                child: Row(children: [Icon(Icons.logout, color: Colors.red), SizedBox(width: 10), Text("Cerrar Sesión", style: TextStyle(color: Colors.red))])
              ),
            ],
          ),
        ],
      ),
      
      body: Column(
        children: [
          // BOTONES INGRESO / SALIDA
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)]),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const IngresoScreen()))
                      .then((_) => fetchTickets()); // Recargar al volver
                    },
                    icon: const Icon(Icons.directions_car, color: Colors.white),
                    label: const Text("INGRESO", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: accentGreen, padding: const EdgeInsets.symmetric(vertical: 15)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
  child: ElevatedButton.icon(
    onPressed: () {
      // NAVEGAR A PANTALLA DE SALIDA
      Navigator.push(
        context, 
        MaterialPageRoute(builder: (context) => const SalidaScreen())
      ).then((_) {
        // Al regresar, actualizamos la lista para que ya no salga el auto que se fue
        fetchTickets();
      });
    },
    icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
    label: const Text("SALIDA", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: accentRed, padding: const EdgeInsets.symmetric(vertical: 15)),
                  ),
                ),
              ],
            ),
          ),

          // LISTA DE VEHÍCULOS
          Expanded(
            child: isLoading 
              ? const Center(child: CircularProgressIndicator()) 
              : tickets.isEmpty 
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.garage_outlined, size: 60, color: Colors.blueGrey[200]),
                        const SizedBox(height: 10),
                        const Text("No hay vehículos pendientes", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: tickets.length,
                    itemBuilder: (context, index) {
                      var auto = tickets[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blueGrey[100],
                            child: const Icon(Icons.directions_car, color: Colors.black54),
                          ),
                          title: Text(auto['placa'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          subtitle: Text("${auto['modelo']} • ${auto['color']}"),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Muestra solo la hora HH:MM:SS
                              Text(auto['hora_entrada'].toString().split(" ")[1], style: const TextStyle(fontWeight: FontWeight.bold)),
                              const Text("Entrada", style: TextStyle(fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}