# AyudaLocal App

Aplicacion Flutter para gestion de servicios generales con backend en Dart y PostgreSQL.

## Requisitos previos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable)
- [Dart SDK](https://dart.dev/get-dart) (incluido con Flutter)
- [PostgreSQL](https://www.postgresql.org/download/) instalado y corriendo

## Instalacion

### 1. Clonar el repositorio

```bash
git clone https://github.com/Ronaldtictac/ayudalocal_app.git
cd ayudalocal_app
```

### 2. Configurar la base de datos

```bash
psql -U postgres -f server/setup.sql
```

Esto creara:
- La base de datos `ayudalocal_db`
- La tabla `servicios`
- Datos de ejemplo

> **Nota:** Si tu contraseña de postgres no es `unaClave`, edita `server/main.dart` linea 26 y cambiala.

### 3. Instalar dependencias del servidor

```bash
cd server
dart pub get
cd ..
```

### 4. Instalar dependencias de la app Flutter

```bash
flutter pub get
```

### 5. Ejecutar el servidor

```bash
cd server
dart run main.dart
```

El servidor estara disponible en `http://localhost:8080`

### 6. Ejecutar la app Flutter

En otra terminal:

```bash
flutter run
```

## Estructura del proyecto

```
ayudalocal_app/
├── lib/                    # Codigo Flutter (Dart)
│   ├── main.dart          # Pantalla principal
│   ├── servicio_model.dart # Modelo de datos
│   └── servicio_service.dart # Servicio API
├── server/                 # Backend Dart
│   ├── main.dart          # Servidor REST
│   ├── setup.sql          # Script de BD
│   └── pubspec.yaml       # Dependencias del servidor
├── android/               # Configuracion Android
├── web/                   # Configuracion Web
├── linux/                 # Configuracion Linux
└── windows/               # Configuracion Windows
```

## API Endpoints

| Metodo | Ruta | Descripcion |
|--------|------|-------------|
| GET | /servicios | Lista todos los servicios |
| POST | /servicios | Crea un nuevo servicio |
| PUT | /servicios/:id | Actualiza un servicio |
| DELETE | /servicios/:id | Elimina un servicio |

## Solucion de problemas

**Error de conexion a PostgreSQL:**
- Verifica que PostgreSQL este corriendo: `sudo systemctl status postgresql`
- Verifica credenciales en `server/main.dart` linea 22-28

**Error de puertos:**
- Asegurate de que el puerto 8080 este libre
- Si usas emulador Android, usa `10.0.2.2:8080` en vez de `localhost:8080`
