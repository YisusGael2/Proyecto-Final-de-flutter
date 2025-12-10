import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AtajosScreen extends StatefulWidget {
  const AtajosScreen({super.key});

  @override
  State<AtajosScreen> createState() => _AtajosScreenState();
}

class _AtajosScreenState extends State<AtajosScreen> {
  List atajos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarAtajos();
  }

  // 1. CARGAR LISTA (Reusamos tu lógica anterior)
  Future<void> _cargarAtajos() async {
    String host = kIsWeb ? 'localhost' : '10.0.2.2';
    var url = Uri.parse('http://$host/parking_api/obtener_vehiculos.php');
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          atajos = jsonDecode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      print(e);
      setState(() => _isLoading = false);
    }
  }

  // 2. AGREGAR NUEVO
  Future<void> _agregarAtajo(String modelo, String color) async {
    String host = kIsWeb ? 'localhost' : '10.0.2.2';
    var url = Uri.parse('http://$host/parking_api/agregar_atajo.php');
    await http.post(url, body: {"modelo": modelo, "color": color});
    _cargarAtajos(); // Recargar lista
    Navigator.pop(context); // Cerrar diálogo
  }

  // 3. ELIMINAR UNO
  Future<void> _eliminarAtajo(String id) async {
    String host = kIsWeb ? 'localhost' : '10.0.2.2';
    var url = Uri.parse('http://$host/parking_api/eliminar_atajo.php');
    await http.post(url, body: {"id": id});
    _cargarAtajos(); // Recargar lista
  }

  // DIÁLOGO PARA ESCRIBIR EL NUEVO
  void _mostrarDialogoAgregar() {
    TextEditingController modeloCtrl = TextEditingController();
    TextEditingController colorCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nuevo Vehículo Frecuente"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: modeloCtrl, decoration: const InputDecoration(labelText: "Modelo (Ej. Tsuru)")),
            TextField(controller: colorCtrl, decoration: const InputDecoration(labelText: "Color (Ej. Blanco)")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () {
              if (modeloCtrl.text.isNotEmpty && colorCtrl.text.isNotEmpty) {
                _agregarAtajo(modeloCtrl.text, colorCtrl.text);
              }
            },
            child: const Text("Guardar"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Atajos"),
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView.separated(
            itemCount: atajos.length,
            separatorBuilder: (c, i) => const Divider(),
            itemBuilder: (context, index) {
              var item = atajos[index];
              return ListTile(
                leading: const Icon(Icons.star, color: Colors.amber),
                title: Text(item['modelo'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(item['color']),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _eliminarAtajo(item['id']),
                ),
              );
            },
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarDialogoAgregar,
        backgroundColor: Colors.blueGrey[800],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}