import 'package:flutter/material.dart';

import '../../estado/alcance.dart';
import '../../tema/colores.dart';
import '../../widgets/componentes.dart';

/// Panel inferior para confirmar el cierre de sesión.
Future<void> confirmarCierre(BuildContext context) async {
  final repo = context.repositorio;
  final confirmar = await showModalBottomSheet<bool>(
    context: context,
    useRootNavigator: true,
    barrierColor: Colores.marino.withValues(alpha: 0.6),
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: CajaIcono(Icons.logout, fondo: Colores.ambarSuave, tamano: 48),
            ),
            const SizedBox(height: 14),
            Text('¿Cerrar sesión?', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 22)),
            const SizedBox(height: 8),
            const Text('Saldrás de tu cuenta en este teléfono. Tus archivos se conservan.'),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(backgroundColor: Colores.marino, minimumSize: const Size.fromHeight(50)),
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Cerrar sesión'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(46)),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    ),
  );
  if (confirmar == true) repo.cerrarSesion();
}
