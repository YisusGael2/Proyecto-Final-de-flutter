import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:barcode_widget/barcode_widget.dart';

class IngresoScreen extends StatefulWidget {
  const IngresoScreen({super.key});

  @override
  State<IngresoScreen> createState() => _IngresoScreenState();
}

class _IngresoScreenState extends State<IngresoScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _placaController = TextEditingController();
  final TextEditingController _modeloController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  
  bool _isLoading = false;
  
  // Lista dinámica
  List<dynamic> _listaVehiculosBD = [];
  bool _cargandoLista = true;
  String _errorLista = ""; // Para ver si hay error en texto

  @override
  void initState() {
    super.initState();
    _cargarVehiculosFrecuentes();
  }

  // --- 1. FUNCIÓN PARA CARGAR LISTA (DEBUG MEJORADO) ---
  Future<void> _cargarVehiculosFrecuentes() async {
    // Si usas Web: localhost. Si usas Emulador Android: 10.0.2.2
    String host = kIsWeb ? 'localhost' : '10.0.2.2';
    // ASEGÚRATE QUE LA RUTA SEA CORRECTA
    var url = Uri.parse('http://$host/parking_api/obtener_vehiculos.php');

    try {
      var response = await http.get(url);
      
      print("Respuesta del servidor: ${response.body}"); // MIRA LA CONSOLA

      if (response.statusCode == 200) {
        setState(() {
          _listaVehiculosBD = jsonDecode(response.body);
          _cargandoLista = false;
          _errorLista = "";
        });
      } else {
         setState(() {
          _errorLista = "Error ${response.statusCode}";
          _cargandoLista = false;
        });
      }
    } catch (e) {
      print("Error cargando lista: $e");
      setState(() {
        _cargandoLista = false;
        _errorLista = "Error de conexión: $e";
      });
    }
  }

  // --- 2. FUNCIÓN PARA REGISTRAR (YA CONECTADA) ---
  Future<void> registrarEntrada() async {
    if (_placaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Falta la placa")));
      return;
    }

    setState(() => _isLoading = true);
    
    String host = kIsWeb ? 'localhost' : '10.0.2.2';
    var url = Uri.parse('http://$host/parking_api/registrar_entrada.php');

    try {
      var response = await http.post(url, body: {
        "placa": _placaController.text.toUpperCase(),
        "modelo": _modeloController.text,
        "color": _colorController.text,
      });

      print("Respuesta Registro: ${response.body}"); // DEBUG

      var data = jsonDecode(response.body);

      if (data['success'] == true) {
        // SI SE GUARDÓ, MOSTRAMOS TICKET
        _mostrarTicketVirtual(data['ticket']);
        _placaController.clear();
        _modeloController.clear();
        _colorController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error API: ${data['message']}")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error de conexión: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  // --- 3. EL TICKET VIRTUAL (TU CÓDIGO ORIGINAL) ---
  // REEMPLAZA TU FUNCIÓN _mostrarTicketVirtual POR ESTA:
  void _mostrarTicketVirtual(Map ticket) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. ENCABEZADO
                const Icon(Icons.receipt_long, size: 40, color: Colors.black54),
                const SizedBox(height: 5),
                const Text(
                  "TICKET DE ENTRADA",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Courier'),
                ),
                const Divider(color: Colors.black, thickness: 1, height: 20),
                
                // 2. PLACA (GRANDE)
                Text(
                  "PLACA: ${ticket['placa']}", 
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, fontFamily: 'Courier')
                ),
                
                // 3. MODELO
                Text(
                  "${ticket['modelo']} - ${ticket['color']}", 
                  style: const TextStyle(fontSize: 14, fontFamily: 'Courier')
                ),
                
                const SizedBox(height: 15),

                // 4. ¡AQUÍ ESTÁ LA TARIFA QUE FALTABA!
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.grey[200], // Fondo grisecito
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.black12)
                  ),
                  child: Text(
                    // Si PHP no manda tarifa, mostramos 15.00 por defecto
                    "Tarifa: \$${ticket['tarifa'] ?? '15.00'} / Hr", 
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Courier', color: Colors.black87)
                  ),
                ),
                
                const SizedBox(height: 15),

                // 5. FECHA Y HORA
                Text(
                  "Entrada: ${ticket['entrada']}", 
                  style: const TextStyle(fontSize: 12, fontFamily: 'Courier')
                ),
                
                const SizedBox(height: 20),

                // 6. CÓDIGO DE BARRAS
                BarcodeWidget(
                  barcode: Barcode.code128(),
                  data: ticket['codigo'] ?? 'ERROR',
                  width: 200,
                  height: 60,
                  drawText: true,
                ),

                const SizedBox(height: 20),
                
                // 7. BOTÓN CERRAR
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                       Navigator.pop(context); // Cierra el ticket
                       Navigator.pop(context); // Regresa a la pantalla anterior
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                    child: const Text("CERRAR / IMPRIMIR", style: TextStyle(color: Colors.white)),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
  // --- 4. LA INTERFAZ VISUAL ---
  void _usarPredeterminado(String modelo, String color) {
    setState(() {
      _modeloController.text = modelo;
      _colorController.text = color;
    });
    Navigator.of(context).pop(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Ingresar Vehículo"),
        backgroundColor: const Color(0xFF263238),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          )
        ],
      ),
      endDrawer: Drawer(
        width: 280,
        child: Column(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF455A64)),
              child: Center(
                child: Text("Modelos Comunes", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            Expanded(
              child: _cargandoLista 
                  ? const Center(child: CircularProgressIndicator()) 
                  : _errorLista.isNotEmpty
                      ? Padding(padding: const EdgeInsets.all(20), child: Text(_errorLista, style: const TextStyle(color: Colors.red)))
                      : _listaVehiculosBD.isEmpty 
                          ? const Center(child: Text("No hay datos en la BD"))
                          : ListView.separated(
                              itemCount: _listaVehiculosBD.length,
                              separatorBuilder: (c, i) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final item = _listaVehiculosBD[index];
                                return ListTile(
                                  title: Text(item['modelo'] ?? 'Sin modelo', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text(item['color'] ?? 'Sin color'),
                                  onTap: () => _usarPredeterminado(item['modelo'], item['color']),
                                );
                              },
                            ),
            ),
             if (!_cargandoLista)
              TextButton.icon(
                onPressed: _cargarVehiculosFrecuentes,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text("Recargar Lista"),
              )
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _placaController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(labelText: "PLACA", prefixIcon: Icon(Icons.tag), border: OutlineInputBorder()),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: _modeloController, decoration: const InputDecoration(labelText: "Modelo", border: OutlineInputBorder()))),
                        const SizedBox(width: 15),
                        Expanded(child: TextField(controller: _colorController, decoration: const InputDecoration(labelText: "Color", border: OutlineInputBorder()))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : registrarEntrada,
                icon: const Icon(Icons.print, color: Colors.white),
                label: _isLoading 
                  ? const Text("PROCESANDO...", style: TextStyle(color: Colors.white))
                  : const Text("REGISTRAR ENTRADA", style: TextStyle(fontSize: 16, color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF263238)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}