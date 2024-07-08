import 'package:flutter/material.dart';
import '../buscar_usuario_carteira.dart';
import 'carteira_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:projeto_pdm/db_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _matriculaController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  Future<void> _login() async {
    final String matricula = _matriculaController.text;
    final String senha = _senhaController.text;


    final response = await http.post(
      Uri.parse('http://10.0.2.2:8080/api/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'matricula': _matriculaController.text,
        'senha': _senhaController.text,
      }),
    );
    if (response.statusCode == 200) {
      // Autenticação bem-sucedida
      final usuarioCarteira = await BuscarUsuarioCarteira(_matriculaController.text);

      await DBHelper().saveLogin(_matriculaController.text, _senhaController.text);
      if (usuarioCarteira != null) {
        // Salvar os dados de login localmente
        await DBHelper().saveLogin(_matriculaController.text, _senhaController.text);

        // Navegar para a tela de carteira, passando os dados do usuário
        DBHelper().insertUsuario(usuarioCarteira);
        print(usuarioCarteira.nome);
        Navigator.pushReplacementNamed(context, '/carteira');

      } else {
        showDialog(
          context: context,
          builder: (context) =>
              AlertDialog(
                title: Text("Erro"),
                content: Text("Matrícula ou senha incorretos"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("OK"),
                  ),
                ],
              ),
        );
        // Trate o erro de autenticação
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login falhou')));
      }
    } else if (response.statusCode == 401) {
      showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
              title: Text("Erro"),
              content: Text("Matrícula ou senha incorretos"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("OK"),
                ),
              ],
            ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
              title: Text("Erro"),
              content: Text("Erro desconhecido ao fazer login."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("OK"),
                ),
              ],
            ),
      );
    }
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("E-Carteira Politecnico Login"),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 60.0, bottom: 10),
                child: Center(
                  child: Container(
                    width: 200,
                    height: 150,
                    child: Image.asset('lib/assets/images/login.png'),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: TextFormField(
                  controller: _matriculaController, // Adicione o controlador aqui
                  validator: (valor) {
                    if (valor == null || valor.isEmpty) {
                      return 'Digite uma matrícula válida.';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Matrícula',
                    hintText: 'Digite sua matrícula.',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 15, bottom: 0),
                child: TextFormField(
                  controller: _senhaController, // Adicione o controlador aqui
                  obscureText: true,
                  validator: (valor) {
                    if (valor == null || valor.isEmpty) {
                      return 'Digite uma senha válida.';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Senha',
                    hintText: 'Digite a senha.',
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Implementar tela para "Esqueceu a senha"
                },
                child: const Text(
                  'Esqueceu a Senha ?',
                  style: TextStyle(color: Colors.blue, fontSize: 15),
                ),
              ),
              Container(
                height: 50,
                width: 250,
                decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20)),
                child: TextButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _login();
                    }
                  },
                  child: const Text(
                    'Login',
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
