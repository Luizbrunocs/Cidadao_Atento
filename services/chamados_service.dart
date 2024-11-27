import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

class ChamadosService {
  static const String url = "http://192.168.0.19:3000/";
  static const String resource = "learnhttp/";

  final Logger _logger = Logger('ChamadosService');

  ChamadosService() {
    _setupLogging();
  }

  void _setupLogging() {
    Logger.root.level = Level.ALL;  // Configura o nível de log (use Level.INFO para produção)
    Logger.root.onRecord.listen((record) {
      ('${record.level.name}: ${record.time}: ${record.message}');
    });
  }

  Uri getURI() {
    return Uri.parse("$url$resource");
  }

  Future<void> register(String content) async {
    try {
      final response = await http.post(
        getURI(),
        body: jsonEncode({'content': content}),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        _logger.info("Registro bem-sucedido: ${response.body}");
      } else {
        _logger.warning("Erro ao registrar: ${response.statusCode}");
      }
    } catch (error) {
      _logger.severe("Erro de rede: $error");
    }
  }

  Future<void> get() async {
    try {
      final response = await http.get(getURI());

      if (response.statusCode == 200) {
        _logger.info("Dados obtidos: ${response.body}");
      } else {
        _logger.warning("Erro ao obter dados: ${response.statusCode}");
      }
    } catch (error) {
      _logger.severe("Erro de rede: $error");
    }
  }
}
