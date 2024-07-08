import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

import 'models/usuario_model.dart';

Future<Usuario> BuscarUsuarioCarteira(String matricula) async {
  final response = await http.get(
    Uri.parse('http://10.0.2.2:8080/api/usuarios/matricula/$matricula'),
  );

  if (response.statusCode == 200) {
    return Usuario.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load usuario');
  }
}
