import 'package:flutter/material.dart';

import '../../datos/modelos.dart';
import '../../datos/repositorio.dart';
import '../../estado/alcance.dart';
import '../../tema/colores.dart';
import '../../widgets/archivos.dart';
import '../../widgets/cabecera.dart';
import '../../widgets/componentes.dart';
import 'publicaciones.dart';

/// Apartado que puede llevar un documento: los de la trayectoria más
/// Publicaciones y Proyectos.
class _Apartado {
  const _Apartado(this.id, this.nombre, this.icono, this.tono, this.entradas);

  final String id;
  final String nombre;
  final IconData icono;
  final Tono tono;
  final List<(String, String, String)> entradas;
}

enum _Formato {
  cv('Currículum vitae', 'Toda tu trayectoria', Icons.description_outlined, Tono.turquesa),
  ficha('Ficha institucional', 'Datos de adscripción', Icons.account_balance_outlined, Tono.verde),
  informe('Informe de trayectoria', 'Actividad del periodo', Icons.workspace_premium_outlined, Tono.ambar),
  semblanza('Semblanza', 'Presentación breve', Icons.person_outline, Tono.morado);

  const _Formato(this.nombre, this.descripcion, this.icono, this.tono);
  final String nombre;
  final String descripcion;
  final IconData icono;
  final Tono tono;

  /// Apartados que incluye por omisión; vacío si no usa apartados.
  Set<String> get porOmision => switch (this) {
    cv => {for (final s in SeccionTrayectoria.values) s.name, 'publicaciones', 'proyectos'},
    informe => {'capacitacion', 'distinciones', 'institucional', 'estadias', 'vinculacion', 'proyectos'},
    _ => {},
  };
}

/// Generar documentos (como en la web): el formato se elige entre
/// archivitos, se marcan los apartados que incluye y se ve la hoja.
class Documentos extends StatefulWidget {
  const Documentos({super.key});

  @override
  State<Documentos> createState() => _DocumentosState();
}

class _DocumentosState extends State<Documentos> {
  var _formato = _Formato.cv;
  var _incluidos = _Formato.cv.porOmision;

  List<_Apartado> _apartados(Repositorio repo) => [
    for (final s in SeccionTrayectoria.values)
      _Apartado(s.name, s.nombre, iconoSeccion(s), s.tono, [
        for (final r in repo.trayectoria.where((r) => r.seccion == s)) (r.periodo, r.titulo, r.detalle),
      ]),
    _Apartado('publicaciones', 'Publicaciones', Icons.menu_book_outlined, Tono.ambar, [
      for (final p in repo.publicaciones.where((p) => esRegistrada(repo, p)))
        ('${p.anio}', p.titulo, '${p.tipo} · ${p.fuente}'),
    ]),
    if (repo.docente.esPtc)
      _Apartado('proyectos', 'Proyectos', Icons.work_outline, Tono.turquesa, [
        for (final p in repo.proyectos) (p.periodo, p.titulo, p.descripcion),
      ]),
  ];

