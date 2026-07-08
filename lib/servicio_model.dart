/// Modelo de datos que representa un servicio/orden de trabajo.
///
/// Contiene la información básica de un servicio registrado en el sistema:
/// cliente, descripción, precio y estado de la orden.
///
/// Este modelo se utiliza tanto en el app Flutter (cliente) como
/// en el servidor (backend) para transportar datos entre ambas capas.
class Servicio {
  final int? id;
  final String cliente;
  final String descripcionServicio;
  final double precio;
  final String estado;

  Servicio({
    this.id,
    required this.cliente,
    required this.descripcionServicio,
    required this.precio,
    required this.estado,
  });

  /// Convierte un mapa JSON proveniente del backend a un objeto [Servicio].
  ///
  /// Se espera que el mapa tenga las claves:
  /// `id`, `cliente`, `descripcion_servicio`, `precio`, `estado`.
  ///
  /// El campo `precio` se parsea de String a Double ya que
  /// el backend lo retorna como texto.
  factory Servicio.fromMap(Map<String, dynamic> map) {
    return Servicio(
      id: map['id'] as int?,
      cliente: map['cliente'] as String,
      descripcionServicio: map['descripcion_servicio'] as String,
      precio: double.tryParse(map['precio'].toString()) ?? 0.0,
      estado: map['estado'] as String,
    );
  }

  /// Convierte el objeto [Servicio] a un mapa JSON para enviarlo al backend.
  ///
  /// Las claves coinciden con los nombres de columnas en la base de datos.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cliente': cliente,
      'descripcion_servicio': descripcionServicio,
      'precio': precio,
      'estado': estado,
    };
  }
}
