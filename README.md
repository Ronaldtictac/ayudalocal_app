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

### 3. Configurar variables de entorno (opcional)

Si tu contraseña de PostgreSQL no es `unaClave`, crea el archivo `server/.env`:

```bash
cp server/.env.example server/.env
```

Edita `server/.env` con tus credenciales:

```
DB_HOST=localhost
DB_NAME=ayudalocal_db
DB_USER=postgres
DB_PASS=tu_contrasena_aqui
```

### 4. Instalar dependencias

```bash
cd server && dart pub get && cd ..
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

## Notas importantes

### Android Emulator
La app detecta automaticamente si esta corriendo en un emulador Android y usa `10.0.2.2` en vez de `localhost` para comunicarse con el servidor.

### iOS Simulator / Web / Desktop
Usa `localhost:8080` normalmente.

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
│   ├── .env.example       # Ejemplo de variables de entorno
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
- Verifica credenciales en `server/.env` o `server/main.dart`

**Error de puertos:**
- Asegurate de que el puerto 8080 este libre
- En Android emulator se usa automaticamente `10.0.2.2:8080`

**Error de internet en Android:**
- Verifica que `AndroidManifest.xml` tenga el permiso `<uses-permission android:name="android.permission.INTERNET"/>`
