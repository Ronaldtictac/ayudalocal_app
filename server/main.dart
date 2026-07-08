/// Servidor backend para la app "Servicios Generales".
///
/// Expone una API REST en el puerto 8080 con los endpoints:
/// - GET    /servicios       → Lista todos los servicios
/// - POST   /servicios       → Crea un nuevo servicio
/// - PUT    /servicios/<id>  → Actualiza un servicio existente
/// - DELETE /servicios/<id>  → Elimina un servicio
///
/// Conecta a PostgreSQL para persistir los datos.
/// Incluye middleware CORS para permitir peticiones desde el app Flutter.
///
/// Para ejecutar: cd server && dart run main.dart
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:postgres/postgres.dart';
import 'package:shelf/shelf_io.dart' as io;

void main() async {
  // Conexión a la base de datos PostgreSQL
  final conn = await Connection.open(
    Endpoint(
      host: 'localhost',
      database: 'ayudalocal_db',
      username: 'postgres',
      password: 'unaClave',
    ),
    settings: ConnectionSettings(sslMode: SslMode.disable),
  );

  print(' Conexion exitosa a PostgreSQL!');

  final router = Router();

  // ─── GET /servicios ──────────────────────────────────────────────
  // Retorna la lista completa de servicios almacenados en la BD.
  router.get('/servicios', (Request request) async {
    try {
      final result = await conn.execute(
        'SELECT id, cliente, descripcion_servicio, precio, estado FROM servicios',
      );

      // Convertir cada fila de la BD a un mapa JSON
      final listaServicios = result.map((row) => {
        'id': row[0],
        'cliente': row[1],
        'descripcion_servicio': row[2],
        'precio': row[3].toString(),
        'estado': row[4],
      }).toList();

      return Response.ok(
        jsonEncode(listaServicios),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(body: 'Error en el servidor: $e');
    }
  });

  // ─── POST /servicios ─────────────────────────────────────────────
  // Crea un nuevo servicio con los datos enviados en el body.
  // Retorna el ID generado por la base de datos.
  router.post('/servicios', (Request request) async {
    try {
      final payload = await request.readAsString();
      final data = jsonDecode(payload);

      final result = await conn.execute(
        Sql.named(
          'INSERT INTO servicios (cliente, descripcion_servicio, precio, estado) '
          'VALUES (@cliente, @descripcion, @precio, @estado) '
          'RETURNING id',
        ),
        parameters: {
          'cliente': data['cliente'],
          'descripcion': data['descripcion_servicio'],
          'precio': double.parse(data['precio'].toString()),
          'estado': data['estado'] ?? 'Pendiente',
        },
      );

      return Response.ok(
        jsonEncode({'mensaje': 'Servicio creado con exito', 'id': result.first.first}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(body: 'Error al crear servicio: $e');
    }
  });

  // ─── PUT /servicios/<id> ─────────────────────────────────────────
  // Actualiza un servicio existente identificado por su [id].
  router.put('/servicios/<id>', (Request request, String id) async {
    try {
      final payload = await request.readAsString();
      final data = jsonDecode(payload);

      await conn.execute(
        Sql.named(
          'UPDATE servicios '
          'SET cliente = @cliente, descripcion_servicio = @descripcion, '
          'precio = @precio, estado = @estado '
          'WHERE id = @id',
        ),
        parameters: {
          'cliente': data['cliente'],
          'descripcion': data['descripcion_servicio'],
          'precio': double.parse(data['precio'].toString()),
          'estado': data['estado'],
          'id': int.parse(id),
        },
      );

      return Response.ok(
        jsonEncode({'mensaje': 'Servicio actualizado correctamente'}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(body: 'Error al actualizar: $e');
    }
  });

  // ─── DELETE /servicios/<id> ──────────────────────────────────────
  // Elimina un servicio de la BD por su [id].
  router.delete('/servicios/<id>', (Request request, String id) async {
    try {
      await conn.execute(
        Sql.named('DELETE FROM servicios WHERE id = @id'),
        parameters: {'id': int.parse(id)},
      );

      return Response.ok(
        jsonEncode({'mensaje': 'Servicio eliminado correctamente'}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(body: 'Error al eliminar: $e');
    }
  });

  // ─── Middleware CORS ─────────────────────────────────────────────
  // Agrega los headers CORS necesarios para que el app Flutter
  // (que corre en un navegador o emulador) pueda comunicarse con este servidor.

  /// Agrega headers CORS a la respuesta para permitir peticiones cross-origin.
  Response addCorsHeaders(Response response) {
    final headers = Map<String, String>.from(response.headers);
    headers['Access-Control-Allow-Origin'] = '*';
    headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS';
    headers['Access-Control-Allow-Headers'] = 'Content-Type';
    return Response(response.statusCode, body: response.read(), headers: headers);
  }

  // Pipeline de middlewares: logging + CORS
  final pipeline = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware((handler) {
    return (request) async {
      // Responder directamente a peticiones OPTIONS (preflight CORS)
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type',
        });
      }
      final response = await handler(request);
      return addCorsHeaders(response);
    };
  }).addHandler(router.call);

  // Iniciar el servidor en el puerto 8080
  final server = await io.serve(pipeline, '0.0.0.0', 8080);
  print('Servidor escuchando en http://${server.address.host}:${server.port}');
}
