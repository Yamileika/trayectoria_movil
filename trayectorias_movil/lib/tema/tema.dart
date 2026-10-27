import 'package:flutter/material.dart';

import 'colores.dart';

const fuente = 'NunitoSans';

/// Tema según la guía de estilos: Avenir/Nunito Sans, bordes definidos y
/// botones de 46 px con esquinas de 12 px.
ThemeData crearTema() {
  final esquema = ColorScheme.fromSeed(
    seedColor: Colores.marino,
    primary: Colores.verde,
    onPrimary: Colores.blanco,
    secondary: Colores.marino,
    onSecondary: Colores.blanco,
    tertiary: Colores.turquesa,
    error: Colores.error,
    surface: Colores.blanco,
    onSurface: Colores.marino,
  );
  final esquinas = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));
  const textoBoton = TextStyle(fontFamily: fuente, fontWeight: FontWeight.w700, fontSize: 14);
  OutlineInputBorder borde(Color color, [double ancho = 1]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: color, width: ancho),
  );

  return ThemeData(
    useMaterial3: true,
    fontFamily: fuente,
    colorScheme: esquema,
    scaffoldBackgroundColor: Colores.fondo,
    textTheme: const TextTheme(
      headlineSmall: TextStyle(fontSize: 25, fontWeight: FontWeight.w800, color: Colores.marino),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colores.marino),
      titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colores.marino),
      bodyLarge: TextStyle(fontSize: 14, color: Colores.marino),
      bodyMedium: TextStyle(fontSize: 13, color: Colores.marino, height: 1.45),
      bodySmall: TextStyle(fontSize: 12.5, color: Colores.apoyo, height: 1.4),
      labelLarge: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colores.marino),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Colores.verde,
        foregroundColor: Colores.blanco,
        disabledBackgroundColor: Colores.neutro,
        minimumSize: const Size(48, 46),
        shape: esquinas,
        textStyle: textoBoton,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colores.marino,
        backgroundColor: Colores.blanco,
        minimumSize: const Size(48, 46),
        side: const BorderSide(color: Colores.marino),
        shape: esquinas,
        textStyle: textoBoton,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: Colores.marino, textStyle: textoBoton),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colores.blanco,
      hintStyle: const TextStyle(color: Colores.apoyo),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      border: borde(Colores.bordeCampo),
      enabledBorder: borde(Colores.bordeCampo),
      focusedBorder: borde(Colores.verde, 2),
      errorBorder: borde(Colores.error),
      focusedErrorBorder: borde(Colores.error, 2),
      errorStyle: const TextStyle(color: Colores.errorTexto, fontWeight: FontWeight.w700, fontSize: 12),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.all(Colores.blanco),
      trackColor: WidgetStateProperty.resolveWith(
        (e) => e.contains(WidgetState.selected) ? Colores.verde : Colores.bordeCampo,
      ),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (e) => e.contains(WidgetState.selected) ? Colores.verde : Colores.blanco,
      ),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating, backgroundColor: Colores.marino),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colores.blanco,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    ),
  );
}
