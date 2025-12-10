import 'dart:convert';
import 'package:flutter/foundation.dart'; // Para kIsWeb
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SalidaScreen extends StatefulWidget {
  const SalidaScreen({super.key});

  @override
  State<SalidaScreen> createState() => _SalidaScreenState();
}

class _SalidaScreenState extends State<SalidaScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  bool _buscando = false;
  Map<String, dynamic>? _infoCobro; // Aquí guardamos los datos si encontramos el auto

  // 1. BUSCAR Y CALCULAR
  Future<void> consultarCobro() async {
    if (_searchController.text.isEmpty) return;

    setState(() { _buscando = true; _infoCobro = null; });

    String host = kIsWeb ? 'localhost' : '10.0.2.2';
    var url = Uri.parse('http://$host/parking_api/consultar_cobro.php');

    try {
      var response = await http.post(url, body: {
      
        "codigo_barra": _searchController.text.trim(), 
      });

      var data = jsonDecode(response.body);

      if (data['encontrado'] == true) {
        setState(() => _infoCobro = data);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['mensaje'])));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error de conexión: $e")));
    } finally {
      setState(() => _buscando = false);
    }
  }

  // 2. CONFIRMAR Y PAGAR
  Future<void> registrarSalida() async {
    if (_infoCobro == null) return;

    String host = kIsWeb ? 'localhost' : '10.0.2.2';
    var url = Uri.parse('http://$host/parking_api/registrar_salida.php');

    try {
      var response = await http.post(url, body: {
        "placa": _infoCobro!['placa'],
        "total": _infoCobro!['total'].toString(),
      });

      var data = jsonDecode(response.body);

      if (data['success'] == true) {
        // ÉXITO: Mostramos alerta y salimos
        showDialog(
          context: context, 
          barrierDismissible: false,
          builder: (c) => AlertDialog(
            title: const Text("¡Cobro Exitoso!"),
            content: const Icon(Icons.check_circle, color: Colors.green, size: 60),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Cierra dialogo
                  Navigator.pop(context); // Regresa al Home
                }, 
                child: const Text("ACEPTAR")
              )
            ],
          )
        );
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Salida y Cobro"),
        backgroundColor: const Color(0xFF5D4037), // Color Café/Rojo para salidas
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- BUSCADOR ---
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                          labelText: "Buscar Codigo de Barra",
                          hintText: "Ej. ABC-123",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.search)
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _buscando ? null : consultarCobro,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5D4037),
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20)
                      ),
                      child: _buscando 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                        : const Icon(Icons.arrow_forward, color: Colors.white),
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // --- RESULTADO DEL COBRO (SOLO SI SE ENCONTRÓ) ---
            if (_infoCobro != null) 
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Text("RESUMEN DE PAGO", style: TextStyle(fontSize: 18, color: Colors.grey, letterSpacing: 2)),
                      const Divider(height: 30),
                      
                      // Placa gigante
                      Text(
                        _infoCobro!['placa'], 
                        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Color(0xFF263238))
                      ),
                      Text(_infoCobro!['modelo'] ?? "", style: const TextStyle(fontSize: 16, color: Colors.grey)),
                      
                      const SizedBox(height: 20),
                      
                      // Detalles Tiempo
                      _filaDetalle("Entrada:", _infoCobro!['hora_entrada']),
                      _filaDetalle("Salida:", _infoCobro!['hora_salida']),
                      _filaDetalle("Tiempo Total:", _infoCobro!['tiempo_transcurrido']),
                      
                      const Divider(height: 30, thickness: 2),

                      // TOTAL
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("TOTAL A PAGAR:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(
                            "\$${_infoCobro!['total']}.00", 
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green)
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // BOTÓN COBRAR
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton.icon(
                          onPressed: registrarSalida,
                          icon: const Icon(Icons.attach_money, color: Colors.white),
                          label: const Text("CONFIRMAR Y COBRAR", style: TextStyle(fontSize: 18, color: Colors.white)),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
                        ),
                      )
                    ],
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _filaDetalle(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(valor),
        ],
      ),
    );
  }
}