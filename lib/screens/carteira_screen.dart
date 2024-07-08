import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:projeto_pdm/db_helper.dart';
import 'package:projeto_pdm/models/usuario_model.dart';

class CarteiraScreen extends StatefulWidget {
  CarteiraScreen();

  @override
  State<CarteiraScreen> createState() => _CarteiraScreenState();
}

class _CarteiraScreenState extends State<CarteiraScreen> {
  Usuario? _usuario;
  File? _image;
  final picker = ImagePicker();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsuario();
  }

  Future<void> _loadUsuario() async {
    setState(() {
      _isLoading = true;
      _image = null; // Resetar a imagem ao carregar novo usuário
    });
    DBHelper dbHelper = DBHelper();
    List<Usuario> usuarios = await dbHelper.getUsuarios();

    if (usuarios.isNotEmpty) {
      _usuario = usuarios.first;
      if (_usuario!.fotoPerfil != null && _usuario!.fotoPerfil!.isNotEmpty) {
        _image = await _writeToFile(
            Uint8List.fromList(_usuario!.fotoPerfil!), 'user_profile_image_${_usuario!.id}.png');
      }
    } else {
      _usuario = null;
    }
    setState(() {
      _isLoading = false; // Marca o carregamento como completo
    });
  }

  Future<File> _writeToFile(Uint8List data, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    return file.writeAsBytes(data);
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final File temporaryImage = File(pickedFile.path);
      final bool shouldSave = await _showPreviewDialog(temporaryImage);
      if (shouldSave) {
        if (await _updateProfilePicture(temporaryImage)) {
          setState(() {
            _image = temporaryImage;
          });
        }
      }
    }
  }

  Future<bool> _updateProfilePicture(File temporaryImage) async {
    if (_usuario == null || temporaryImage == null) return false;

    try {
      Uint8List imageBytes = await temporaryImage.readAsBytes();
      Usuario updatedUser = Usuario(
        id: _usuario?.id,
        matricula: _usuario?.matricula,
        nome: _usuario?.nome,
        senha: _usuario?.senha,
        curso: _usuario?.curso,
        validade: _usuario?.validade,
        dataInscricao: _usuario?.dataInscricao,
        fotoPerfil: imageBytes,
      );

      String url = 'http://10.0.2.2:8080/api/usuarios/carteira/atualizarfoto';
      var response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(updatedUser.toJson()),
      );

      if (response.statusCode == 201) {
        print("Foto do usuário atualizada com sucesso!");
        DBHelper dbHelper = DBHelper();
        await dbHelper.updateUsuario(updatedUser);
        print("Usuário atualizado no banco local com sucesso!");
        return true;
      } else {
        print("Erro ao atualizar a foto do usuário: ${response.body}");
      }
    } catch (e) {
      print("Erro ao enviar a foto: $e");
    }
    return false;
  }

  Future<bool> _showPreviewDialog(File image) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Visualizar Foto'),
          content: Image.file(image),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Não salvar a foto
              },
              child: Text('Descartar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Salvar a foto
              },
              child: Text('Salvar'),
            ),
          ],
        );
      },
    ) ?? false; // Retorna false se o diálogo for fechado sem selecionar uma opção
  }

  void _logout(BuildContext context) async {
    await DBHelper().deleteLogin();
    await DBHelper().deleteUsuarios();
    setState(() {
      _usuario = null; // Limpa completamente o usuário
      _image = null; // Limpa a imagem ao fazer logout
      _isLoading = true; // Reseta o estado de carregamento para exibir o indicador novamente
    });
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _showProfilePictureDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.7,
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _image != null
                  ? Image.file(
                _image!,
                fit: BoxFit.contain,
              )
                  : Image.asset(
                'lib/assets/images/perfil_generico.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'lib/assets/images/icon_logo.png',
              height: 40,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Associação do Colégio Politécnico',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _usuario != null
          ? SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap: _showProfilePictureDialog,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _image == null
                            ? AssetImage(
                            'lib/assets/images/perfil_generico.png')
                            : FileImage(_image!) as ImageProvider,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _pickImage,
                        child: Text(
                          'Alterar Foto',
                          style: TextStyle(
                              color: Colors.blue, fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  _buildInfoRow(
                      'Matrícula:', _usuario!.matricula ?? ''),
                  _buildInfoRow('Nome:', _usuario!.nome ?? ''),
                  _buildInfoRow('Curso:', _usuario!.curso ?? ''),
                  _buildInfoRow(
                      'Validade:', _usuario!.validade ?? ''),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      )
          : Center(
        child: Text('Nenhum usuário encontrado.'),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
