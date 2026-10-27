import 'package:flutter/material.dart';

import '../../estado/alcance.dart';
import '../../tema/colores.dart';
import '../../widgets/cabecera.dart';
import '../../widgets/componentes.dart';
import '../principal.dart';
import 'cambiar_contrasena.dart';
import 'cerrar_sesion.dart';

class Configuracion extends StatelessWidget {
  const Configuracion({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.repositorio;
    final p = repo.preferencias;

    Widget interruptor(IconData icono, Color fondo, String titulo, bool valor, ValueChanged<bool> alCambiar) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: FilaMenu(
        icono: icono,
        titulo: titulo,
        fondoIcono: fondo,
        alTocar: () => alCambiar(!valor),
        final_: Switch(value: valor, onChanged: alCambiar),
      ),
    );

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const CabeceraMovil(
            volver: true,
            etiqueta: 'Configuración',
            titulo: 'Configuración',
            subtitulo: 'Cuenta y preferencias',
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilaMenu(
                  icono: Icons.shield_outlined,
                  titulo: 'Cambiar contraseña',
                  descripcion: 'Actualiza tu clave de acceso',
                  alTocar: () => abrirCompleta(context, const CambiarContrasena()),
                ),
                const SizedBox(height: 12),
                interruptor(
                  Icons.lock_outline,
                  Colores.verdeSuave,
                  'Entrar con huella',
                  p.huella,
                  (v) => repo.actualizarPreferencias(p.copiar(huella: v)),
                ),
                interruptor(
                  Icons.notifications_none,
                  Colores.ambarSuave,
                  'Recordatorios de documentos',
                  p.recordatorios,
                  (v) => repo.actualizarPreferencias(p.copiar(recordatorios: v)),
                ),
                interruptor(
                  Icons.mail_outline,
                  Colores.turquesaSuave,
                  'Resumen semanal por correo',
                  p.resumenSemanal,
                  (v) => repo.actualizarPreferencias(p.copiar(resumenSemanal: v)),
                ),
                const FilaMenu(icono: Icons.language, titulo: 'Idioma', descripcion: 'Español (México)', flecha: false),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () => confirmarCierre(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colores.errorTexto,
                    side: const BorderSide(color: Colores.error),
                  ),
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text('Cerrar sesión'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
