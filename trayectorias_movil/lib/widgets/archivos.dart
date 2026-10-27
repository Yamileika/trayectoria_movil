import 'package:flutter/material.dart';

import '../datos/modelos.dart';
import '../servicios/selector_archivos.dart';
import '../tema/colores.dart';

/// Icono de cada apartado de la trayectoria.
IconData iconoSeccion(SeccionTrayectoria s) => switch (s) {
  SeccionTrayectoria.formacion => Icons.school_outlined,
  SeccionTrayectoria.idiomas => Icons.translate,
  SeccionTrayectoria.experiencia => Icons.work_outline,
  SeccionTrayectoria.capacitacion => Icons.workspace_premium_outlined,
  SeccionTrayectoria.certificaciones => Icons.verified_outlined,
  SeccionTrayectoria.distinciones => Icons.emoji_events_outlined,
  SeccionTrayectoria.institucional => Icons.account_balance_outlined,
  SeccionTrayectoria.estadias => Icons.co_present_outlined,
  SeccionTrayectoria.membresias => Icons.groups_outlined,
  SeccionTrayectoria.propiedad => Icons.lightbulb_outline,
  SeccionTrayectoria.vinculacion => Icons.handshake_outlined,
};

/// Extensión del archivo en mayúsculas («PDF»), o vacío si no tiene.
String tipoArchivo(String nombre) => nombre.contains('.') ? nombre.split('.').last.toUpperCase() : '';

/// Carpetita de un apartado o de una carpeta del expediente. Como en la web,
/// la actual no lleva contorno ni se desplaza: solo un fondo suave del color
/// de la carpeta y el nombre subrayado.
class Carpetita extends StatelessWidget {
  const Carpetita({
    super.key,
    required this.icono,
    required this.texto,
    required this.detalle,
    required this.tono,
    required this.alTocar,
    this.actual = false,
  });

