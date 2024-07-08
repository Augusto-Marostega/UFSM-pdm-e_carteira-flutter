import 'dart:convert';
import 'dart:typed_data';

class Usuario {
  final int? id;
  final String? matricula;
  final String? senha;
  final String? nome;
  final String? curso;
  final String? validade;
  final DateTime? dataInscricao;
  late Uint8List? fotoPerfil;

  Usuario({
    required this.id,
    required this.matricula,
    required this.senha,
    required this.nome,
    required this.curso,
    required this.validade,
    required this.dataInscricao,
    required this.fotoPerfil,
  });

  factory Usuario.empty() {
    return Usuario(
      id: 0,
      matricula: '',
      senha: '',
      nome: '',
      curso: '',
      validade: '',
      dataInscricao: DateTime.now(),
      fotoPerfil: Uint8List(0),
    );
  }

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      matricula: json['matricula'],
      senha: json['senha'] ?? '',
      nome: json['nome'],
      curso: json['curso'] ?? '',
      validade: json['validade'] ?? '',
      dataInscricao: json['dataInscricao'] != null ? DateTime.parse(json['dataInscricao']) : null,
      fotoPerfil: json['fotoPerfil'] != null ? base64Decode(json['fotoPerfil']) : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'matricula': matricula,
      'nome': nome,
      'senha': senha,
      'curso': curso,
      'validade': validade,
      'dataInscricao': dataInscricao?.toIso8601String(),
      'fotoPerfil': fotoPerfil != null ? base64Encode(fotoPerfil!) : null,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'matricula': matricula,
      'senha': senha,
      'nome': nome,
      'curso': curso,
      'validade': validade,
      'dataInscricao': dataInscricao?.toIso8601String(),
      'fotoPerfil': fotoPerfil != null ? base64Encode(fotoPerfil!) : null,
    };
  }
}
