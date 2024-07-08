import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/usuario_model.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;

  static Database? _database;

  DBHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'usuarios.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE usuarios(id INTEGER PRIMARY KEY AUTOINCREMENT, matricula TEXT, senha TEXT, nome TEXT, curso TEXT, validade TEXT, dataInscricao TEXT, fotoPerfil BLOB)',
        );
        await db.execute(
          'CREATE TABLE login(id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT, password TEXT)',
        );
      },
    );
  }

  Future<void> insertUsuario(Usuario usuario) async {
    final db = await database;
    await db.insert(
      'usuarios',
      usuario.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Usuario>> getUsuarios() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('usuarios');
    return List.generate(maps.length, (i) {
      return Usuario(
        id: maps[i]['id'],
        matricula: maps[i]['matricula'],
        senha: maps[i]['senha'],
        nome: maps[i]['nome'],
        curso: maps[i]['curso'],
        validade: maps[i]['validade'],
        dataInscricao: DateTime.parse(maps[i]['dataInscricao']),
        fotoPerfil: maps[i]['fotoPerfil'] != null ? base64Decode(maps[i]['fotoPerfil']) : Uint8List(0),
      );
    });
  }

  Future<void> updateUsuario(Usuario usuario) async {
    final db = await database;
    await db.update(
      'usuarios',
      usuario.toMap(),
      where: 'id = ?',
      whereArgs: [usuario.id],
    );
  }

  Future<void> deleteUsuario(int id) async {
    final db = await database;
    await db.delete(
      'usuarios',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  Future<int> deleteUsuarios() async {
    Database db = await database;
    return await db.delete('usuarios');
  }

  Future<int> saveLogin(String username, String password) async {
    Database db = await database;
    return await db.insert('login', {'username': username, 'password': password});
  }

  Future<Map<String, dynamic>?> getLogin() async {
    Database db = await database;
    try {
      List<Map<String, dynamic>> result = await db.query('login');
      if (result.isNotEmpty) {
        return result.first;
      }
      return null;
    } catch (e) {
      await db.execute(
        'CREATE TABLE IF NOT EXISTS login(id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT, password TEXT)',
      );
      return null;
    }
  }

  Future<int> deleteLogin() async {
    Database db = await database;
    return await db.delete('login');
  }
}
