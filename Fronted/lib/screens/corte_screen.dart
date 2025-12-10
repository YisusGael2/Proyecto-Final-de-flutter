import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CorteScreen extends StatefulWidget {
  const CorteScreen({super.key});

  @override
  State<CorteScreen> createState() => _CorteScreenState();
}

class _CorteScreenState extends State<CorteScreen> {
  // Fechas por defecto: Hoy
  DateTime _fechaInicio = DateTime.now();
  DateTime _fechaFin = DateTime.now();
  
  bool _cargando = false;
  List _listaVentas = [];
  double _totalDinero = 0.0;
  int _totalAutos = 0;

  // FUNCIÓN PARA SELECCIONAR FECHA
  Future<void> _seleccionarFecha(BuildContext context, bool esInicio) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: esInicio ? _fechaInicio : _fechaFin,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.blueGrey,
              onPrimary: Colors.white,
              surface: Color(0xFF263238),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (esInicio) {
          _fechaInicio = picked;
        } else {
          _fechaFin = picked;
        }
      });
    }
  }

  // FUNCIÓN PARA GENERAR EL CORTE
  Future<void> _generarCorte() async {
    setState(() => _cargando = true);

    String host = kIsWeb ? 'localhost' : '10.0.2.2';
    var url = Uri.parse('http://$host/parking_api/corte_caja.php');

    // Formateamos la fecha a texto YYYY-MM-DD
    String fInicio = "${_fechaInicio.year}-${_fechaInicio.month.toString().padLeft(2, '0')}-${_fechaInicio.day.toString().padLeft(2, '0')}";
    String fFin = "${_fechaFin.year}-${_fechaFin.month.toString().padLeft(2, '0')}-${_fechaFin.day.toString().padLeft(2, '0')}";

    try {
      var response = await http.post(url, body: {
        "fecha_inicio": fInicio,
        "fecha_fin": fFin
      });

      var data = jsonDecode(response.body);

      if (data['success'] == true) {
        setState(() {
          _listaVentas = data['lista'];
          _totalDinero = double.parse(data['total_dinero'].toString());
          _totalAutos = int.parse(data['total_autos'].toString());
          _cargando = false;
        });
      }
    } catch (e) {
      print(e);
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Corte de Caja"),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // 1. SELECTORES DE FECHA
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _botonFecha("Desde", _fechaInicio, true),
                    const Icon(Icons.arrow_forward, color: Colors.grey),
                    _botonFecha("Hasta", _fechaFin, false),
                  ],
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _generarCorte,
                    icon: const Icon(Icons.search, color: Colors.white),
                    label: const Text("GENERAR REPORTE", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey[800]),
                  ),
                )
              ],
            ),
          ),

          // 2. RESUMEN (TARJETAS)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(child: _tarjetaResumen("Total Cobrado", "\$${_totalDinero.toStringAsFixed(2)}", Colors.green)),
                const SizedBox(width: 10),
                Expanded(child: _tarjetaResumen("Autos", "$_totalAutos", Colors.blue)),
              ],
            ),
          ),

          const Divider(),

          // 3. LISTA DE MOVIMIENTOS
          Expanded(
            child: _cargando 
              ? const Center(child: CircularProgressIndicator()) 
              : _listaVentas.isEmpty 
                  ? const Center(child: Text("No hay movimientos en estas fechas"))
                  : ListView.builder(
                      itemCount: _listaVentas.length,
                      itemBuilder: (context, index) {
                        var item = _listaVentas[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          elevation: 0,
                          child: ListTile(
                            leading: const Icon(Icons.monetization_on, color: Colors.green),
                            title: Text(item['placa'], style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text("Salida: ${item['hora_salida']}"),
                            trailing: Text(
                              "\$${item['total_cobrado']}", 
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)
                            ),
                          ),
                        );
                      },
                    ),
          )
        ],
      ),
    );
  }

  // WIDGETS AUXILIARES PARA QUE SE VEA BONITO
  Widget _botonFecha(String label, DateTime fecha, bool esInicio) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        TextButton(
          onPressed: () => _seleccionarFecha(context, esInicio),
          child: Text(
            "${fecha.day}/${fecha.month}/${fecha.year}",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey),
          ),
        )
      ],
    );
  }

  Widget _tarjetaResumen(String titulo, String valor, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)]),
      child: Column(
        children: [
          Text(titulo, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 5),
          Text(valor, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}