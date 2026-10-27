import 'package:flutter/material.dart';

import '../../datos/modelos.dart';
import '../../estado/alcance.dart';
import '../../tema/colores.dart';
import '../../widgets/cabecera.dart';
import '../../widgets/componentes.dart';
import 'publicaciones.dart';

/// Mis indicadores: avance personal, conteos y cargas por mes.
class Indicadores extends StatelessWidget {
  const Indicadores({super.key});

  static const _meses = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];

  @override
  Widget build(BuildContext context) {
    final repo = context.repositorio;
    final avance = repo.avancePropio;
    final registros = repo.trayectoria;
    final publicaciones = repo.publicaciones.where((p) => esRegistrada(repo, p)).length;

    // Documentos que subió el docente en los últimos cuatro meses.
    final hoy = DateTime.now();
    final meses = [for (var i = 3; i >= 0; i--) DateTime(hoy.year, hoy.month - i)];
    final subidas = repo.expediente
        .where((f) => f.requisito.responsable == Responsable.docente)
        .expand((f) => f.versiones);
    final porMes = [
      for (final m in meses) subidas.where((a) => a.subidoEn.year == m.year && a.subidoEn.month == m.month).length,
    ];
    final maximo = porMes.fold(1, (a, b) => a > b ? a : b);
    const colores = [Colores.verde, Colores.turquesa, Colores.ambar, Colores.verde];

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const CabeceraMovil(volver: true, etiqueta: 'Seguimiento', titulo: 'Mis indicadores', subtitulo: 'Tu avance'),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Tarjeta(
                  color: Colores.turquesaSuave,
                  destacada: true,
                  child: Row(
                    children: [
                      AnilloAvance(
                        fraccion: avance.fraccion,
                        texto: '${avance.porcentaje}%',
                        tamano: 88,
                        fondo: Colores.blanco,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Avance personal', style: TextStyle(fontWeight: FontWeight.w800)),
                            Text('${avance.cargados} de ${avance.aplicables} documentos de ingreso'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.9,
                  children: [
                    _Kpi('Registros', registros.length, Colores.turquesaSuave),
                    _Kpi('Publicaciones', publicaciones, Colores.verdeSuave),
                    if (repo.docente.esPtc) _Kpi('Proyectos', repo.proyectos.length, Colores.ambarSuave),
                    _Kpi(
                      'Capacitaciones',
                      registros.where((r) => r.seccion == SeccionTrayectoria.capacitacion).length,
                      Colores.turquesaSuave,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Tarjeta(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Cargas por mes', style: TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 12),
                      Semantics(
                        label: [for (final (i, m) in meses.indexed) '${_meses[m.month - 1]}: ${porMes[i]}'].join(', '),
                        excludeSemantics: true,
                        child: SizedBox(
                          height: 130,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              for (final (i, m) in meses.indexed)
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text('${porMes[i]}', style: const TextStyle(fontSize: 11)),
                                      const SizedBox(height: 4),
                                      Container(
                                        width: 40,
                                        height: 4 + 80 * porMes[i] / maximo,
                                        decoration: BoxDecoration(
                                          color: colores[i],
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(_meses[m.month - 1], style: Theme.of(context).textTheme.bodySmall),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi(this.etiqueta, this.valor, this.fondo);

  final String etiqueta;
  final int valor;
  final Color fondo;

  @override
  Widget build(BuildContext context) {
    return Tarjeta(
      color: fondo,
      destacada: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(etiqueta),
          Text('$valor', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
