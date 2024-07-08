import 'dart:io';
import 'dart:typed_data';

File byteArrayToFile(Uint8List bytes, String fileName) {
  // Obter o diretório de armazenamento temporário (ou outro diretório desejado)
  Directory tempDir = Directory.systemTemp; // Diretório temporário do sistema
  String filePath = '${tempDir.path}/$fileName';

  // Escrever os bytes no arquivo
  File file = File(filePath);
  //file.writeAsBytesSync(bytes);

  return file;
}
