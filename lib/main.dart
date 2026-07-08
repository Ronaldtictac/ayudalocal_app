/// Pantalla principal de la app "Servicios Generales".
///
/// Muestra la lista de servicios/órdenes de trabajo registrados,
/// con opciones para crear, editar y eliminar servicios.
///
/// Arquitectura:
/// - [ServicioService]: se encarga de la comunicación HTTP con el backend.
/// - [Servicio]: modelo de datos que representa un servicio.
/// - [HomeServicios]: pantalla principal con la lista de servicios.
library;

import 'package:flutter/material.dart';
import 'servicio_model.dart';
import 'servicio_service.dart';

void main() {
  runApp(const MyApp());
}

/// Widget raíz de la aplicación.
///
/// Configura el tema Material3 y establece la pantalla inicial.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Servicios Generales',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeServicios(),
    );
  }
}

/// Pantalla principal que muestra la lista de servicios.
///
/// Utiliza un [FutureBuilder] para cargar y mostrar los servicios
/// desde el backend de forma asíncrona. Permite realizar
/// operaciones CRUD a través de botones en cada elemento de la lista.
class HomeServicios extends StatefulWidget {
  const HomeServicios({super.key});

  @override
  State<HomeServicios> createState() => _HomeServiciosState();
}

class _HomeServiciosState extends State<HomeServicios> {
  final ServicioService _service = ServicioService();
  late Future<List<Servicio>> _futureServicios;

  @override
  void initState() {
    super.initState();
    _actualizarLista();
  }

  /// Recarga la lista de servicios desde el backend.
  ///
  /// Actualiza el [_futureServicios] para que el [FutureBuilder]
  /// vuelva a ejecutar la petición y refresque la UI.
  void _actualizarLista() {
    setState(() {
      _futureServicios = _service.obtenerServicios();
    });
  }

  /// Muestra un formulario en un [ModalBottomSheet] para crear o editar un servicio.
  ///
  /// Si se pasa un [servicio], el formulario se carga con sus datos
  /// para edición. Si no se pasa, se muestra vacío para crear uno nuevo.
  ///
  /// El formulario contiene campos para: cliente, descripción, precio y estado.
  /// Al enviar, se llama al backend para crear o actualizar el registro.
  void _mostrarFormulario({Servicio? servicio}) {
    final esEdicion = servicio != null;
    final clienteCtrl = TextEditingController(text: servicio?.cliente ?? '');
    final descCtrl = TextEditingController(text: servicio?.descripcionServicio ?? '');
    final precioCtrl = TextEditingController(text: servicio?.precio.toString() ?? '');
    String estado = servicio?.estado ?? 'Pendiente';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16, right: 16, top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    esEdicion ? 'Editar Servicio' : 'Nuevo Servicio',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: clienteCtrl,
                    decoration: const InputDecoration(labelText: 'Cliente', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descCtrl,
                    decoration: const InputDecoration(labelText: 'Descripción', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: precioCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Precio', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: estado,
                    decoration: const InputDecoration(labelText: 'Estado', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'Pendiente', child: Text('Pendiente')),
                      DropdownMenuItem(value: 'En proceso', child: Text('En proceso')),
                      DropdownMenuItem(value: 'Terminado', child: Text('Terminado')),
                    ],
                    onChanged: (value) {
                      if (value != null) setModalState(() => estado = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        // Capturar referencias antes de la operación async
                        final navigator = Navigator.of(context);
                        final messenger = ScaffoldMessenger.of(context);

                        final nuevo = Servicio(
                          id: servicio?.id,
                          cliente: clienteCtrl.text,
                          descripcionServicio: descCtrl.text,
                          precio: double.tryParse(precioCtrl.text) ?? 0,
                          estado: estado,
                        );

                        bool exito;
                        if (esEdicion) {
                          exito = await _service.actualizarServicio(nuevo.id!, nuevo);
                        } else {
                          exito = await _service.crearServicio(nuevo);
                        }

                        if (!mounted) return;
                        navigator.pop();
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(exito
                                ? (esEdicion ? 'Servicio actualizado' : 'Servicio creado')
                                : 'Error al guardar'),
                            backgroundColor: exito ? Colors.green : Colors.red,
                          ),
                        );
                        if (exito) _actualizarLista();
                      },
                      child: Text(esEdicion ? 'Actualizar' : 'Crear'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Muestra un diálogo de confirmación antes de eliminar un servicio.
  ///
  /// Si el usuario confirma, se envía la petición DELETE al backend
  /// y se refresca la lista si la eliminación fue exitosa.
  void _confirmarEliminar(Servicio servicio) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar servicio'),
        content: Text('¿Eliminar el servicio de ${servicio.cliente}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);
              bool eliminado = await _service.eliminarServicio(servicio.id!);
              if (!mounted) return;
              messenger.showSnackBar(
                SnackBar(
                  content: Text(eliminado ? 'Servicio eliminado' : 'Error al eliminar'),
                  backgroundColor: eliminado ? Colors.green : Colors.red,
                ),
              );
              if (eliminado) _actualizarLista();
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Servicios Generales - Gestión de Órdenes'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _actualizarLista),
        ],
      ),
      body: FutureBuilder<List<Servicio>>(
        future: _futureServicios,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}\n\n*Verifica que el backend esté encendido.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay servicios registrados.'));
          }

          final servicios = snapshot.data!;
          return ListView.builder(
            itemCount: servicios.length,
            itemBuilder: (context, index) {
              final item = servicios[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: item.estado == 'Terminado' ? Colors.green : Colors.orange,
                    child: const Icon(Icons.build, color: Colors.white, size: 20),
                  ),
                  title: Text(item.cliente, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${item.descripcionServicio}\nPrecio: \$${item.precio}'),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blueAccent),
                        onPressed: () => _mostrarFormulario(servicio: item),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _confirmarEliminar(item),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormulario(),
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
