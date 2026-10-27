import 'package:flutter/material.dart';

import '../../datos/modelos.dart';
import '../../estado/alcance.dart';
import '../../servicios/selector_archivos.dart';
import '../../tema/colores.dart';
import '../../widgets/cabecera.dart';
import '../../widgets/componentes.dart';
import 'archivo_subido.dart';

/// Subir documento: foto, galería o archivo; PDF, JPG o PNG de hasta 2 MB.
class SubirDocumento extends StatefulWidget {
  const SubirDocumento({super.key, required this.requisito});

  final Requisito requisito;

  @override
  State<SubirDocumento> createState() => _SubirDocumentoState();
}

class _SubirDocumentoState extends State<SubirDocumento> {
  ArchivoElegido? _archivo;
  String? _problema;

  Future<void> _elegir(OrigenArchivo origen) async {
    final elegido = await context.selector.elegir(origen);
    if (elegido == null || !mounted) return;
    setState(() {
      _problema = elegido.problema;
      _archivo = _problema == null ? elegido : null;
    });
  }

  void _subir() {
    final cargado = context.repositorio.subirDocumento(widget.requisito.id, _archivo!);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ArchivoSubido(requisito: widget.requisito, archivo: cargado),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final instrucciones = widget.requisito.instrucciones?.split('.').first;
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          CabeceraMovil(
            volver: true,
            etiqueta: 'Subir archivo',
            titulo: widget.requisito.corto,
            subtitulo: instrucciones ?? widget.requisito.categoria?.etiqueta,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Tarjeta(
                  color: Colores.turquesaSuave,
                  destacada: true,
                  padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
                  child: Column(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colores.blanco,
                          border: Border.all(color: Colores.marino, width: 1.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.upload, color: Colores.marino),
                      ),
                      const SizedBox(height: 10),
                      const Text('Elige cómo subirlo', style: TextStyle(fontWeight: FontWeight.w800)),
                      const Text('PDF, JPG o PNG · máx. 2 MB'),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: () => _elegir(OrigenArchivo.camara),
                  style: FilledButton.styleFrom(backgroundColor: Colores.marino, alignment: Alignment.centerLeft),
                  icon: const Icon(Icons.photo_camera_outlined, size: 20),
                  label: const Text('Tomar foto'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _elegir(OrigenArchivo.galeria),
                  style: OutlinedButton.styleFrom(alignment: Alignment.centerLeft),
                  icon: const Icon(Icons.image_outlined, size: 20),
                  label: const Text('Elegir de la galería'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _elegir(OrigenArchivo.archivos),
                  style: OutlinedButton.styleFrom(alignment: Alignment.centerLeft),
                  icon: const Icon(Icons.description_outlined, size: 20),
                  label: const Text('Elegir archivo'),
                ),
                const SizedBox(height: 14),
                if (_archivo != null)
                  Tarjeta(
                    child: Row(
                      children: [
                        const CajaIcono(Icons.description_outlined, fondo: Colores.verdeSuave),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_archivo!.nombre, style: const TextStyle(fontWeight: FontWeight.w700)),
                              Text(tamanoLegible(_archivo!.tamano), style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ),
                        const Insignia('Listo', tono: TonoInsignia.listo, icono: Icons.check),
                      ],
                    ),
                  ),
                if (_problema != null)
                  Semantics(
                    liveRegion: true,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colores.errorSuave,
                        border: Border.all(color: Colores.error),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _problema!,
                            style: const TextStyle(color: Colores.errorTexto, fontWeight: FontWeight.w800),
                          ),
                          Text(
                            _problema!.contains('2 MB')
                                ? 'Reduce su tamaño e inténtalo de nuevo.'
                                : 'Elige un archivo PDF, JPG o PNG.',
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BotonesInferiores(
        principal: FilledButton.icon(
          onPressed: _archivo == null ? null : _subir,
          icon: const Icon(Icons.upload, size: 18),
          label: const Text('Subir archivo'),
        ),
      ),
    );
  }
}
