import 'package:flutter/material.dart';

import '../../datos/modelos.dart';
import '../../datos/repositorio.dart';
import '../../estado/alcance.dart';
import '../../tema/colores.dart';
import '../../widgets/archivos.dart';
import '../../widgets/cabecera.dart';
import '../../widgets/componentes.dart';
import '../principal.dart';
import '../trayectoria/formulario_registro.dart';
import 'subir_documento.dart';

enum TipoElemento { evidencia, faltaEvidencia, personal, ingreso, pendiente }

/// Un archivo del expediente como lo muestra la web: evidencia de la
/// trayectoria, archivo personal o documento de nuevo ingreso.
class ElementoArchivo {
  const ElementoArchivo({
    required this.id,
    required this.carpeta,
    required this.nombre,
    required this.detalle,
    required this.archivo,
    required this.tipo,
    this.registro,
    this.fila,
    this.personal,
  });

  final String id;

  /// Carpeta a la que pertenece: el nombre del apartado, «personal» o «ingreso».
  final String carpeta;
  final String nombre;
  final String detalle;

  /// Nombre del archivo; vacío si todavía no hay archivo.
  final String archivo;
  final TipoElemento tipo;
  final RegistroTrayectoria? registro;
  final FilaExpediente? fila;
  final ArchivoPersonal? personal;

  bool get faltante => tipo == TipoElemento.faltaEvidencia || tipo == TipoElemento.pendiente;

  EstiloHoja get estilo => faltante
      ? EstiloHoja.faltante
      : tipo == TipoElemento.personal
      ? EstiloHoja.personal
      : EstiloHoja.normal;
}

const carpetaPersonal = 'personal';
const carpetaIngreso = 'ingreso';

const _meses = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
String fechaCorta(DateTime f) => '${f.day} ${_meses[f.month - 1]} ${f.year}';

/// Evidencias de la trayectoria, una por registro (las que faltan también).
List<ElementoArchivo> elementosTrayectoria(Repositorio repo) => [
  for (final s in SeccionTrayectoria.values)
    for (final r in repo.trayectoria.where((r) => r.seccion == s))
      ElementoArchivo(
        id: 'registro-${r.id}',
        carpeta: s.name,
        nombre: r.evidencia?.nombre ?? r.titulo,
        detalle: r.evidencia != null ? '${r.titulo} · ${r.periodo}' : 'Falta evidencia',
        archivo: r.evidencia?.nombre ?? '',
        tipo: r.evidencia != null ? TipoElemento.evidencia : TipoElemento.faltaEvidencia,
        registro: r,
      ),
];

ElementoArchivo elementoDeFila(FilaExpediente fila) {
  final actual = fila.actual;
  return ElementoArchivo(
    id: 'ingreso-${fila.requisito.id}',
    carpeta: carpetaIngreso,
    nombre: fila.requisito.corto,
    detalle: actual != null
        ? '${actual.nombre} · ${fechaCorta(actual.subidoEn)}'
        : fila.requisito.responsable == Responsable.docente
        ? 'Pendiente'
        : 'Pendiente · Lo carga ${fila.requisito.responsable.etiqueta}',
    archivo: actual?.nombre ?? '',
    tipo: actual != null ? TipoElemento.ingreso : TipoElemento.pendiente,
    fila: fila,
  );
}

/// Expediente de un docente activo: primero la trayectoria, luego su carpeta
/// personal y al final lo que entregó al ingresar.
List<ElementoArchivo> elementosActivo(Repositorio repo) => [
  ...elementosTrayectoria(repo),
  for (final p in repo.carpetaPersonal)
    ElementoArchivo(
      id: 'personal-${p.id}',
      carpeta: carpetaPersonal,
      nombre: p.tipo,
      detalle: '${p.archivo.nombre} · ${fechaCorta(p.fecha)}',
      archivo: p.archivo.nombre,
      tipo: TipoElemento.personal,
      personal: p,
    ),
  for (final f in repo.expediente.where((f) => f.estado == EstadoDocumento.cargado)) elementoDeFila(f),
];

/// Vista previa de un archivo, con lo que se puede hacer con él.
class VistaArchivo extends StatefulWidget {
  const VistaArchivo({super.key, required this.elemento});

  final ElementoArchivo elemento;

  @override
  State<VistaArchivo> createState() => _VistaArchivoState();
}

class _VistaArchivoState extends State<VistaArchivo> {
  var _confirmando = false;

