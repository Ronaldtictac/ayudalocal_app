/// Servicio de comunicación HTTP con el backend REST.
///
/// Proporciona las operaciones CRUD (Crear, Leer, Actualizar, Eliminar)
/// para gestionar los servicios/órdenes de trabajo a través de la API.
///
/// Se comunica con el servidor en `http://localhost:8080/servicios`
/// usando peticiones HTTP con formato JSON.
library;

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'servicio_model.dart';

class ServicioService {
  /// En Android emulator, localhost apunta al emulador, no al host.
  /// Se usa 10.0.2.2 para acceder al localhost de la PC host.
  final String baseUrl = defaultTargetPlatform == TargetPlatform.android
      ? 'http://10.0.2.2:8080/servicios'
      : 'http://localhost:8080/servicios';

  /// Obtiene la lista de todos los servicios registrados en el backend.
  ///
  /// Retorna una lista de objetos [Servicio] decodificados desde JSON.
  /// Lanza una [Exception] si no se puede conectar al servidor
  /// o si la respuesta no es exitosa (código 200).
  Future<List<Servicio>> obtenerServicios() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => Servicio.fromMap(item)).toList();
      } else {
        throw Exception('Error al cargar servicios desde el servidor');
      }
    } catch (e) {
      throw Exception('No se pudo conectar al backend: $e');
    }
  }

  /// Envía un nuevo servicio al backend para ser almacenado.
  ///
  /// Retorna `true` si la creación fue exitosa (código 200),
  /// `false` en caso contrario o si ocurre un error de conexión.
  Future<bool> crearServicio(Servicio servicio) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(servicio.toMap()),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Actualiza un servicio existente en el backend por su [id].
  ///
  /// Retorna `true` si la actualización fue exitosa (código 200),
  /// `false` en caso contrario o si ocurre un error de conexión.
  Future<bool> actualizarServicio(int id, Servicio servicio) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(servicio.toMap()),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Elimina un servicio del backend por su [id].
  ///
  /// Retorna `true` si la eliminación fue exitosa (código 200),
  /// `false` en caso contrario o si ocurre un error de conexión.
  Future<bool> eliminarServicio(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
