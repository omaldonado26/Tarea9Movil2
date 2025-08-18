import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AgregarTareaTab extends StatefulWidget {
  const AgregarTareaTab({super.key});

  @override
  State<AgregarTareaTab> createState() => _AgregarTareaTabState();
}

class _AgregarTareaTabState extends State<AgregarTareaTab> {
  final _formKey = GlobalKey<FormState>();
  final _titulo = TextEditingController();
  final _descripcion = TextEditingController();
  bool _estado = true;

  @override
  void dispose() {
    _titulo.dispose();
    _descripcion.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    await FirebaseFirestore.instance.collection('tareas').add({
      'titulo': _titulo.text.trim(),
      'descripcion': _descripcion.text.trim(),
      'estado': _estado,
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Tarea guardada')));
      _formKey.currentState!.reset();
      setState(() => _estado = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const Text(
                  'Digita los datos de la tarea a recordar',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _titulo,
                  decoration: const InputDecoration(
                    labelText: 'Título de la tarea',
                    prefixIcon: Icon(Icons.title),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Campo obligatorio'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descripcion,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Descripción de la tarea',
                    prefixIcon: Icon(Icons.description),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Campo obligatorio'
                      : null,
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Estado (completada)'),
                  subtitle: const Text('Apágalo si está pendiente'),
                  value: _estado,
                  onChanged: (v) => setState(() => _estado = v),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _guardar,
                  icon: const Icon(Icons.save),
                  label: const Text('Guardar tarea'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
