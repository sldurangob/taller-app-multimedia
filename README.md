# App Multimedia

Aplicación Flutter desarrollada para el Taller 02 de Ingeniería Multimedia por Sergio Luis Durango Banquez

## Funcionalidades

- Navegación mediante BottomNavigationBar.
- Reproducción de video con video_player.
- Galería de imágenes con GridView.builder.
- Navegador web embebido con webview_flutter.
- Uso de IndexedStack para conservar el estado de las vistas.

## Estructura

```text
lib/
├── main.dart
└── screens/
    ├── main_navigator.dart
    ├── image_screen.dart
    ├── video_screen.dart
    └── web_screen.dart
```

## Ejecución

```bash
flutter pub get
flutter run
```

## Capturas

### Vista de video

![Vista de video](screenshots/video.png)

### Vista de imágenes

![Vista de imágenes](screenshots/imagenes.png)

### Vista web

![Vista web](screenshots/web.png)
