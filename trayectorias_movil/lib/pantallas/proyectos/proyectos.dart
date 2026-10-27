import 'package:flutter/material.dart';

import '../../datos/modelos.dart';
import '../../estado/alcance.dart';
import '../../tema/colores.dart';
import '../../widgets/cabecera.dart';
import '../../widgets/componentes.dart';
import '../principal.dart';

/// Proyectos del docente (solo profesores de tiempo completo). Solo consulta.
class Proyectos extends StatelessWidget {
  const Proyectos({super.key});

  static Color colorAvance(int avance) =>
      avance >= 60 ? Colores.turquesa : (avance >= 30 ? Colores.verde : Colores.ambar);

  @override
  Widget build(BuildContext context) {
    final proyectos = context.repositorio.proyectos;
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const CabeceraMovil(etiqueta: 'Proyectos', titulo: 'Proyectos', subtitulo: 'Consulta de tus proyectos'),
          const SizedBox(height: 16),
          if (proyectos.isEmpty)
            const SinResultados(mensaje: 'No tienes proyectos registrados.', icono: Icons.work_outline),
          for (final (i, p) in proyectos.indexed)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Tarjeta(
                color: i == 0 ? Colores.verdeSuave : Colores.blanco,
                destacada: i == 0,
                alTocar: () => abrirCompleta(context, DetalleProyecto(proyecto: p)),
                child: Row(
                  children: [
                    AnilloAvance(
                      fraccion: p.avance / 100,
                      texto: '${p.avance}%',
                      tamano: 56,
                      grosor: 5,
                      color: colorAvance(p.avance),
                      fondo: Colores.blanco,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.titulo, style: const TextStyle(fontWeight: FontWeight.w800)),
                          Text('${p.categoria} · ${p.periodo}', style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colores.marino),
                  ],
                ),
              ),
            ),
          const AvisoSimulado(),
        ],
      ),
    );
  }
}

enum _ApartadoProyecto { general, documentos, cronograma, avances }

class DetalleProyecto extends StatefulWidget {
  const DetalleProyecto({super.key, required this.proyecto});

  final Proyecto proyecto;

  @override
  State<DetalleProyecto> createState() => _DetalleProyectoState();
}

class _DetalleProyectoState extends State<DetalleProyecto> {
  var _apartado = _ApartadoProyecto.cronograma;

  @override
  Widget build(BuildContext context) {
    final p = widget.proyecto;
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          CabeceraMovil(
            volver: true,
            etiqueta: 'Proyecto',
            titulo: p.tituloCorto,
            subtitulo: 'Responsable: ${p.responsable} · ${p.periodo}',
          ),
          const SizedBox(height: 16),
          ChipsDesplazables(
            opciones: const [
              (_ApartadoProyecto.general, 'General'),
              (_ApartadoProyecto.documentos, 'Documentos'),
              (_ApartadoProyecto.cronograma, 'Cronograma'),
              (_ApartadoProyecto.avances, 'Avances'),
            ],
            seleccion: _apartado,
            alCambiar: (a) => setState(() => _apartado = a),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: switch (_apartado) {
                _ApartadoProyecto.general => [
                  Tarjeta(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.titulo, style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 6),
                        Text(p.descripcion),
                        const SizedBox(height: 10),
                        Insignia(p.categoria, tono: TonoInsignia.info),
                      ],
                    ),
                  ),
                ],
                _ApartadoProyecto.documentos => [
                  const SinResultados(
                    mensaje: 'La documentación del proyecto se consultará aquí cuando se registre.',
                    icono: Icons.folder_open_outlined,
                  ),
                ],
                _ApartadoProyecto.cronograma => [
                  for (final (i, fase) in p.cronograma.indexed) ...[
                    Tarjeta(
                      child: Row(
                        children: [
                          CajaIcono(
                            Icons.schedule,
                            fondo: i == p.cronograma.length - 1 ? Colores.ambarSuave : Colores.turquesaSuave,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(fase.titulo, style: const TextStyle(fontWeight: FontWeight.w800)),
                              Text(fase.fechas, style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
                _ApartadoProyecto.avances => [
                  Tarjeta(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text('Avance', style: TextStyle(fontWeight: FontWeight.w700)),
                            ),
                            Text('${p.avance}%', style: const TextStyle(fontWeight: FontWeight.w800)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        BarraAvance(fraccion: p.avance / 100, color: Proyectos.colorAvance(p.avance)),
                        const SizedBox(height: 10),
                        Text(
                          'Las entregas y evidencias de avance se mostrarán cuando se definan las revisiones.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              },
            ),
          ),
          const AvisoSimulado(),
        ],
      ),
    );
  }
}
