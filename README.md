# App Multimedia
2
 
3
Aplicación desarrollada en Flutter para el Taller 01 de la asignatura Profesional Complementaria II del programa de Ingeniería Multimedia. La aplicación integra tres funcionalidades principales: reproducción de video, visualización de imágenes y navegación web mediante una interfaz basada en BottomNavigationBar. 【1-bb9139】
4
 
5
## Autor
6
 
7
**Sergio Luis Durango Banquez**
8
 
9
## Funcionalidades
10
 
11
- Navegación mediante BottomNavigationBar.
12
- Visualización de imágenes utilizando GridView.builder.
13
- Reproducción de video mediante el paquete video_player.
14
- Navegación web utilizando webview_flutter.
15
- Conservación del estado de las vistas mediante IndexedStack.
16
- Estructura modular del proyecto para facilitar el mantenimiento y la escalabilidad.
17
 
18
## Tecnologías Utilizadas
19
 
20
- Flutter
21
- Dart
22
- video_player
23
- webview_flutter
24
 
25
## Estructura del Proyecto
26
 
27
```text
28
lib/
29
├── main.dart
30
└── screens/
31
├── main_navigator.dart
32
├── image_screen.dart
33
├── video_screen.dart
34
└── web_screen.dart
35
```
36
 
37
## Instalación y Ejecución
38
 
39
1. Clonar el repositorio:
40
 
41
```bash
42
git clone https://github.com/sldurangob/taller-app-multimedia.git
43
```
44
 
45
2. Ingresar al directorio del proyecto:
46
 
47
```bash
48
cd taller-app-multimedia
49
```
50
 
51
3. Instalar dependencias:
52
 
53
```bash
54
flutter pub get
55
```
56
 
57
4. Ejecutar la aplicación:
58
 
59
```bash
60
flutter run
61
```
62
 
63
## Capturas de Pantalla
64
 
65
### Vista de Video
66
 
67
screenshots/video.jpeg
68
 
69
### Vista de Imágenes
70
 
71
screenshots/imagenes.jpeg
72
 
73
### Vista Web
74
 
75
screenshots/web.jpeg
76
 
77
## APK
78
 
79
El archivo APK compilado se encuentra disponible en la sección **Releases** del repositorio de GitHub, de acuerdo con los requerimientos del taller. 【1-bb9139】
80
 
81
## Repositorio
82
 
83
Repositorio oficial del proyecto:
84
 
85
https://github.com/sldurangob/taller-app-multimedia
86
 
87
## Objetivo Académico
88
 
89
Este proyecto fue desarrollado como evidencia práctica para el 01 - Taller - APP Multimedia.pdf, aplicando conceptos de navegación, integración multimedia, modularización del código y uso de dependencias oficiales de Flutter. 【1-bb9139