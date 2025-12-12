import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// 1. IMPORTACIONES PARA PDF
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class CorteScreen extends StatefulWidget {
  const CorteScreen({super.key});

  @override
  State<CorteScreen> createState() => _CorteScreenState();
}

class _CorteScreenState extends State<CorteScreen> {
  DateTime _fechaInicio = DateTime.now();
  DateTime _fechaFin = DateTime.now();
  
  bool _cargando = false;
  List _listaVentas = [];
  double _totalDinero = 0.0;
  int _totalAutos = 0;

  // ... (Tus funciones _seleccionarFecha y _generarCorte se quedan IGUAL, no las borres) ...
  
  // COPIA TUS FUNCIONES ANTIGUAS AQUÍ O DÉJALAS COMO ESTABAN:
  Future<void> _seleccionarFecha(BuildContext context, bool esInicio) async {
    final DateTime? picked = await showDatePicker(
      context: context, initialDate: esInicio ? _fechaInicio : _fechaFin,
      firstDate: DateTime(2020), lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() { esInicio ? _fechaInicio = picked : _fechaFin = picked; });
    }
  }

  Future<void> _generarCorte() async {
    setState(() => _cargando = true);
    String host = kIsWeb ? 'localhost' : '10.0.2.2';
    var url = Uri.parse('http://$host/parking_api/corte_caja.php');
    String fInicio = "${_fechaInicio.year}-${_fechaInicio.month.toString().padLeft(2, '0')}-${_fechaInicio.day.toString().padLeft(2, '0')}";
    String fFin = "${_fechaFin.year}-${_fechaFin.month.toString().padLeft(2, '0')}-${_fechaFin.day.toString().padLeft(2, '0')}";

    try {
      var response = await http.post(url, body: {"fecha_inicio": fInicio, "fecha_fin": fFin});
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

  // --- 2. NUEVA FUNCIÓN: GENERAR PDF ---
  Future<void> _imprimirPDF() async {
    if (_listaVentas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No hay datos para exportar")));
      return;
    }

    final doc = pw.Document();

    // Formato de fechas para el título
    String fInicio = "${_fechaInicio.day}/${_fechaInicio.month}/${_fechaInicio.year}";
    String fFin = "${_fechaFin.day}/${_fechaFin.month}/${_fechaFin.year}";

    // Agregamos una página (MultiPage soporta varias hojas si la lista es larga)
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return [
            // TÍTULO
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Reporte de Corte de Caja", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.Text("Generado: ${DateTime.now().toString().substring(0, 16)}"),
                ]
              )
            ),
            
            pw.SizedBox(height: 10),
            pw.Text("Periodo: $fInicio al $fFin", style: const pw.TextStyle(fontSize: 14)),
            pw.Divider(),
            pw.SizedBox(height: 10),

            // RESUMEN
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
              children: [
                _cajaResumenPDF("Total Ingresos", "\$${_totalDinero.toStringAsFixed(2)}"),
                _cajaResumenPDF("Total Autos", "$_totalAutos"),
              ]
            ),

            pw.SizedBox(height: 20),

            // TABLA DE DATOS
            pw.Table.fromTextArray(
              context: context,
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              headerHeight: 25,
              cellAlignment: pw.Alignment.centerLeft,
              headers: ['Placa', 'Hora Salida', 'Cobrado'],
              data: _listaVentas.map((item) {
                return [
                  item['placa'],
                  item['hora_salida'],
                  "\$${item['total_cobrado']}",
                ];
              }).toList(),
            ),
            
            pw.SizedBox(height: 20),
            pw.Text("Fin del reporte.", style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
          ];
        },
      ),
    );

    // Muestra la vista previa nativa del celular/web
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }

  // Widget auxiliar para el PDF (Diseño del resumen)
  pw.Widget _cajaResumenPDF(String titulo, String valor) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(border: pw.Border.all(), borderRadius: pw.BorderRadius.circular(5)),
      child: pw.Column(
        children: [
          pw.Text(titulo, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
          pw.Text(valor, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        ]
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Corte de Caja"),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
        actions: [
          // 3. BOTÓN DE IMPRIMIR EN LA BARRA
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: "Exportar PDF",
            onPressed: _listaVentas.isNotEmpty ? _imprimirPDF : null, // Solo activo si hay datos
          )
        ],
      ),
      // ... EL RESTO DE TU BODY SE QUEDA IGUAL ...
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
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
          Expanded(
            child: _cargando 
              ? const Center(child: CircularProgressIndicator()) 
              : _listaVentas.isEmpty 
                  ? const Center(child: Text("No hay movimientos"))
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
                            trailing: Text("\$${item['total_cobrado']}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        );
                      },
                    ),
          )
        ],
      ),
    );
  }
  
  // TUS WIDGETS VISUALES NORMALES...
  Widget _botonFecha(String label, DateTime fecha, bool esInicio) {
    return Column(children: [Text(label), TextButton(onPressed: () => _seleccionarFecha(context, esInicio), child: Text("${fecha.day}/${fecha.month}/${fecha.year}"))]);
  }
  Widget _tarjetaResumen(String titulo, String valor, Color color) {
    return Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)), child: Column(children: [Text(titulo), Text(valor, style: TextStyle(fontSize: 24, color: color, fontWeight: FontWeight.bold))]));
  }
}