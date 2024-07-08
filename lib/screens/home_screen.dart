import 'package:flutter/material.dart';
import '../db_helper.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    _checkLoginStatus(context);
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }

  void _checkLoginStatus(BuildContext context) async {
    var loginData = await DBHelper().getLogin();
    if (loginData != null) {
      Navigator.pushReplacementNamed(context, '/carteira');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
}