  /// Semblanza escrita por el docente o, si no hay, una armada con su último
  /// grado, su puesto y sus idiomas.
  String _semblanza(Repositorio repo) {
    final d = repo.docente;
    if (d.contacto.semblanza.trim().isNotEmpty) return d.contacto.semblanza.trim();
    String? primero(SeccionTrayectoria s) => repo.trayectoria.where((r) => r.seccion == s).firstOrNull?.titulo;
    final idiomas = repo.trayectoria.where((r) => r.seccion == SeccionTrayectoria.idiomas).map((r) => r.titulo);
    return [
      '${d.nombre} es docente de ${d.contratacion.etiqueta.toLowerCase()} en ${d.departamento}.',
      if (primero(SeccionTrayectoria.formacion) case final grado?) 'Cuenta con ${grado.toLowerCase()}.',
      if (idiomas.isNotEmpty) 'Domina ${idiomas.join(', ').toLowerCase()}.',
    ].join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.repositorio;
    final d = repo.docente;
    final apartados = _apartados(repo);
    final usaApartados = _formato == _Formato.cv || _formato == _Formato.informe;
    final hoja = apartados.where((a) => _incluidos.contains(a.id)).toList();

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const CabeceraMovil(
            volver: true,
            etiqueta: 'Documentos',
            titulo: 'Generar documentos',
            subtitulo: 'Se arman con la información de tu trayectoria, sin volver a capturar.',
          ),
          const SizedBox(height: 14),
          FilaCarpetas(
            children: [
              for (final f in _Formato.values)
                _Archivito(
                  formato: f,
                  actual: f == _formato,
                  alTocar: () => setState(() {
                    _formato = f;
                    _incluidos = f.porOmision;
                  }),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(_formato.nombre, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 6),
                if (usaApartados) ...[
                  Row(
                    children: [
                      Expanded(child: Text('Apartados que incluye', style: Theme.of(context).textTheme.labelLarge)),
                      TextButton(
                        onPressed: () => setState(() => _incluidos = {for (final a in apartados) a.id}),
                        child: const Text('Todos'),
                      ),
                      TextButton(onPressed: () => setState(() => _incluidos = {}), child: const Text('Ninguno')),
                    ],
                  ),
                  Tarjeta(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      children: [
                        for (final a in apartados)
                          CheckboxListTile(
                            value: _incluidos.contains(a.id),
                            onChanged: (v) => setState(() {
                              _incluidos = {..._incluidos};
                              v! ? _incluidos.add(a.id) : _incluidos.remove(a.id);
                            }),
                            dense: true,
                            controlAffinity: ListTileControlAffinity.leading,
                            secondary: Text('${a.entradas.length}', style: const TextStyle(color: Colores.apoyo)),
                            title: Row(
                              children: [
                                CajaIcono(a.icono, fondo: a.tono.suave, tamano: 28),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(a.nombre, style: const TextStyle(fontWeight: FontWeight.w700)),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ] else
                  Text(
                    _formato == _Formato.ficha
                        ? 'Usa los datos que asigna Recursos Humanos.'
                        : 'Se arma con tu semblanza o, si no la tienes, con tu último grado, tu puesto y tus idiomas.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                const SizedBox(height: 18),
                _Hoja(formato: _formato, docente: d, apartados: hoja, semblanza: _semblanza(repo)),
                const SizedBox(height: 18),
                Text('Generados recientemente', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                for (final (nombre, fecha) in [
                  ('Currículum vitae', '20 oct 2026'),
                  ('Ficha institucional', '18 oct 2026'),
                ])
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CajaIcono(Icons.description_outlined),
                    title: Text(nombre, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text('Vista previa · $fecha'),
                    trailing: const Insignia('Muestra'),
                  ),
              ],
            ),
          ),
          const AvisoSimulado(),
        ],
      ),
      bottomNavigationBar: BotonesInferiores(
        principal: OutlinedButton.icon(
          onPressed: null,
          style: OutlinedButton.styleFrom(side: const BorderSide(color: Colores.bordeCampo)),
          icon: const Icon(Icons.download, size: 18),
          label: const Text('Guardar PDF · pendiente'),
        ),
      ),
    );
  }
}

/// Formato como archivito: mini hoja del color del formato.
class _Archivito extends StatelessWidget {
  const _Archivito({required this.formato, required this.actual, required this.alTocar});

  final _Formato formato;
  final bool actual;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: actual,
      button: true,
      child: Material(
        color: actual ? formato.tono.suave : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: alTocar,
          borderRadius: BorderRadius.circular(14),
          hoverColor: formato.tono.suave,
          child: SizedBox(
            width: 112,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 80,
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: Colores.blanco,
                      border: Border.all(color: Colores.marino, width: 1.5),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(12),
                        bottomLeft: Radius.circular(4),
                        bottomRight: Radius.circular(4),
                      ),
                      boxShadow: [BoxShadow(color: formato.tono.fuerte, offset: const Offset(3, 3))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(formato.icono, size: 16, color: Colores.marino),
                        const Spacer(),
                        for (final ancho in [1.0, 1.0, 0.6])
                          FractionallySizedBox(
                            widthFactor: ancho,
                            child: Container(
                              height: 3,
                              margin: const EdgeInsets.only(top: 4),
                              color: Colores.bordeSuave,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formato.nombre,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      decoration: actual ? TextDecoration.underline : null,
                    ),
                  ),
                  Text(
                    formato.descripcion,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 10.5, color: Colores.apoyo),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Hoja con la vista previa del documento.
class _Hoja extends StatelessWidget {
  const _Hoja({required this.formato, required this.docente, required this.apartados, required this.semblanza});

  final _Formato formato;
  final Docente docente;
  final List<_Apartado> apartados;
  final String semblanza;

  @override
  Widget build(BuildContext context) {
    final d = docente;
    final estiloBajo = Theme.of(context).textTheme.bodySmall;
    String asignado(String v) => v.isEmpty ? 'Pendiente de asignación' : v;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colores.blanco,
        border: Border.all(color: Colores.marino, width: 1.5),
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [BoxShadow(color: Colores.marino, offset: Offset(4, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AvatarIniciales(d.iniciales, tamano: 46),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formato.nombre.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10.5,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w800,
                        color: Colores.etiqueta,
                      ),
                    ),
                    Text(d.nombre, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    Text(
                      [
                        d.departamento,
                        d.contratacion.etiqueta,
                        if (d.correoInstitucional.isNotEmpty) d.correoInstitucional,
                      ].join(' · '),
                      style: estiloBajo,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24, thickness: 1.5, color: Colores.marino),
          switch (formato) {
            _Formato.ficha => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final (e, v) in [
                  ('Nombre', d.nombre),
                  ('Departamento', d.departamento),
                  ('Contratación', d.contratacion.etiqueta),
                  ('Número de nómina', asignado(d.nomina)),
                  ('Correo institucional', asignado(d.correoInstitucional)),
                ])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e, style: estiloBajo),
                        Text(v, style: const TextStyle(fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
              ],
            ),
            _Formato.semblanza => Text(semblanza, style: const TextStyle(height: 1.5)),
            _ => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (formato == _Formato.cv && d.contacto.semblanza.isNotEmpty) ...[
                  Text(d.contacto.semblanza, style: const TextStyle(height: 1.5)),
                  const SizedBox(height: 12),
                ],
                if (apartados.isEmpty) Text('Elige al menos un apartado.', style: estiloBajo),
                for (final a in apartados) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    margin: const EdgeInsets.only(top: 6, bottom: 6),
                    color: a.tono.suave,
                    child: Text(a.nombre, style: const TextStyle(fontWeight: FontWeight.w800)),
                  ),
                  if (a.entradas.isEmpty) Text('Sin registros.', style: estiloBajo),
                  for (final (periodo, titulo, detalle) in a.entradas)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: 76, child: Text(periodo, style: estiloBajo)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(titulo, style: const TextStyle(fontWeight: FontWeight.w700)),
                                Text(detalle, style: estiloBajo),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ],
            ),
          },
          const SizedBox(height: 12),
          Text('Vista previa con datos de demostración · sin validez oficial.', style: estiloBajo),
        ],
      ),
    );
  }
}
