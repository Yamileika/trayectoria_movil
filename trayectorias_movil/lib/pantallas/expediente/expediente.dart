import 'package:flutter/material.dart';

import '../../datos/modelos.dart';
import '../../estado/alcance.dart';
import '../../tema/colores.dart';
import '../../widgets/cabecera.dart';
import '../../widgets/componentes.dart';
import '../principal.dart';
import '../../widgets/archivos.dart';
import 'expediente_activo.dart';
import 'explorador.dart';
import 'subir_documento.dart';

enum VistaExpediente { porSubir, cargados, institucion }

/// Mi expediente: Por subir, Cargados y lo que está a cargo de la institución.
class Expediente extends StatefulWidget {
  const Expediente({super.key, required this.vista});

  /// Vista elegida; otras pantallas pueden cambiarla (por ejemplo «Mis archivos»).
  final ValueNotifier<VistaExpediente> vista;

  @override
  State<Expediente> createState() => _ExpedienteState();
}

class _ExpedienteState extends State<Expediente> {
  final _busqueda = TextEditingController();
  final _abiertas = <CategoriaDocumento>{};
  var _primeraVez = true;

  static const _fondos = {
    CategoriaDocumento.cartas: Colores.turquesaSuave,
    CategoriaDocumento.identidad: Colores.verdeSuave,
    CategoriaDocumento.formacion: Colores.ambarSuave,
    CategoriaDocumento.tramites: Colores.turquesaSuave,
  };

  @override
  void initState() {
    super.initState();
    _busqueda.addListener(() => setState(() {}));
    widget.vista.addListener(_alCambiarVista);
  }

  @override
  void dispose() {
    widget.vista.removeListener(_alCambiarVista);
    _busqueda.dispose();
    super.dispose();
  }

  void _alCambiarVista() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final repo = context.repositorio;
    // Ya activo, el expediente se vuelve el explorador de carpetas.
    if (repo.docente.estado == EstadoDocente.activo) return const ExpedienteActivo();
    final filas = repo.expediente;
    final propias = filas.where((f) => f.requisito.responsable == Responsable.docente).toList();
    final avance = Avance.de(propias);
    final vista = widget.vista.value;

