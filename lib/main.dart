import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:projeto_pdm/models/usuario_model.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/carteira_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/login': (context) => LoginScreen(),
        '/carteira': (context) => CarteiraScreen(),
      },
    );
  }
}