  @override
  Widget build(BuildContext context) {
    final e = widget.elemento;
    final tipo = tipoArchivo(e.archivo);
    final fila = e.fila;
    final propio = fila != null && fila.requisito.responsable == Responsable.docente;

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          CabeceraMovil(volver: true, etiqueta: 'Vista previa', titulo: e.nombre, subtitulo: e.detalle),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (tipo.isNotEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Insignia(tipo, tono: TonoInsignia.info),
                  ),
                const SizedBox(height: 12),
                if (e.faltante)
                  _Aviso(
                    icono: e.tipo == TipoElemento.pendiente ? Icons.schedule : Icons.attach_file,
                    texto: e.tipo == TipoElemento.pendiente
                        ? 'Este documento aún no se ha cargado.'
                        : 'Este registro aún no tiene evidencia.',
                  )
                else
                  _Hoja(titulo: e.tipo == TipoElemento.ingreso ? e.nombre : e.detalle.split(' · ').first),
                const SizedBox(height: 18),
                if (e.tipo == TipoElemento.faltaEvidencia)
                  FilledButton.icon(
                    onPressed: () =>
                        abrirCompleta(context, FormularioRegistro(seccion: e.registro!.seccion, registro: e.registro)),
                    icon: const Icon(Icons.upload, size: 18),
                    label: const Text('Adjuntar en Trayectoria'),
                  ),
                if (e.tipo == TipoElemento.pendiente)
                  propio
                      ? FilledButton.icon(
                          onPressed: () => abrirCompleta(context, SubirDocumento(requisito: fila.requisito)),
                          icon: const Icon(Icons.upload, size: 18),
                          label: const Text('Subir documento'),
                        )
                      : Text('Lo carga ${fila!.requisito.responsable.etiqueta}.', textAlign: TextAlign.center),
                if (e.tipo == TipoElemento.ingreso && propio)
                  OutlinedButton.icon(
                    onPressed: () => abrirCompleta(context, SubirDocumento(requisito: fila.requisito)),
                    icon: const Icon(Icons.swap_horiz, size: 18),
                    label: const Text('Reemplazar'),
                  ),
                if (e.tipo == TipoElemento.personal)
                  _confirmando
                      ? Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => setState(() => _confirmando = false),
                                child: const Text('Cancelar'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: FilledButton(
                                style: FilledButton.styleFrom(backgroundColor: Colores.errorTexto),
                                onPressed: () {
                                  context.repositorio.quitarPersonal(e.personal!.id);
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(content: Text('Se quitó el archivo.')));
                                },
                                child: const Text('Sí, quitar'),
                              ),
                            ),
                          ],
                        )
                      : OutlinedButton.icon(
                          onPressed: () => setState(() => _confirmando = true),
                          icon: const Icon(Icons.delete_outline, size: 18),
                          label: const Text('Quitar'),
                        ),
                if (e.tipo == TipoElemento.personal) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Solo tú puedes ver este archivo.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          const AvisoSimulado(),
        ],
      ),
    );
  }
}

/// Hoja de muestra: los archivos de la demostración no tienen contenido real.
class _Hoja extends StatelessWidget {
  const _Hoja({required this.titulo});

  final String titulo;

  @override
  Widget build(BuildContext context) {
    Widget linea([double ancho = 1]) => FractionallySizedBox(
      widthFactor: ancho,
      alignment: Alignment.centerLeft,
      child: Container(
        height: 8,
        margin: const EdgeInsets.only(top: 12),
        decoration: BoxDecoration(color: Colores.bordeSuave, borderRadius: BorderRadius.circular(4)),
      ),
    );
    return Semantics(
      image: true,
      label: 'Vista de muestra de $titulo',
      excludeSemantics: true,
      child: AspectRatio(
        aspectRatio: 0.77,
        child: Container(
          padding: const EdgeInsets.fromLTRB(28, 32, 28, 20),
          decoration: BoxDecoration(
            color: Colores.blanco,
            border: Border.all(color: Colores.marino, width: 1.5),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(28),
              bottomLeft: Radius.circular(6),
              bottomRight: Radius.circular(6),
            ),
            boxShadow: const [BoxShadow(color: Colores.marino, offset: Offset(4, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'DOCUMENTO DE MUESTRA',
                style: TextStyle(fontSize: 11, letterSpacing: 1, fontWeight: FontWeight.w800, color: Colores.turquesa),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.only(bottom: 10),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colores.marino, width: 1.5)),
                ),
                child: Text(titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              ),
              linea(),
              linea(),
              linea(0.6),
              linea(),
              linea(0.8),
              const Spacer(),
              Text('Archivo de muestra, sin contenido real', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _Aviso extends StatelessWidget {
  const _Aviso({required this.icono, required this.texto});

  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        border: Border.all(color: Colores.bordeCampo, width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icono, size: 36, color: Colores.apoyo),
          const SizedBox(height: 10),
          Text(
            texto,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
