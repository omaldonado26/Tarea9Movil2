import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AgregarProductosTab extends StatefulWidget {
  final String dia;
  const AgregarProductosTab({super.key, required this.dia});

  @override
  State<AgregarProductosTab> createState() => _AgregarProductosTabState();
}

class _AgregarProductosTabState extends State<AgregarProductosTab> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController precioController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();

  File? imagenSeleccionada;

  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        imagenSeleccionada = File(picked.path);
      });
    }
  }

  Future<String?> _subirImagen(File imagen) async {
    final nombreArchivo = DateTime.now().millisecondsSinceEpoch.toString();
    final ref = FirebaseStorage.instance.ref().child(
      'productos/$nombreArchivo.jpg',
    );
    await ref.putFile(imagen);
    return await ref.getDownloadURL();
  }

  Future<void> guardarProducto() async {
    if (_formKey.currentState!.validate()) {
      String? urlImagen;
      if (imagenSeleccionada != null) {
        urlImagen = await _subirImagen(imagenSeleccionada!);
      }

      await FirebaseFirestore.instance.collection('productos').add({
        'nombre': nombreController.text.trim(),
        'precio': double.tryParse(precioController.text.trim()) ?? 0,
        'descripcion': descripcionController.text.trim(),
        'imagen': urlImagen,
        'fechaRegistro': Timestamp.now(),
        'dia': widget.dia,
      });

      nombreController.clear();
      precioController.clear();
      descripcionController.clear();
      setState(() => imagenSeleccionada = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                'Agregar Producto',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: precioController,
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: descripcionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: _seleccionarImagen,
                child: Container(
                  height: 100,
                  width: double.infinity,
                  color: Colors.grey.shade200,
                  child: Center(
                    child: Text(
                      imagenSeleccionada == null
                          ? 'Seleccionar imagen'
                          : 'Imagen seleccionada',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: guardarProducto,
                icon: const Icon(Icons.save),
                label: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
