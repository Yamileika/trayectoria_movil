import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../datos/modelos.dart';
import '../tema/colores.dart';
import '../tema/tema.dart';

/// Superficie blanca con borde suave. Con [destacada] lleva borde marino y
/// sombra sólida corta (toque neobrutalista).
class Tarjeta extends StatelessWidget {
  const Tarjeta({
    super.key,
    required this.child,
    this.color = Colores.blanco,
    this.destacada = false,
    this.padding = const EdgeInsets.all(14),
    this.alTocar,
    this.etiquetaAccesible,
  });

  final Widget child;
  final Color color;
  final bool destacada;
  final EdgeInsetsGeometry padding;
  final VoidCallback? alTocar;
  final String? etiquetaAccesible;

  @override
  Widget build(BuildContext context) {
    final radio = BorderRadius.circular(14);
    return Container(
      decoration: BoxDecoration(
        borderRadius: radio,
        boxShadow: destacada ? const [BoxShadow(color: Colores.marino, offset: Offset(3, 3))] : null,
      ),
      child: Material(
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: radio,
          side: destacada
              ? const BorderSide(color: Colores.marino, width: 1.5)
              : const BorderSide(color: Colores.bordeSuave),
        ),
        clipBehavior: Clip.antiAlias,
        child: Semantics(
          button: alTocar != null,
          label: etiquetaAccesible,
          child: InkWell(
            onTap: alTocar,
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}

enum TonoInsignia { pendiente, listo, neutro, info }

/// Etiqueta de estado con texto y color (el color nunca va solo).
class Insignia extends StatelessWidget {
  const Insignia(this.texto, {super.key, this.tono = TonoInsignia.pendiente, this.icono, this.fuerte = false});

  factory Insignia.estado(EstadoDocumento estado) => switch (estado) {
    EstadoDocumento.cargado => Insignia(estado.etiqueta, tono: TonoInsignia.listo, icono: Icons.check),
    EstadoDocumento.pendiente => Insignia(estado.etiqueta),
    EstadoDocumento.noAplica => Insignia(estado.etiqueta, tono: TonoInsignia.neutro),
  };

  final String texto;
  final TonoInsignia tono;
  final IconData? icono;

  /// Versión más visible, con borde marino y sombra (por ejemplo «14 por subir»).
  final bool fuerte;

  @override
  Widget build(BuildContext context) {
    final (fondo, borde, tinta) = switch (tono) {
      TonoInsignia.pendiente => (
        fuerte ? Colores.ambar : Colores.ambarSuave,
        Colores.ambar,
        fuerte ? Colores.marino : Colores.ambarTexto,
      ),
      TonoInsignia.listo => (Colores.verdeSuave, Colores.exito, Colores.verdeTexto),
      TonoInsignia.neutro => (Colores.neutro, Colores.bordeCampo, Colores.apoyo),
      TonoInsignia.info => (Colores.turquesaSuave, Colores.turquesa, Colores.turquesaTexto),
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: fuerte ? 10 : 9, vertical: fuerte ? 3 : 2),
      decoration: BoxDecoration(
        color: fondo,
        border: Border.all(color: fuerte ? Colores.marino : borde, width: fuerte ? 1.5 : 1),
        borderRadius: BorderRadius.circular(99),
        boxShadow: fuerte ? const [BoxShadow(color: Colores.marino, offset: Offset(2, 2))] : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icono != null) ...[Icon(icono, size: 12, color: tinta), const SizedBox(width: 4)],
          Text(
            texto,
            style: TextStyle(fontSize: fuerte ? 12.5 : 11, fontWeight: FontWeight.w800, color: tinta),
          ),
        ],
      ),
    );
  }
}

/// Cuadro de icono de 36 px con fondo suave.
class CajaIcono extends StatelessWidget {
  const CajaIcono(
    this.icono, {
    super.key,
    this.fondo = Colores.turquesaSuave,
    this.color = Colores.marino,
    this.tamano = 36,
  });

  final IconData icono;
  final Color fondo;
  final Color color;
  final double tamano;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tamano,
      height: tamano,
      decoration: BoxDecoration(color: fondo, borderRadius: BorderRadius.circular(9)),
      child: Icon(icono, size: tamano * 0.5, color: color),
    );
  }
}

