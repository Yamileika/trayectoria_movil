import 'package:flutter/material.dart';

import '../../widgets/cabecera.dart';
import '../../widgets/componentes.dart';

/// Preguntas frecuentes, tomadas de las reglas ya definidas en la plataforma.
class Ayuda extends StatelessWidget {
  const Ayuda({super.key});

  static const _preguntas = [
    (
      '¿Qué archivos puedo subir?',
      'Documentos en PDF, JPG o PNG de hasta 2 MB. Puedes tomar una foto, elegirla de la galería o elegir un archivo.',
    ),
    (
      '¿Por qué hay documentos que no puedo subir?',
      'Administración y Recursos Humanos suben sus propios documentos. Los consultas en Expediente › Institución.',
    ),
    (
      '¿Alguien revisa mis documentos?',
      'Los documentos de ingreso no requieren revisión. Al subirlos cuentan en tu avance.',
    ),
    (
      '¿Puedo cambiar un archivo que ya subí?',
      'Sí. En Expediente › Cargados elige «Reemplazar»; se guarda como una nueva versión.',
    ),
    (
      '¿Quién asigna mi nómina y mi correo institucional?',
      'Recursos Humanos. Los verás en Información general cuando estén asignados.',
    ),
    ('¿Problemas para entrar?', 'Escribe a Evaluación y Formación Docente.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const CabeceraMovil(volver: true, etiqueta: 'Ayuda', titulo: 'Preguntas frecuentes'),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                for (final (pregunta, respuesta) in _preguntas) ...[
                  Tarjeta(
                    padding: EdgeInsets.zero,
                    child: ExpansionTile(
                      shape: const Border(),
                      title: Text(pregunta, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                      expandedCrossAxisAlignment: CrossAxisAlignment.start,
                      children: [Text(respuesta)],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
