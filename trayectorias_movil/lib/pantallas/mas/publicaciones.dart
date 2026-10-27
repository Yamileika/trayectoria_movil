import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../datos/modelos.dart';
import '../../datos/repositorio.dart';
import '../../estado/alcance.dart';
import '../../tema/colores.dart';
import '../../widgets/cabecera.dart';
import '../../widgets/componentes.dart';
import '../principal.dart';

enum _Filtro { todas, registradas, sugerencias }

/// Una publicación cuenta como registrada si no es sugerencia o si el
/// docente confirmó que es suya. Las que marcó como ajenas se ocultan.
bool esRegistrada(Repositorio repo, Publicacion p) => !p.sugerencia || repo.decision(p.id) == DecisionSugerencia.mia;
bool esSugerenciaPendiente(Repositorio repo, Publicacion p) =>
    p.sugerencia && repo.decision(p.id) == DecisionSugerencia.pendiente;

class Publicaciones extends StatefulWidget {
  const Publicaciones({super.key});

  @override
  State<Publicaciones> createState() => _PublicacionesState();
}

class _PublicacionesState extends State<Publicaciones> {
  var _filtro = _Filtro.todas;
  final _busqueda = TextEditingController();

  @override
  void initState() {
    super.initState();
    _busqueda.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.repositorio;
    final registradas = repo.publicaciones.where((p) => esRegistrada(repo, p)).toList();
    final sugerencias = repo.publicaciones.where((p) => esSugerenciaPendiente(repo, p)).toList();
    bool busca(Publicacion p) => coincide(_busqueda.text, [p.titulo, p.autores]);

    final verSugerencias = _filtro != _Filtro.registradas ? sugerencias.where(busca).toList() : <Publicacion>[];
    final verRegistradas = _filtro != _Filtro.sugerencias ? registradas.where(busca).toList() : <Publicacion>[];

    // La lista va agrupada por año, del más reciente al más antiguo.
    final anios = {for (final p in verRegistradas) p.anio}.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          CabeceraMovil(
            volver: true,
            etiqueta: 'Producción científica',
            titulo: 'Publicaciones',
            pie: Row(
              children: [
                _Cifra(registradas.length, registradas.length == 1 ? 'Registrada' : 'Registradas'),
                const SizedBox(width: 10),
                _Cifra(sugerencias.length, 'Por confirmar'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Pestanas(
                  opciones: const [
                    (_Filtro.todas, 'Todas'),
                    (_Filtro.registradas, 'Registradas'),
                    (_Filtro.sugerencias, 'Sugerencias'),
                  ],
                  seleccion: _filtro,
                  alCambiar: (f) => setState(() => _filtro = f),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _busqueda,
                  decoration: const InputDecoration(
                    hintText: 'Buscar por título o autor',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 14),
                if (verSugerencias.isEmpty && verRegistradas.isEmpty)
                  SinResultados(
                    mensaje: _busqueda.text.isEmpty
                        ? 'No hay publicaciones en esta vista.'
                        : 'Ninguna publicación coincide.',
                    accion: _busqueda.text.isEmpty ? null : 'Limpiar búsqueda',
                    alAccion: _busqueda.clear,
                  ),
                if (verSugerencias.isNotEmpty) ...[
                  Tarjeta(
                    color: Colores.ambarSuave,
                    destacada: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.auto_awesome_outlined, color: Colores.ambarTexto),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                verSugerencias.length == 1
                                    ? '1 publicación podría ser tuya'
                                    : '${verSugerencias.length} publicaciones podrían ser tuyas',
                                style: const TextStyle(fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Confirma si son tuyas. Una coincidencia de nombre no lo asegura.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        for (final p in verSugerencias) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colores.blanco,
                              border: Border.all(color: Colores.bordeSuave),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                InkWell(
                                  onTap: () => abrirCompleta(context, DetallePublicacion(publicacion: p)),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _IconoTipo(p.tipo),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(p.titulo, style: const TextStyle(fontWeight: FontWeight.w800)),
                                            Text(
                                              '${p.tipo} · ${p.anio} · ${p.fuente}',
                                              style: Theme.of(context).textTheme.bodySmall,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                _BotonesAutoria(publicacion: p),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
                for (final anio in anios) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Semantics(
                      header: true,
                      child: Text('$anio', style: Theme.of(context).textTheme.titleMedium),
                    ),
                  ),
                  for (final p in verRegistradas.where((p) => p.anio == anio)) ...[
                    Tarjeta(
                      alTocar: () => abrirCompleta(context, DetallePublicacion(publicacion: p)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _IconoTipo(p.tipo),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.titulo, style: const TextStyle(fontWeight: FontWeight.w800)),
                                Text('${p.tipo} · ${p.fuente}', style: Theme.of(context).textTheme.bodySmall),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Colores.apoyo),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  const SizedBox(height: 6),
                ],
                const AvisoSimulado(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Icono de color según el tipo de publicación.
class _IconoTipo extends StatelessWidget {
  const _IconoTipo(this.tipo);

  final String tipo;

  @override
  Widget build(BuildContext context) {
    final (icono, tono) = switch (tipo) {
      'Artículo' => (Icons.article_outlined, Tono.turquesa),
      'Capítulo' => (Icons.menu_book_outlined, Tono.ambar),
      'Ponencia' => (Icons.mic_none, Tono.verde),
      _ => (Icons.description_outlined, Tono.morado),
    };
    return CajaIcono(icono, fondo: tono.suave, color: tono.texto);
  }
}

class _Cifra extends StatelessWidget {
  const _Cifra(this.valor, this.texto);

  final int valor;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colores.blanco.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              '$valor',
              style: const TextStyle(color: Colores.blanco, fontSize: 20, fontWeight: FontWeight.w800),
            ),
            Text(texto, style: const TextStyle(color: Colores.lilaSobreMarino, fontSize: 11.5)),
          ],
        ),
      ),
    );
  }
}

class _BotonesAutoria extends StatelessWidget {
  const _BotonesAutoria({required this.publicacion});

  final Publicacion publicacion;

  void _decidir(BuildContext context, DecisionSugerencia d) {
    context.repositorio.decidir(publicacion.id, d);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(d == DecisionSugerencia.mia ? 'Se agregó a tus publicaciones.' : 'Se descartó la sugerencia.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: () => _decidir(context, DecisionSugerencia.mia),
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Es mía'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton(
            onPressed: () => _decidir(context, DecisionSugerencia.ajena),
            child: const Text('No es mía'),
          ),
        ),
      ],
    );
  }
}

/// Referencia lista para copiar: autoría (año). Título. Fuente.
String referencia(Publicacion p) => '${p.autores} (${p.anio}). ${p.titulo}. ${p.fuente}.';

class DetallePublicacion extends StatelessWidget {
  const DetallePublicacion({super.key, required this.publicacion});

  final Publicacion publicacion;

  @override
  Widget build(BuildContext context) {
    final p = publicacion;
    final pendiente = esSugerenciaPendiente(context.repositorio, p);
    Widget fila(String etiqueta, String valor) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(etiqueta, style: const TextStyle(color: Colores.apoyo)),
          ),
          Expanded(
            child: Text(
              valor,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          CabeceraMovil(volver: true, etiqueta: 'Publicación', titulo: p.titulo, subtitulo: '${p.tipo} · ${p.anio}'),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (pendiente) ...[
                  const Tarjeta(
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colores.marino),
                        SizedBox(width: 10),
                        Expanded(child: Text('Una coincidencia de nombre no confirma que sea tuya.')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Tarjeta(
                  child: Column(
                    children: [
                      fila('Tipo', p.tipo),
                      fila('Autoría', p.autores),
                      fila('Fuente', p.fuente),
                      fila('Año', '${p.anio}'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text('Referencia', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Tarjeta(
                  color: Colores.fondo,
                  child: SelectableText(referencia(p), style: const TextStyle(height: 1.45)),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: referencia(p)));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Referencia copiada.')));
                  },
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text('Copiar referencia'),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: pendiente
          ? BotonesInferiores(
              secundario: OutlinedButton(
                onPressed: () {
                  context.repositorio.decidir(p.id, DecisionSugerencia.ajena);
                  Navigator.of(context).pop();
                },
                child: const Text('No es mía'),
              ),
              principal: FilledButton.icon(
                onPressed: () {
                  context.repositorio.decidir(p.id, DecisionSugerencia.mia);
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Es mía'),
              ),
            )
          : null,
    );
  }
}