    if (_primeraVez) {
      // El primer apartado con pendientes empieza abierto.
      final primera = CategoriaDocumento.values.where(
        (c) => propias.any((f) => f.requisito.categoria == c && f.estado == EstadoDocumento.pendiente),
      );
      if (primera.isNotEmpty) _abiertas.add(primera.first);
      _primeraVez = false;
    }

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          CabeceraMovil(
            etiqueta: 'Expediente',
            titulo: 'Mi expediente',
            subtitulo: '${repo.docente.estado.etiqueta} · ${avance.cargados} de ${avance.aplicables} documentos',
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Pestanas(
              opciones: [
                (VistaExpediente.porSubir, 'Por subir ${avance.pendientes}'),
                (VistaExpediente.cargados, 'Cargados ${avance.cargados}'),
                (VistaExpediente.institucion, 'Institución'),
              ],
              seleccion: vista,
              alCambiar: (v) => widget.vista.value = v,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: switch (vista) {
                VistaExpediente.porSubir => _porSubir(propias),
                VistaExpediente.cargados => _cargados(propias),
                VistaExpediente.institucion => _institucion(repo.docente, filas),
              },
            ),
          ),
          const AvisoSimulado(),
        ],
      ),
    );
  }

  List<Widget> _porSubir(List<FilaExpediente> propias) {
    final todas = propias.where((f) => f.estado == EstadoDocumento.pendiente).toList();
    if (todas.isEmpty) {
      return const [
        Tarjeta(
          color: Colores.verdeSuave,
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colores.verdeTexto),
              SizedBox(width: 10),
              Expanded(
                child: Text('Ya subiste todos tus documentos. Los documentos de ingreso no requieren revisión.'),
              ),
            ],
          ),
        ),
      ];
    }
    final buscando = _busqueda.text.trim().isNotEmpty;
    final pendientes = todas.where((f) => coincide(_busqueda.text, [f.requisito.nombre])).toList();
    return [
      TextField(
        controller: _busqueda,
        decoration: const InputDecoration(hintText: 'Buscar un documento', prefixIcon: Icon(Icons.search)),
      ),
      const SizedBox(height: 14),
      if (pendientes.isEmpty)
        SinResultados(
          mensaje: 'Ningún documento pendiente coincide con la búsqueda.',
          accion: 'Limpiar búsqueda',
          alAccion: _busqueda.clear,
        ),
      for (final categoria in CategoriaDocumento.values)
        if (pendientes.any((f) => f.requisito.categoria == categoria))
          _Apartado(
            categoria: categoria,
            fondo: _fondos[categoria]!,
            filas: pendientes.where((f) => f.requisito.categoria == categoria).toList(),
            abierto: buscando || _abiertas.contains(categoria),
            alAlternar: () => setState(() {
              _abiertas.contains(categoria) ? _abiertas.remove(categoria) : _abiertas.add(categoria);
            }),
          ),
    ];
  }

  List<Widget> _cargados(List<FilaExpediente> propias) {
    final cargados = propias.where((f) => f.estado == EstadoDocumento.cargado).toList();
    if (cargados.isEmpty) {
      return [
        SinResultados(
          mensaje: 'Aún no has cargado documentos.',
          icono: Icons.description_outlined,
          accion: 'Ver los que faltan',
          alAccion: () => widget.vista.value = VistaExpediente.porSubir,
        ),
      ];
    }
    return [
      Text('Tus archivos, en un solo lugar', style: Theme.of(context).textTheme.titleMedium),
      Text('Toca un archivo para verlo o reemplazarlo.', style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: 6),
      CuadriculaHojas(
        children: [
          for (final fila in cargados)
            Builder(
              builder: (context) {
                final e = elementoDeFila(fila);
                return HojaArchivo(
                  nombre: e.nombre,
                  detalle: '${fila.actual!.nombre} · versión ${fila.actual!.version}',
                  archivo: e.archivo,
                  alTocar: () => abrirCompleta(context, VistaArchivo(elemento: e)),
                );
              },
            ),
        ],
      ),
    ];
  }

  List<Widget> _institucion(Docente docente, List<FilaExpediente> filas) {
    Widget dato(String etiqueta, String valor) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(etiqueta, style: const TextStyle(color: Colores.apoyo)),
          ),
          Text(valor.isEmpty ? 'Pendiente de asignación' : valor, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );

    return [
      Tarjeta(
        color: Colores.turquesaSuave,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Datos que asigna Recursos Humanos', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            dato('Número de nómina', docente.nomina),
            dato('Correo institucional', docente.correoInstitucional),
          ],
        ),
      ),
      const SizedBox(height: 18),
      for (final responsable in [Responsable.administracion, Responsable.rh]) ...[
        Builder(
          builder: (context) {
            final suyas = filas.where((f) => f.requisito.responsable == responsable).toList();
            final avance = Avance.de(suyas);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(responsable.etiqueta, style: Theme.of(context).textTheme.titleMedium)),
                    Text(
                      '${avance.cargados} de ${avance.aplicables}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                BarraAvance(fraccion: avance.fraccion),
                const SizedBox(height: 10),
                // Lo que ya cargó la institución se abre como cualquier archivo.
                CuadriculaHojas(
                  children: [
                    for (final fila in suyas.where((f) => f.estado != EstadoDocumento.noAplica))
                      Builder(
                        builder: (context) {
                          final e = elementoDeFila(fila);
                          return HojaArchivo(
                            nombre: e.nombre,
                            detalle: e.detalle,
                            archivo: e.archivo,
                            estilo: e.estilo,
                            alTocar: () => abrirCompleta(context, VistaArchivo(elemento: e)),
                          );
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 18),
              ],
            );
          },
        ),
      ],
      Text(
        'Estos documentos los sube la institución. Toca uno para verlo; no puedes cambiarlos.',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    ];
  }
}

/// Apartado desplegable con los documentos pendientes de una categoría.
class _Apartado extends StatelessWidget {
  const _Apartado({
    required this.categoria,
    required this.fondo,
    required this.filas,
    required this.abierto,
    required this.alAlternar,
  });

  final CategoriaDocumento categoria;
  final Color fondo;
  final List<FilaExpediente> filas;
  final bool abierto;
  final VoidCallback alAlternar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Tarjeta(
        destacada: true,
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            Semantics(
              expanded: abierto,
              button: true,
              child: InkWell(
                onTap: alAlternar,
                child: Container(
                  color: fondo,
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      const CajaIcono(Icons.description_outlined, fondo: Colores.blanco),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(categoria.etiqueta, style: const TextStyle(fontWeight: FontWeight.w800)),
                      ),
                      Insignia('${filas.length} por subir'),
                    ],
                  ),
                ),
              ),
            ),
            if (abierto)
              for (final fila in filas)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Colores.neutro)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(fila.requisito.corto, style: const TextStyle(fontWeight: FontWeight.w700)),
                            Text('PDF, JPG o PNG', style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: () => abrirCompleta(context, SubirDocumento(requisito: fila.requisito)),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colores.marino,
                          minimumSize: const Size(0, 40),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                        ),
                        icon: const Icon(Icons.upload, size: 18),
                        label: Text('Subir', semanticsLabel: 'Subir ${fila.requisito.corto}'),
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