/// Fila de menú: icono, título, descripción y flecha.
class FilaMenu extends StatelessWidget {
  const FilaMenu({
    super.key,
    required this.icono,
    required this.titulo,
    this.descripcion,
    this.fondoIcono = Colores.turquesaSuave,
    this.colorTitulo = Colores.marino,
    this.alTocar,
    this.flecha = true,
    this.final_,
  });

  final IconData icono;
  final String titulo;
  final String? descripcion;
  final Color fondoIcono;
  final Color colorTitulo;
  final VoidCallback? alTocar;
  final bool flecha;
  final Widget? final_;

  @override
  Widget build(BuildContext context) {
    return Tarjeta(
      alTocar: alTocar,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          CajaIcono(icono, fondo: fondoIcono),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(fontWeight: FontWeight.w700, color: colorTitulo),
                ),
                if (descripcion != null) Text(descripcion!, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          ?final_,
          if (flecha && final_ == null) const Icon(Icons.chevron_right, color: Colores.marino),
        ],
      ),
    );
  }
}

/// Pestañas en forma de botón (Por subir / Cargados / Institución).
class Pestanas<T> extends StatelessWidget {
  const Pestanas({super.key, required this.opciones, required this.seleccion, required this.alCambiar});

  final List<(T, String)> opciones;
  final T seleccion;
  final ValueChanged<T> alCambiar;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final (valor, texto) in opciones) ...[
          Expanded(
            child: Semantics(
              selected: valor == seleccion,
              child: valor == seleccion
                  ? FilledButton(
                      onPressed: () => alCambiar(valor),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 38),
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        textStyle: const TextStyle(fontFamily: fuente, fontWeight: FontWeight.w800, fontSize: 12),
                      ),
                      child: Text(texto, maxLines: 1, overflow: TextOverflow.ellipsis),
                    )
                  : OutlinedButton(
                      onPressed: () => alCambiar(valor),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 38),
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        side: const BorderSide(color: Colores.bordeSuave),
                        textStyle: const TextStyle(fontFamily: fuente, fontWeight: FontWeight.w700, fontSize: 12),
                      ),
                      child: Text(texto, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
            ),
          ),
          if (valor != opciones.last.$1) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

/// Fila de chips desplazable (Formación, Experiencia…).
class ChipsDesplazables<T> extends StatelessWidget {
  const ChipsDesplazables({super.key, required this.opciones, required this.seleccion, required this.alCambiar});

  final List<(T, String)> opciones;
  final T seleccion;
  final ValueChanged<T> alCambiar;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (final (valor, texto) in opciones)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(texto),
                selected: valor == seleccion,
                showCheckmark: false,
                onSelected: (_) => alCambiar(valor),
                backgroundColor: Colores.neutro,
                selectedColor: Colores.verdeSuave,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                  color: valor == seleccion ? Colores.verdeTexto : Colores.marino,
                ),
                side: BorderSide(color: valor == seleccion ? Colores.exito : Colores.bordeCampo),
                shape: const StadiumBorder(),
              ),
            ),
        ],
      ),
    );
  }
}

/// Anillo de avance con el texto en el centro.
class AnilloAvance extends StatelessWidget {
  const AnilloAvance({
    super.key,
    required this.fraccion,
    required this.texto,
    this.tamano = 92,
    this.grosor = 7,
    this.color = Colores.verde,
    this.fondo = Colores.neutro,
    this.colorTexto = Colores.marino,
  });

  final double fraccion;
  final String texto;
  final double tamano;
  final double grosor;
  final Color color;
  final Color fondo;
  final Color colorTexto;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: tamano,
      height: tamano,
      child: CustomPaint(
        painter: _Anillo(fraccion.clamp(0, 1), grosor, color, fondo),
        child: Center(
          child: Text(
            texto,
            style: TextStyle(fontSize: tamano * 0.24, fontWeight: FontWeight.w800, color: colorTexto),
          ),
        ),
      ),
    );
  }
}

class _Anillo extends CustomPainter {
  _Anillo(this.fraccion, this.grosor, this.color, this.fondo);

  final double fraccion;
  final double grosor;
  final Color color;
  final Color fondo;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final area = rect.deflate(grosor / 2);
    final pincel = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = grosor
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(area, 0, math.pi * 2, false, pincel..color = fondo);
    if (fraccion > 0) canvas.drawArc(area, -math.pi / 2, math.pi * 2 * fraccion, false, pincel..color = color);
  }

  @override
  bool shouldRepaint(_Anillo old) => old.fraccion != fraccion || old.color != color;
}

