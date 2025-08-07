import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ListadoProductosTab extends StatelessWidget {
  final String dia;
  const ListadoProductosTab({super.key, required this.dia});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('productos')
          .where('dia', isEqualTo: dia)
          .orderBy('fechaRegistro', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Center(child: Text('No hay productos para este día.'));
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;

            return ListTile(
              leading: (data['imagen'] != null && data['imagen'] != '')
                  ? Image.network(
                      data['imagen'],
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.image_not_supported),
              title: Text(data['nombre'] ?? 'Sin nombre'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data['descripcion'] ?? 'Sin descripción'),
                  Text('L ${data['precio'] ?? '0.00'}'),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
