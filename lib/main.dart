import 'package:flutter/material.dart';
import 'screens/main_navigator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Definición de paleta de colores Teal / Verde Esmeralda
    const primaryColor = Color(0xFF00695C); // Teal oscuro
    const accentColor = Color(0xFF26A69A);  // Teal medio/claro
    const backgroundColor = Color(0xFFF0F4F4); // Fondo gris verdoso muy claro

    return MaterialApp(
      title: 'Aplicación Multimedia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: backgroundColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          secondary: accentColor,
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: primaryColor,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white60,
        ),
      ),
      home: const MainNavigator(),
    );
  }
}