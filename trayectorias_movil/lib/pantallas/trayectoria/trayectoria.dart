import 'package:flutter/material.dart';

import '../../datos/modelos.dart';
import '../../datos/repositorio.dart';
import '../../estado/alcance.dart';
import '../../tema/colores.dart';
import '../../widgets/archivos.dart';
import '../../widgets/cabecera.dart';
import '../../widgets/componentes.dart';
import '../expediente/expediente.dart';
import '../expediente/explorador.dart';
import '../principal.dart';
import 'formulario_registro.dart';

enum _Vista { lista, archivos }

/// Apartados con al menos un registro, frente al total.
double perfilCompleto(Repositorio repo) =>
    SeccionTrayectoria.values.where((s) => repo.trayectoria.any((r) => r.seccion == s)).length /
    SeccionTrayectoria.values.length;

/// Mi trayectoria, como en la web: perfil completo, carpetitas de los
/// apartados y, debajo, la lista de cada apartado o sus archivos.
class Trayectoria extends StatefulWidget {
  const Trayectoria({super.key});

  @override
  State<Trayectoria> createState() => _TrayectoriaState();
}

class _TrayectoriaState extends State<Trayectoria> {
  var _vista = _Vista.lista;

  /// Carpeta que filtra los archivos (solo en la vista Archivos).
  SeccionTrayectoria? _filtro;

  void _tocarCarpeta(SeccionTrayectoria s) {
    // En la lista, la carpeta abre su apartado; en Archivos, filtra.
    if (_vista == _Vista.lista) {
      abrir(context, DetalleSeccion(seccion: s));
    } else {
      setState(() => _filtro = _filtro == s ? null : s);
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.repositorio;
    final docente = repo.docente;
    final completo = perfilCompleto(repo);
    int cuantos(SeccionTrayectoria s) => repo.trayectoria.where((r) => r.seccion == s).length;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          CabeceraMovil(
            encabezado: PerfilCabecera(
              iniciales: docente.iniciales,
              arriba: docente.nombre,
              abajo: docente.departamento,
            ),
            pie: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    AnilloAvance(
                      fraccion: completo,
                      texto: '${(completo * 100).round()}%',
                      tamano: 72,
                      fondo: Colores.blanco.withValues(alpha: 0.15),
                      colorTexto: Colores.blanco,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PERFIL COMPLETO',
                            style: TextStyle(
                              color: Colores.verdeSobreMarino,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            '${(completo * SeccionTrayectoria.values.length).round()} de '
                            '${SeccionTrayectoria.values.length} apartados con registros',
                            style: const TextStyle(color: Colores.blanco, fontWeight: FontWeight.w800, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => abrirCompleta(context, const FormularioRegistro()),
                        style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Agregar registro'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Principal.irA(context, Pestana.expediente, vista: VistaExpediente.cargados),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colores.blanco,
                          side: const BorderSide(color: Colores.blanco),
                        ),
                        icon: const Icon(Icons.description_outlined, size: 18),
                        label: const Text('Mi expediente'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  header: true,
                  child: Text('Apartados de mi trayectoria', style: Theme.of(context).textTheme.titleLarge),
                ),
                Text(
                  _vista == _Vista.archivos
                      ? 'Toca una carpeta para ver solo los archivos de ese apartado.'
                      : 'Toca una carpeta para abrir ese apartado.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 10),
                Pestanas(
                  opciones: const [(_Vista.lista, 'Lista'), (_Vista.archivos, 'Archivos')],
                  seleccion: _vista,
                  alCambiar: (v) => setState(() {
                    _vista = v;
                    _filtro = null;
                  }),
                ),
              ],
            ),
          ),
          FilaCarpetas(
            children: [
              for (final s in SeccionTrayectoria.values)
                Carpetita(
                  icono: iconoSeccion(s),
                  texto: s.etiqueta,
                  detalle: cuantos(s) == 1 ? '1 registro' : '${cuantos(s)} registros',
                  tono: s.tono,
                  actual: _vista == _Vista.archivos && _filtro == s,
                  alTocar: () => _tocarCarpeta(s),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (_vista == _Vista.lista)
            for (final s in SeccionTrayectoria.values)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: TarjetaSeccion(seccion: s),
              )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _Archivos(filtro: _filtro),
            ),
          const AvisoSimulado(),
        ],
      ),
    );
  }
}

/// Archivos de evidencia de los apartados, filtrados por carpeta.
class _Archivos extends StatelessWidget {
  const _Archivos({required this.filtro});

  final SeccionTrayectoria? filtro;

