import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_options.dart';
import 'agregar_productos_tab.dart';
import 'ListaProductosTab.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  String? token = await messaging.getToken();
  print('🔥 Token Firebase: $token');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestión de Productos por Día',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  final List<String> dias = const [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: dias.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gestión de Productos'),
          bottom: TabBar(
            isScrollable: true,
            tabs: dias.map((dia) => Tab(text: dia)).toList(),
          ),
        ),
        body: TabBarView(
          children: dias.map((dia) {
            return Column(
              children: [
                Expanded(child: ListadoProductosTab(dia: dia)),
                const Divider(),
                AgregarProductosTab(dia: dia),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
