import 'package:flutter/material.dart';

import '../../datos/modelos.dart';
import '../../estado/alcance.dart';
import '../../tema/colores.dart';
import '../../widgets/archivos.dart';
import '../../widgets/cabecera.dart';
import '../../widgets/componentes.dart';
import '../principal.dart';
import 'expediente_activo.dart';
import 'explorador.dart';

/// Botón aparte para llegar a los documentos personales.
class BotonPersonales extends StatelessWidget {
  const BotonPersonales({super.key});

  @override
  Widget build(BuildContext context) {
    final n = context.repositorio.carpetaPersonal.length;
    return Tarjeta(
      color: Colores.lilaSuave,
      destacada: true,
      etiquetaAccesible: 'Mis documentos personales',
      alTocar: () => abrir(context, const DocumentosPersonales()),
      child: Row(
        children: [
          const CajaIcono(Icons.lock_outline, fondo: Colores.blanco),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Mis documentos personales', style: TextStyle(fontWeight: FontWeight.w800)),
                Text(
                  '${n == 1 ? '1 archivo' : '$n archivos'} · Solo tú los ves',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colores.marino),
        ],
      ),
    );
  }
}

/// Documentos personales: los que el docente quiera guardar, con el nombre
/// que quiera. Solo los ve él.
class DocumentosPersonales extends StatelessWidget {
  const DocumentosPersonales({super.key});

  Future<void> _subir(BuildContext context) async {
    final repo = context.repositorio;
    final selector = context.selector;
    final mensajero = ScaffoldMessenger.of(context);
    final tipo = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => const _NombrePersonal(),
    );
    if (tipo == null || !context.mounted) return;
    final origen = await preguntarOrigen(context, 'Subir «$tipo»');
    if (origen == null) return;
    final archivo = await selector.elegir(origen);
    if (archivo == null) return;
    final error = repo.agregarPersonal(tipo, archivo);
    mensajero.showSnackBar(SnackBar(content: Text(error ?? 'Se guardó «$tipo» en tus documentos personales.')));
  }

  @override
  Widget build(BuildContext context) {
    final personales = elementosActivo(context.repositorio).where((e) => e.carpeta == carpetaPersonal).toList();
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          CabeceraMovil(
            volver: true,
            etiqueta: 'Mi expediente',
            titulo: 'Mis documentos personales',
            subtitulo: '${personales.length == 1 ? '1 archivo' : '${personales.length} archivos'} · Solo tú los ves',
            pie: FilledButton.icon(
              onPressed: () => _subir(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Agregar documento'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Guarda aquí los documentos que quieras tener a la mano, con el nombre que elijas.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Hojas(
                  elementos: personales,
                  vacio: 'Aún no tienes documentos personales. Toca «Agregar documento» para subir el primero.',
                ),
              ],
            ),
          ),
          const AvisoSimulado(),
        ],
      ),
    );
  }
}

/// Pide qué documento es, con sugerencias; se puede escribir cualquier nombre.
class _NombrePersonal extends StatefulWidget {
  const _NombrePersonal();

  @override
  State<_NombrePersonal> createState() => _NombrePersonalState();
}

class _NombrePersonalState extends State<_NombrePersonal> {
  final _nombre = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _nombre.dispose();
    super.dispose();
  }

  void _seguir() {
    final texto = _nombre.text.trim();
    if (texto.isEmpty) {
      setState(() => _error = 'Escribe qué documento es.');
      return;
    }
    Navigator.of(context).pop(texto);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Agregar documento personal', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Escribe el nombre que quieras, por ejemplo «Pasaporte» o «Licencia de manejo». Solo tú podrás verlo.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _nombre,
              maxLength: 120,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _seguir(),
              decoration: InputDecoration(
                labelText: 'Nombre del documento',
                hintText: 'Escribe cualquier nombre',
                errorText: _error,
                counterText: '',
              ),
            ),
            const SizedBox(height: 10),
            Text('O elige una sugerencia', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in sugerenciasPersonales)
                  ActionChip(
                    label: Text(s),
                    onPressed: () => setState(() {
                      _nombre.text = s;
                      _error = null;
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: _seguir, child: const Text('Elegir archivo')),
          ],
        ),
      ),
    );
  }
}