  @override
  Widget build(BuildContext context) {
    final todos = elementosTrayectoria(context.repositorio);
    final elementos = filtro == null ? todos : todos.where((e) => e.carpeta == filtro!.name).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(filtro?.nombre ?? 'Todos los apartados', style: Theme.of(context).textTheme.titleMedium),
        Text(
          elementos.length == 1 ? '1 archivo' : '${elementos.length} archivos',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (elementos.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Text('Este apartado todavía no tiene registros.', textAlign: TextAlign.center),
          )
        else
          CuadriculaHojas(
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
          ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline, size: 18, color: Colores.apoyo),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Aquí están las evidencias de cada apartado. Las publicaciones y los proyectos se consultan en su lista.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Tarjeta de un apartado con su encabezado de color y sus registros.
class TarjetaSeccion extends StatelessWidget {
  const TarjetaSeccion({super.key, required this.seccion, this.conTitulo = true});

  final SeccionTrayectoria seccion;

  /// En el detalle del apartado el título ya está en la cabecera.
  final bool conTitulo;

  @override
  Widget build(BuildContext context) {
    final registros = context.repositorio.trayectoria.where((r) => r.seccion == seccion).toList();
    final s = seccion;
    return Container(
      decoration: BoxDecoration(
        color: Colores.blanco,
        border: Border.all(color: Colores.marino, width: 1.5),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: s.tono.suave, offset: const Offset(4, 4))],
      ),
      // El recorte va por dentro del borde para que las esquinas se vean completas.
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: s.tono.suave,
              padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
              child: Row(
                children: [
                  CajaIcono(iconoSeccion(s), fondo: Colores.blanco),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (conTitulo)
                          InkWell(
                            onTap: () => abrir(context, DetalleSeccion(seccion: s)),
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(text: s.nombre),
                                  TextSpan(
                                    text: '  ${registros.length}',
                                    style: TextStyle(color: s.tono.texto, fontWeight: FontWeight.w800),
                                  ),
                                ],
                              ),
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5),
                            ),
                          ),
                        Text(s.descripcion, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: s.agregar,
                    onPressed: () => abrirCompleta(context, FormularioRegistro(seccion: s)),
                    style: IconButton.styleFrom(
                      backgroundColor: Colores.blanco,
                      side: const BorderSide(color: Colores.marino, width: 1.5),
                    ),
                    icon: const Icon(Icons.add, color: Colores.marino),
                  ),
                ],
              ),
            ),
            const Divider(height: 1.5, thickness: 1.5, color: Colores.marino),
            if (registros.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Todavía no hay registros.', style: Theme.of(context).textTheme.bodySmall),
              ),
            for (final (i, r) in registros.indexed) _FilaRegistro(registro: r, primera: i == 0),
          ],
        ),
      ),
    );
  }
}

class _FilaRegistro extends StatelessWidget {
  const _FilaRegistro({required this.registro, required this.primera});

  final RegistroTrayectoria registro;
  final bool primera;

  @override
  Widget build(BuildContext context) {
    final r = registro;
    void editar() => abrirCompleta(context, FormularioRegistro(seccion: r.seccion, registro: r));
    return Semantics(
      button: true,
      label: 'Editar ${r.titulo}',
      child: InkWell(
        onTap: editar,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            border: primera ? null : const Border(top: BorderSide(color: Colores.neutro)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                constraints: const BoxConstraints(minWidth: 64, maxWidth: 76),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                decoration: BoxDecoration(
                  color: Colores.fondo,
                  border: Border.all(color: Colores.bordeSuave),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  r.periodo,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.titulo, style: const TextStyle(fontWeight: FontWeight.w800)),
                    Text(r.detalle, style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 6),
                    if (r.evidencia != null)
                      const Insignia('Evidencia adjunta', tono: TonoInsignia.listo, icono: Icons.check)
                    else
                      const Insignia('Falta evidencia', icono: Icons.attach_file),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Un apartado abierto. Arriba van las carpetitas con la actual marcada,
/// para saltar a otro apartado.
class DetalleSeccion extends StatelessWidget {
  const DetalleSeccion({super.key, required this.seccion});

  final SeccionTrayectoria seccion;

  @override
  Widget build(BuildContext context) {
    final repo = context.repositorio;
    int cuantos(SeccionTrayectoria s) => repo.trayectoria.where((r) => r.seccion == s).length;
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          CabeceraMovil(
            volver: true,
            etiqueta: 'Mi trayectoria',
            titulo: seccion.nombre,
            subtitulo: cuantos(seccion) == 1 ? '1 registro' : '${cuantos(seccion)} registros',
            pie: FilledButton.icon(
              onPressed: () => abrirCompleta(context, FormularioRegistro(seccion: seccion)),
              icon: const Icon(Icons.add, size: 18),
              label: Text(seccion.agregar),
            ),
          ),
          const SizedBox(height: 10),
          FilaCarpetas(
            children: [
              for (final s in SeccionTrayectoria.values)
                Carpetita(
                  icono: iconoSeccion(s),
                  texto: s.etiqueta,
                  detalle: cuantos(s) == 1 ? '1 registro' : '${cuantos(s)} registros',
                  tono: s.tono,
                  actual: s == seccion,
                  alTocar: () {
                    if (s == seccion) return;
                    Navigator.of(context)
                        .pushReplacement(MaterialPageRoute(builder: (_) => DetalleSeccion(seccion: s)));
                  },
                ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TarjetaSeccion(seccion: seccion, conTitulo: false),
          ),
          const SizedBox(height: 8),
          const AvisoSimulado(),
        ],
      ),
    );
  }
}