/// Barra delgada de avance.
class BarraAvance extends StatelessWidget {
  const BarraAvance({super.key, required this.fraccion, this.color = Colores.verde});

  final double fraccion;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: LinearProgressIndicator(value: fraccion, minHeight: 7, color: color, backgroundColor: Colores.neutro),
    );
  }
}

/// Etiqueta de campo + campo de texto, con el estilo de la guía.
class CampoTexto extends StatelessWidget {
  const CampoTexto({
    super.key,
    required this.etiqueta,
    this.controlador,
    this.pista,
    this.validar,
    this.lineas = 1,
    this.teclado,
    this.oculto = false,
    this.sufijo,
    this.soloLectura = false,
    this.maximo,
    this.error,
    this.autocompletar,
  });

  final String etiqueta;
  final TextEditingController? controlador;
  final String? pista;
  final FormFieldValidator<String>? validar;
  final int lineas;
  final TextInputType? teclado;
  final bool oculto;
  final Widget? sufijo;
  final bool soloLectura;
  final int? maximo;
  final String? error;
  final Iterable<String>? autocompletar;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(etiqueta, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        TextFormField(
          controller: controlador,
          validator: validar,
          minLines: lineas,
          maxLines: oculto ? 1 : lineas,
          keyboardType: teclado,
          obscureText: oculto,
          readOnly: soloLectura,
          maxLength: maximo,
          autofillHints: autocompletar,
          decoration: InputDecoration(
            hintText: pista,
            suffixIcon: sufijo,
            errorText: error,
            counterText: '',
            fillColor: error != null ? Colores.errorSuave : (soloLectura ? Colores.fondo : null),
          ),
          style: const TextStyle(fontSize: 14, color: Colores.marino),
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}

/// Validador de campo obligatorio con límite de caracteres.
FormFieldValidator<String> obligatorio([int? maximo]) => (v) {
  if (v == null || v.trim().isEmpty) return 'Este campo es obligatorio';
  if (maximo != null && v.length > maximo) return 'Máximo $maximo caracteres';
  return null;
};

/// Botones fijos al pie (Cancelar / Guardar).
class BotonesInferiores extends StatelessWidget {
  const BotonesInferiores({super.key, required this.principal, this.secundario});

  final Widget principal;
  final Widget? secundario;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          children: [
            if (secundario != null) ...[Expanded(child: secundario!), const SizedBox(width: 10)],
            Expanded(child: principal),
          ],
        ),
      ),
    );
  }
}

/// Aviso de que los datos son de muestra.
class AvisoSimulado extends StatelessWidget {
  const AvisoSimulado({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Text(
        'Datos de demostración: los cambios se pierden al cerrar la app.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 11.5, color: Colores.apoyo),
      ),
    );
  }
}

/// Mensaje para listas vacías o búsquedas sin resultados.
class SinResultados extends StatelessWidget {
  const SinResultados({super.key, required this.mensaje, this.accion, this.alAccion, this.icono = Icons.search_off});

  final String mensaje;
  final String? accion;
  final VoidCallback? alAccion;
  final IconData icono;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      child: Column(
        children: [
          Icon(icono, size: 36, color: Colores.apoyo),
          const SizedBox(height: 8),
          Text(mensaje, textAlign: TextAlign.center),
          if (accion != null) ...[
            const SizedBox(height: 12),
            OutlinedButton(onPressed: alAccion, child: Text(accion!)),
          ],
        ],
      ),
    );
  }
}

/// Quita acentos y pasa a minúsculas para buscar sin importar cómo se escriba.
String normalizar(String texto) {
  const de = 'áéíóúüñÁÉÍÓÚÜÑ';
  const a = 'aeiouunaeiouun';
  final buffer = StringBuffer();
  for (final c in texto.split('')) {
    final i = de.indexOf(c);
    buffer.write(i >= 0 ? a[i] : c);
  }
  return buffer.toString().toLowerCase();
}

/// Todas las palabras de la búsqueda deben aparecer, en cualquier orden.
bool coincide(String consulta, Iterable<String> campos) {
  final texto = normalizar(campos.join(' '));
  return normalizar(consulta).split(RegExp(r'\s+')).where((p) => p.isNotEmpty).every(texto.contains);
}

String tamanoLegible(int bytes) =>
    bytes >= 1024 * 1024 ? '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB' : '${(bytes / 1024).round()} KB';
