import 'package:flutter/material.dart';

import '../../datos/modelos.dart';
import '../../estado/alcance.dart';
import '../../tema/colores.dart';
import '../../widgets/archivos.dart';
import '../../widgets/cabecera.dart';
import '../../widgets/componentes.dart';
import '../principal.dart';
import 'documentos_personales.dart';
import 'explorador.dart';

const _todos = 'todos';

/// Expediente de un docente activo, como explorador de carpetas (igual que
/// la web), en dos grupos: las evidencias de la trayectoria por apartado y
/// lo que se entregó al ingresar, incluido lo que cargó la institución. Los
/// documentos personales tienen su propio botón. Al tocar un archivo se abre
/// su vista previa.
class ExpedienteActivo extends StatefulWidget {
  const ExpedienteActivo({super.key});

  @override
  State<ExpedienteActivo> createState() => _ExpedienteActivoState();
}

enum _Grupo { trayectoria, ingreso }

class _ExpedienteActivoState extends State<ExpedienteActivo> {
  var _grupo = _Grupo.trayectoria;
  var _carpeta = _todos;

  @override
  Widget build(BuildContext context) {
    final repo = context.repositorio;
    final elementos = elementosActivo(repo);
    final trayectoria = elementos.where((e) => e.registro != null).toList();
    final ingreso = elementos.where((e) => e.carpeta == carpetaIngreso).toList();
    int cuantos(String carpeta) => trayectoria.where((e) => e.carpeta == carpeta).length;
    final mostrados = _carpeta == _todos ? trayectoria : trayectoria.where((e) => e.carpeta == _carpeta).toList();
    final seccion = SeccionTrayectoria.values.where((s) => s.name == _carpeta).firstOrNull;

    Widget carpeta(String id, IconData icono, String texto, Tono tono) => Carpetita(
      icono: icono,
      texto: texto,
      detalle: '${id == _todos ? trayectoria.length : cuantos(id)}',
      tono: tono,
      actual: _carpeta == id,
      alTocar: () => setState(() => _carpeta = id),
    );

    Widget encabezado(String titulo, String detalle) => Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(header: true, child: Text(titulo, style: Theme.of(context).textTheme.titleLarge)),
          Text(detalle, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );

    String documentos(int n) => n == 1 ? '1 documento' : '$n documentos';

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          CabeceraMovil(
            etiqueta: 'Expediente',
            titulo: 'Mi expediente',
            subtitulo: '${repo.docente.estado.etiqueta} · ${documentos(elementos.length)}',
          ),
          const Padding(padding: EdgeInsets.fromLTRB(16, 16, 16, 0), child: BotonPersonales()),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Pestanas(
              opciones: [
                (_Grupo.trayectoria, 'Trayectoria ${trayectoria.length}'),
                (_Grupo.ingreso, 'Ingreso ${ingreso.length}'),
              ],
              seleccion: _grupo,
              alCambiar: (g) => setState(() => _grupo = g),
            ),
          ),
          if (_grupo == _Grupo.trayectoria) ...[
            const SizedBox(height: 4),
            FilaCarpetas(
              children: [
                carpeta(_todos, Icons.folder_copy_outlined, 'Todos', Tono.ambar),
                for (final s in SeccionTrayectoria.values) carpeta(s.name, iconoSeccion(s), s.etiqueta, s.tono),
              ],
            ),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: switch (_grupo) {
                _Grupo.trayectoria => [
                  encabezado(seccion?.nombre ?? 'Todas las evidencias', documentos(mostrados.length)),
                  Hojas(elementos: mostrados, vacio: 'No hay documentos en esta carpeta.'),
                ],
                _Grupo.ingreso => [
                  encabezado('Documentación de nuevo ingreso', 'Lo que entregaste tú y lo que cargó la institución'),
                  for (final responsable in const [Responsable.docente, Responsable.administracion, Responsable.rh])
                    if (ingreso.any((e) => e.fila!.requisito.responsable == responsable)) ...[
                      const SizedBox(height: 14),
                      Text(
                        responsable == Responsable.docente ? 'Tus documentos' : responsable.etiqueta,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Hojas(
                        elementos: ingreso.where((e) => e.fila!.requisito.responsable == responsable).toList(),
                        vacio: '',
                      ),
                    ],
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

/// Cuadrícula de hojas que abre la vista previa de cada archivo.
class Hojas extends StatelessWidget {
  const Hojas({super.key, required this.elementos, required this.vacio});

  final List<ElementoArchivo> elementos;
  final String vacio;

  @override
  Widget build(BuildContext context) {
    if (elementos.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          vacio,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colores.apoyo),
        ),
      );
    }
    return CuadriculaHojas(
      children: [
        for (final e in elementos)
          HojaArchivo(
            nombre: e.nombre,
            detalle: e.detalle,
            archivo: e.archivo,
            estilo: e.estilo,
            alTocar: () => abrirCompleta(context, VistaArchivo(elemento: e)),
          ),
      ],
    );
  }
}
