import 'package:flutter/material.dart';

import '../../datos/modelos.dart';
import '../../estado/alcance.dart';
import '../../tema/colores.dart';
import '../../widgets/cabecera.dart';
import '../../widgets/componentes.dart';

class Notificaciones extends StatelessWidget {
  const Notificaciones({super.key});

  @override
  Widget build(BuildContext context) {
    final avisos = context.repositorio.avisos;
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          CabeceraMovil(
            volver: true,
            etiqueta: 'Avisos',
            titulo: 'Notificaciones',
            subtitulo: avisos.length == 1 ? '1 nueva' : '${avisos.length} nuevas',
          ),
          const SizedBox(height: 16),
          if (avisos.isEmpty)
            const SinResultados(mensaje: 'No tienes avisos por ahora.', icono: Icons.notifications_none),
          for (final aviso in avisos)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Tarjeta(
                color: aviso.tipo == TipoAviso.publicacion ? Colores.blanco : Colores.verdeSuave.withValues(alpha: 0.5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CajaIcono(iconoAviso(aviso.tipo), fondo: fondoAviso(aviso.tipo)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(aviso.titulo, style: const TextStyle(fontWeight: FontWeight.w800)),
                          Text(aviso.detalle, style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                    Text(aviso.cuando, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11)),
                  ],
                ),
              ),
            ),
          const AvisoSimulado(),
        ],
      ),
    );
  }

  static IconData iconoAviso(TipoAviso t) => switch (t) {
    TipoAviso.fecha => Icons.schedule,
    TipoAviso.avance => Icons.check,
    TipoAviso.institucional => Icons.person_outline,
    TipoAviso.publicacion => Icons.menu_book_outlined,
  };

  static Color fondoAviso(TipoAviso t) => switch (t) {
    TipoAviso.fecha => Colores.ambarSuave,
    TipoAviso.avance => Colores.verdeSuave,
    _ => Colores.turquesaSuave,
  };
}