  final IconData icono;
  final String texto;
  final String detalle;
  final Tono tono;
  final bool actual;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: actual,
      button: true,
      child: Material(
        color: actual ? tono.suave : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: alTocar,
          borderRadius: BorderRadius.circular(14),
          hoverColor: tono.suave,
          child: SizedBox(
            width: 96,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(6, 10, 6, 8),
              child: Column(
                children: [
                  _Folder(icono: icono, tono: tono),
                  const SizedBox(height: 6),
                  Text(
                    texto,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      height: 1.2,
                      color: Colores.marino,
                      decoration: actual ? TextDecoration.underline : null,
                    ),
                  ),
                  Text(detalle, style: const TextStyle(fontSize: 10.5, color: Colores.apoyo)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Dibujo de carpeta: pestaña y cuerpo del color del apartado, con su icono.
class _Folder extends StatelessWidget {
  const _Folder({required this.icono, required this.tono});

  final IconData icono;
  final Tono tono;

  @override
  Widget build(BuildContext context) {
    const borde = BorderSide(color: Colores.marino, width: 1.5);
    return SizedBox(
      width: 58,
      height: 46,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 26,
              height: 12,
              decoration: BoxDecoration(
                color: tono.fuerte,
                border: const Border(top: borde, left: borde, right: borde),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ),
          ),
          Positioned.fill(
            top: 8,
            child: Container(
              decoration: BoxDecoration(
                color: tono.suave,
                border: Border.all(color: Colores.marino, width: 1.5),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Icon(icono, size: 20, color: Colores.marino),
            ),
          ),
        ],
      ),
    );
  }
}

/// Fila desplazable de carpetitas.
class FilaCarpetas extends StatelessWidget {
  const FilaCarpetas({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }
}

enum EstiloHoja { normal, personal, faltante }

/// Hoja de papel con esquina doblada, miniatura de muestra y su tipo, como
/// los archivos de la web. Debajo van el nombre y un detalle.
class HojaArchivo extends StatelessWidget {
  const HojaArchivo({
    super.key,
    required this.nombre,
    required this.detalle,
    required this.archivo,
    required this.alTocar,
    this.estilo = EstiloHoja.normal,
  });

  final String nombre;
  final String detalle;

  /// Nombre del archivo; vacío si todavía no hay archivo.
  final String archivo;
  final EstiloHoja estilo;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    final faltante = estilo == EstiloHoja.faltante;
    final tipo = tipoArchivo(archivo);
    return Semantics(
      button: true,
      label: '$nombre. $detalle',
      excludeSemantics: true,
      child: InkWell(
        onTap: alTocar,
        borderRadius: BorderRadius.circular(12),
        hoverColor: Colores.elegido,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 10, 4, 8),
          child: Column(
            children: [
              SizedBox(
                width: 86,
                height: 112,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: faltante ? const Color(0xFFFAFAFA) : Colores.blanco,
                          border: Border.all(color: faltante ? Colores.bordeCampo : Colores.marino, width: 1.5),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(14),
                            bottomLeft: Radius.circular(4),
                            bottomRight: Radius.circular(4),
                          ),
                          boxShadow: faltante ? null : const [BoxShadow(color: Colores.marino, offset: Offset(3, 3))],
                        ),
                        padding: const EdgeInsets.fromLTRB(9, 24, 9, 8),
                        child: _Muestra(titulo: archivo.isEmpty ? '' : nombre),
                      ),
                    ),
                    Positioned(
                      left: -6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: switch (estilo) {
                            EstiloHoja.normal => const Color(0xFFB5DE9F),
                            EstiloHoja.personal => const Color(0xFFFCD683),
                            EstiloHoja.faltante => Colores.blanco,
                          },
                          border: Border.all(color: Colores.marino, width: 1.5),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          tipo.isEmpty ? '—' : tipo,
                          style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colores.marino),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                nombre,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, height: 1.25),
              ),
              const SizedBox(height: 2),
              Text(
                detalle,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: faltante ? Colores.ambarTexto : Colores.apoyo,
                  fontWeight: faltante ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mini página de muestra dentro de la hoja.
class _Muestra extends StatelessWidget {
  const _Muestra({required this.titulo});

  final String titulo;

  @override
  Widget build(BuildContext context) {
    Widget linea([double ancho = 1]) => FractionallySizedBox(
      widthFactor: ancho,
      alignment: Alignment.centerLeft,
      child: Container(
        height: 3,
        margin: const EdgeInsets.only(top: 4),
        decoration: BoxDecoration(color: Colores.bordeSuave, borderRadius: BorderRadius.circular(2)),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (titulo.isNotEmpty) ...[
          const Text(
            'MUESTRA',
            style: TextStyle(fontSize: 6, letterSpacing: 0.6, fontWeight: FontWeight.w800, color: Colores.turquesa),
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.only(bottom: 3),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colores.marino)),
            ),
            child: Text(
              titulo,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 7.5, height: 1.2, fontWeight: FontWeight.w700, color: Colores.marino),
            ),
          ),
        ],
        linea(),
        linea(),
        linea(0.6),
      ],
    );
  }
}

/// Cuadrícula de hojas que se acomoda al ancho de la pantalla.
class CuadriculaHojas extends StatelessWidget {
  const CuadriculaHojas({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, limites) {
        final columnas = (limites.maxWidth / 116).floor().clamp(2, 6);
        final ancho = limites.maxWidth / columnas;
        return Wrap(
          children: [for (final hijo in children) SizedBox(width: ancho, child: hijo)],
        );
      },
    );
  }
}

/// Hoja inferior para elegir de dónde sale el archivo.
Future<OrigenArchivo?> preguntarOrigen(BuildContext context, String titulo) {
  return showModalBottomSheet<OrigenArchivo>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(titulo, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 14),
            for (final (origen, icono, texto) in [
              (OrigenArchivo.camara, Icons.photo_camera_outlined, 'Tomar foto'),
              (OrigenArchivo.galeria, Icons.image_outlined, 'Elegir de la galería'),
              (OrigenArchivo.archivos, Icons.description_outlined, 'Elegir archivo'),
            ]) ...[
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pop(origen),
                style: OutlinedButton.styleFrom(alignment: Alignment.centerLeft),
                icon: Icon(icono, size: 20),
                label: Text(texto),
              ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    ),
  );
}
