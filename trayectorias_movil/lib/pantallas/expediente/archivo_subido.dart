import 'package:flutter/material.dart';

import '../../datos/modelos.dart';
import '../../estado/alcance.dart';
import '../../tema/colores.dart';
import '../../widgets/componentes.dart';
import '../principal.dart';
import 'expediente.dart';
import 'subir_documento.dart';

/// Confirmación después de subir un documento.
class ArchivoSubido extends StatelessWidget {
  const ArchivoSubido({super.key, required this.requisito, required this.archivo});

  final Requisito requisito;
  final ArchivoCargado archivo;

  @override
  Widget build(BuildContext context) {
    final repo = context.repositorio;
    final avance = repo.avancePropio;
    final siguiente = repo.expediente
        .where((f) => f.requisito.responsable == Responsable.docente && f.estado == EstadoDocumento.pendiente)
        .firstOrNull;
    final nombre = requisito.corto[0].toLowerCase() + requisito.corto.substring(1);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colores.verde, width: 5),
                ),
                child: const Icon(Icons.check, size: 64, color: Colores.verdeTexto),
              ),
              const SizedBox(height: 22),
              Semantics(
                header: true,
                liveRegion: true,
                child: Text('¡Listo, ${repo.docente.primerNombre}!', style: Theme.of(context).textTheme.headlineSmall),
              ),
              const SizedBox(height: 8),
              Text(
                'Tu $nombre se subió como versión ${archivo.version}. '
                'Tu avance ahora es ${avance.cargados} de ${avance.aplicables}.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              Tarjeta(
                color: Colores.verdeSuave,
                destacada: true,
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text('Tu avance', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                        Text('${avance.porcentaje}%', style: const TextStyle(fontWeight: FontWeight.w800)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    BarraAvance(fraccion: avance.fraccion),
                  ],
                ),
              ),
              const Spacer(flex: 2),
              if (siguiente != null) ...[
                FilledButton(
                  onPressed: () => Navigator.of(
                    context,
                  ).pushReplacement(MaterialPageRoute(builder: (_) => SubirDocumento(requisito: siguiente.requisito))),
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                  child: const Text('Subir otro documento'),
                ),
                const SizedBox(height: 12),
              ],
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Principal.irA(context, Pestana.expediente, vista: VistaExpediente.porSubir);
                },
                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(46)),
                child: const Text('Volver a mi expediente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
