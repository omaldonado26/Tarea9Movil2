import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ListarTareasTab extends StatelessWidget {
  const ListarTareasTab({super.key});

  CollectionReference get col =>
      FirebaseFirestore.instance.collection('tareas');

  Future<void> _toggleEstado(DocumentSnapshot doc) async {
    final d = doc.data() as Map<String, dynamic>;
    final actual = (d['estado'] is bool)
        ? d['estado'] as bool
        : (d['estado'] == 1);
    await col.doc(doc.id).update({'estado': !actual});
  }

  Future<void> _editarDialog(BuildContext context, DocumentSnapshot doc) async {
    final d = doc.data() as Map<String, dynamic>;
    final titulo = TextEditingController(text: (d['titulo'] ?? '').toString());
    final desc = TextEditingController(
      text: (d['descripcion'] ?? '').toString(),
    );
    final form = GlobalKey<FormState>();

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar tarea'),
        content: Form(
          key: form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: titulo,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: desc,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (form.currentState!.validate()) Navigator.pop(context, true);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (ok == true) {
      await col.doc(doc.id).update({
        'titulo': titulo.text.trim(),
        'descripcion': desc.text.trim(),
      });
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Tarea actualizada')));
      }
    }
  }

  Future<void> _eliminar(BuildContext context, DocumentSnapshot doc) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Eliminar tarea?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await col.doc(doc.id).delete();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Tarea eliminada')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: col.orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(child: Text('Error: ${snap.error}'));
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snap.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Text('No hay tareas registradas.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final doc = docs[i];
            final d = doc.data() as Map<String, dynamic>;
            final titulo = (d['titulo'] ?? '').toString();
            final desc = (d['descripcion'] ?? '').toString();
            final estado = (d['estado'] is bool)
                ? d['estado'] as bool
                : (d['estado'] == 1);

            return Card(
              child: ListTile(
                leading: IconButton(
                  tooltip: estado
                      ? 'Completada (tocar para marcar pendiente)'
                      : 'Pendiente (tocar para completar)',
                  icon: Icon(
                    estado ? Icons.check_circle : Icons.warning_amber_rounded,
                    color: estado ? Colors.green : Colors.red,
                  ),
                  onPressed: () => _toggleEstado(doc),
                ),
                title: Text(
                  titulo,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(desc),
                trailing: Wrap(
                  spacing: 8,
                  children: [
                    IconButton(
                      tooltip: 'Editar',
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _editarDialog(context, doc),
                    ),
                    IconButton(
                      tooltip: 'Eliminar',
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _eliminar(context, doc),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
