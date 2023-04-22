import 'package:flutter/material.dart';
import 'package:taxi_driver/screens/home_screen.dart';
import 'package:taxi_driver/screens/login_screen.dart';
import 'package:taxi_driver/screens/journey_list_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

final Future<FirebaseApp> firebase = Firebase.initializeApp();
final auth = FirebaseAuth.instance;

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: firebase,
        builder: ((context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(),
              body: Center(
                child: Text("${snapshot.error}"),
              ),
            );
          } else if (snapshot.connectionState == ConnectionState.done) {
            if (auth.currentUser == null) {
              return const LoginScreen();
            } else if (auth.currentUser != null) {
              return const HomeScreen();
            }
          }

          return Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 10,
              ),
            ),
          );
        }));
  }
}
