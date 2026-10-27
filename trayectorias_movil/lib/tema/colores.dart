import 'package:flutter/material.dart';

import '../datos/modelos.dart';

/// Paleta de la guía de estilos (canvas «Trayectorias Docentes – plataforma integral»).
abstract final class Colores {
  // Principales institucionales
  static const marino = Color(0xFF1F1646);
  static const verde = Color(0xFF4C9C2E);
  static const fondo = Color(0xFFF6F6F5);

  // Secundarios institucionales
  static const turquesa = Color(0xFF15837D);
  static const ambar = Color(0xFFF9B237);
  static const error = Color(0xFFF44336);
  static const exito = Color(0xFF499B35);

  // Estados de botón
  static const verdeHover = Color(0xFF3B7F22);
  static const verdePresionado = Color(0xFF2F6A1B);

  // Derivados claros
  static const turquesaSuave = Color(0xFFDCF0EF);
  static const verdeSuave = Color(0xFFE3F1DD);
  static const ambarSuave = Color(0xFFFEF0D3);
  static const errorSuave = Color(0xFFFDECEA);
  static const neutro = Color(0xFFECEAF4);
  static const lilaSuave = Color(0xFFE6E1FA);

  /// Fondo del archivo elegido: suave, sin contorno (como en la web).
  static const elegido = Color(0xFFEEEBF8);

  // Texto sobre derivados (contraste AA)
  static const turquesaTexto = Color(0xFF0B5551);
  static const etiqueta = Color(0xFF0F6B66);
  static const verdeTexto = Color(0xFF2B5E1A);
  static const ambarTexto = Color(0xFF7A4E00);
  static const errorTexto = Color(0xFFB3261E);
  static const verdeSobreMarino = Color(0xFF9ED38A);
  static const lilaSobreMarino = Color(0xFFD6D1EA);
  static const moradoTexto = Color(0xFF4F3A9E);
  static const morado = Color(0xFF6B55C4);

  // Neutros
  static const bordeSuave = Color(0xFFDAD7E6);
  static const bordeCampo = Color(0xFFBDB8D0);
  static const apoyo = Color(0xFF4B4469);
  static const blanco = Colors.white;
}

/// Colores de cada tono de apartado: fondo suave, color de texto y color fuerte.
extension ColoresTono on Tono {
  Color get suave => switch (this) {
    Tono.turquesa => Colores.turquesaSuave,
    Tono.verde => Colores.verdeSuave,
    Tono.ambar => Colores.ambarSuave,
    Tono.morado => Colores.lilaSuave,
  };

  Color get texto => switch (this) {
    Tono.turquesa => Colores.turquesaTexto,
    Tono.verde => Colores.verdeTexto,
    Tono.ambar => Colores.ambarTexto,
    Tono.morado => Colores.moradoTexto,
  };

  Color get fuerte => switch (this) {
    Tono.turquesa => Colores.turquesa,
    Tono.verde => Colores.verde,
    Tono.ambar => Colores.ambar,
    Tono.morado => Colores.morado,
  };
}
