import 'package:agrosync/core/di/injection_container.dart' as di;
import 'package:agrosync/features/plants/presentation/bloc/plant_bloc.dart';
import 'package:agrosync/models/plant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/users/apresentation/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'core/services/rbac_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBhDSbpaQfmRkyRc1t7ph5R5mUhx-Z4BJ4",
        authDomain: "agro-oversight.firebaseapp.com",
        databaseURL: "https://agro-oversight-default-rtdb.firebaseio.com/",
        projectId: "agro-oversight",
        storageBucket: "agro-oversight.appspot.com",
        messagingSenderId: "603925781655",
        appId: "1:603925781655:web:f2571b9241808e3228ddd2",
      ),
    );
    // Seed RBAC collections/assignments (idempotent)
    await seedRbac(FirebaseFirestore.instance);
  } catch (e) {
    print('Erro ao inicializar o Firebase: $e');
  }  
  try {
    await Hive.initFlutter();
    Hive.registerAdapter(PlantAdapter());
    final box = await Hive.openBox('plant_box');
    print("Dados no Hive após inicialização: ${box.values.toList()}");
    // Open metadata cache box as well
    await Hive.openBox('plant_meta_box');
  } catch (e) {
    print('Erro ao inicializar o Hive: $e');
  }
  
  // Initialize dependency injection
  await di.init();
  
  runApp(const AgroControlApp());
}

class AgroControlApp extends StatelessWidget {
  const AgroControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PlantBloc>(
          create: (_) => di.sl<PlantBloc>(),
        ),
      ],
      child: MaterialApp(
        home: LoginScreen(),
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
      ),
    );
  }
}

void limparHive() async {
  try {
    final box = Hive.box('plant_box');
    await box.clear();
    print("Hive limpo com sucesso!");
  } catch (e) {
    print("Erro ao limpar o Hive: $e");
  }
}

