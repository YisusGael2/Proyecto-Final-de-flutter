import 'dart:convert';
import 'package:flutter/foundation.dart';
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
  Map<String, dynamic>? _infoCobro; 
  
  // VARIABLE NUEVA PARA SABER SI ESTAMOS COBRANDO MULTA
  bool _esBoletoPerdido = false; 

  Future<void> consultarCobro() async {
    if (_searchController.text.isEmpty) return;

    setState(() { _buscando = true; _infoCobro = null; _esBoletoPerdido = false; });

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

  // FUNCIÓN PARA CAMBIAR ENTRE COBRO NORMAL Y MULTA
  void toggleBoletoPerdido() {
    setState(() {
      _esBoletoPerdido = !_esBoletoPerdido;
      
      if (_esBoletoPerdido) {
        // Ponemos el precio de la multa
        _infoCobro!['total_real'] = _infoCobro!['total']; // Respaldamos el original
        _infoCobro!['total'] = _infoCobro!['precio_boleto_perdido'];
      } else {
        // Restauramos el precio por tiempo
        _infoCobro!['total'] = _infoCobro!['total_real'];
      }
    });
  }

  Future<void> registrarSalida() async {
    if (_infoCobro == null) return;

    String host = kIsWeb ? 'localhost' : '10.0.2.2';
    var url = Uri.parse('http://$host/parking_api/registrar_salida.php');

    try {
      var response = await http.post(url, body: {
        "placa": _infoCobro!['placa'],
        "total": _infoCobro!['total'].toString(),
        // Opcional: Podrías mandar una nota de que fue boleto perdido si quisieras
      });

      var data = jsonDecode(response.body);

      if (data['success'] == true) {
        showDialog(
          context: context, 
          barrierDismissible: false,
          builder: (c) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: const Column(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 60),
                SizedBox(height: 10),
                Text("¡Cobro Exitoso!", textAlign: TextAlign.center),
              ],
            ),
            content: Text(
              _esBoletoPerdido ? "Salida registrada con MULTA por boleto perdido." : "Salida registrada correctamente.", 
              textAlign: TextAlign.center
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); 
                  Navigator.pop(context); 
                }, 
                child: const Text("ACEPTAR", style: TextStyle(fontSize: 18))
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
        backgroundColor: const Color(0xFF5D4037),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // BUSCADOR
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                          labelText: "Escanear Código",
                          hintText: "DOM...",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.qr_code)
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
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white)) 
                        : const Icon(Icons.search, color: Colors.white),
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (_infoCobro != null) 
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // AVISO DE MULTA
                      if (_esBoletoPerdido)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 15),
                          padding: const EdgeInsets.all(8),
                          color: Colors.red[100],
                          child: const Text(
                            "⚠️ APLICANDO MULTA: BOLETO PERDIDO",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ),

                      Text(
                        _infoCobro!['placa'], 
                        style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Color(0xFF263238))
                      ),
                      Container(
                         margin: const EdgeInsets.only(top:5, bottom: 20),
                         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                         decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(5)),
                         child: Text("${_infoCobro!['modelo']} • ${_infoCobro!['color']}", style: const TextStyle(fontSize: 16)),
                      ),
                      
                      _filaDetalle("Entrada:", _infoCobro!['hora_entrada']),
                      _filaDetalle("Tiempo:", _infoCobro!['tiempo_transcurrido']),
                      
                      const Divider(height: 30, thickness: 1),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("TOTAL:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          Text(
                            "\$${_infoCobro!['total']}", // Muestra el total dinámico
                            style: TextStyle(
                              fontSize: 36, 
                              fontWeight: FontWeight.bold, 
                              color: _esBoletoPerdido ? Colors.red : Colors.green
                            )
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // BOTÓN TOGGLE: BOLETO PERDIDO
                      OutlinedButton.icon(
                        onPressed: toggleBoletoPerdido,
                        icon: Icon(_esBoletoPerdido ? Icons.undo : Icons.warning_amber_rounded, 
                                   color: _esBoletoPerdido ? Colors.black : Colors.red),
                        label: Text(_esBoletoPerdido ? "CANCELAR MULTA" : "COBRAR BOLETO PERDIDO"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _esBoletoPerdido ? Colors.black : Colors.red,
                          side: BorderSide(color: _esBoletoPerdido ? Colors.black : Colors.red)
                        ),
                      ),

                      const SizedBox(height: 20),

                      // BOTÓN FINALIZAR
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton.icon(
                          onPressed: registrarSalida,
                          icon: const Icon(Icons.attach_money, color: Colors.white, size: 28),
                          label: const Text("COBRAR Y FINALIZAR", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _esBoletoPerdido ? Colors.red[700] : Colors.green[700],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                          ),
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey)),
          Text(valor, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}