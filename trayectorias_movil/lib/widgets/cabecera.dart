import 'package:flutter/material.dart';

import '../tema/colores.dart';
import '../tema/tema.dart';

/// Cabecera marino con el círculo verde y el cuadro ámbar del diseño.
class CabeceraMovil extends StatelessWidget {
  const CabeceraMovil({
    super.key,
    this.etiqueta,
    this.titulo,
    this.subtitulo,
    this.volver = false,
    this.encabezado,
    this.pie,
  });

  /// Sobretítulo en mayúsculas (por ejemplo «EXPEDIENTE»).
  final String? etiqueta;
  final String? titulo;
  final String? subtitulo;

  /// Muestra «‹ Volver» arriba.
  final bool volver;

  /// Contenido propio en lugar de etiqueta, título y subtítulo.
  final Widget? encabezado;

  /// Contenido debajo del título (conteos, botón).
  final Widget? pie;

  @override
  Widget build(BuildContext context) {
    final arriba = MediaQuery.paddingOf(context).top;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      child: Container(
        color: Colores.marino,
        child: Stack(
          children: [
            const Positioned(
              right: -34,
              top: -44,
              child: SizedBox(
                width: 150,
                height: 150,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: Colores.verde, shape: BoxShape.circle),
                ),
              ),
            ),
            Positioned(
              right: 88,
              top: 62 + arriba,
              child: Transform.rotate(
                angle: 0.314,
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colores.ambar,
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(18, 18 + arriba, 18, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (volver)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => Navigator.of(context).maybePop(),
                        style: TextButton.styleFrom(
                          foregroundColor: Colores.blanco,
                          padding: const EdgeInsets.only(right: 8),
                          minimumSize: const Size(44, 36),
                          textStyle: const TextStyle(fontFamily: fuente, fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        icon: const Icon(Icons.chevron_left, size: 22),
                        label: const Text('Volver'),
                      ),
                    ),
                  ?encabezado,
                  if (etiqueta != null)
                    Text(
                      etiqueta!.toUpperCase(),
                      style: const TextStyle(
                        color: Colores.verdeSobreMarino,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.3,
                      ),
                    ),
                  if (titulo != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2, right: 40),
                      child: Semantics(
                        header: true,
                        child: Text(
                          titulo!,
                          style: const TextStyle(
                            color: Colores.blanco,
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                          ),
                        ),
                      ),
                    ),
                  if (subtitulo != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(subtitulo!, style: const TextStyle(color: Colores.lilaSobreMarino, fontSize: 12.5)),
                    ),
                  if (pie != null) ...[const SizedBox(height: 16), pie!],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Avatar circular con iniciales, como en las cabeceras del diseño.
class AvatarIniciales extends StatelessWidget {
  const AvatarIniciales(this.iniciales, {super.key, this.tamano = 44});

  final String iniciales;
  final double tamano;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tamano,
      height: tamano,
      alignment: Alignment.center,
      decoration: const BoxDecoration(color: Colores.turquesaSuave, shape: BoxShape.circle),
      child: Text(
        iniciales,
        style: TextStyle(color: Colores.marino, fontWeight: FontWeight.w800, fontSize: tamano * 0.36),
      ),
    );
  }
}

/// Fila con avatar, nombre y un dato debajo (Inicio, Más, Trayectoria).
class PerfilCabecera extends StatelessWidget {
  const PerfilCabecera({
    super.key,
    required this.iniciales,
    required this.arriba,
    required this.abajo,
    this.grande = true,
    this.accion,
  });

  final String iniciales;
  final String arriba;
  final String abajo;

  /// Nombre grande (Más, Trayectoria) o saludo pequeño (Inicio).
  final bool grande;
  final Widget? accion;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AvatarIniciales(iniciales, tamano: grande ? 56 : 44),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: grande
                ? [
                    Text(
                      arriba,
                      style: const TextStyle(color: Colores.blanco, fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                    Text(abajo, style: const TextStyle(color: Colores.lilaSobreMarino, fontSize: 12.5)),
                  ]
                : [
                    Text(arriba, style: const TextStyle(color: Colores.lilaSobreMarino, fontSize: 12.5)),
                    Text(
                      abajo,
                      style: const TextStyle(color: Colores.blanco, fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                  ],
          ),
        ),
        ?accion,
      ],
    );
  }
}
