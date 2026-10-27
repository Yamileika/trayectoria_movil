import 'package:flutter/material.dart';

import '../../datos/modelos.dart';
import '../../estado/alcance.dart';
import '../../tema/colores.dart';
import '../../widgets/cabecera.dart';
import '../../widgets/componentes.dart';
import '../principal.dart';
import '../expediente/documentos_personales.dart';
import 'ayuda.dart';
import 'cerrar_sesion.dart';
import 'configuracion.dart';
import 'documentos.dart';
import 'indicadores.dart';
import 'informacion_general.dart';
import 'publicaciones.dart';

class Mas extends StatelessWidget {
  const Mas({super.key});

  @override
  Widget build(BuildContext context) {
    final docente = context.repositorio.docente;
    final opciones = [
      (
        Icons.menu_book_outlined,
        'Publicaciones',
        'Registradas y sugerencias',
        Colores.turquesaSuave,
        () => abrir(context, const Publicaciones()),
      ),
      (
        Icons.description_outlined,
        'Documentos',
        'Currículum y fichas',
        Colores.turquesaSuave,
        () => abrir(context, const Documentos()),
      ),
      // Los documentos personales son solo para el docente activo.
      if (docente.estado == EstadoDocente.activo)
        (
          Icons.lock_outline,
          'Mis documentos personales',
          'Solo tú los ves',
          Colores.lilaSuave,
          () => abrir(context, const DocumentosPersonales()),
        ),
      (Icons.bar_chart, 'Indicadores', 'Tu avance', Colores.ambarSuave, () => abrir(context, const Indicadores())),
      (
        Icons.person_outline,
        'Información general',
        'Contacto y semblanza',
        Colores.turquesaSuave,
        () => abrirCompleta(context, const InformacionGeneral()),
      ),
      (
        Icons.settings_outlined,
        'Configuración',
        'Cuenta, seguridad y avisos',
        Colores.turquesaSuave,
        () => abrir(context, const Configuracion()),
      ),
      (Icons.help_outline, 'Ayuda', 'Preguntas frecuentes', Colores.turquesaSuave, () => abrir(context, const Ayuda())),
    ];

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          CabeceraMovil(
            encabezado: PerfilCabecera(
              iniciales: docente.iniciales,
              arriba: docente.primerNombre,
              abajo: docente.correoAcceso,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                for (final (icono, titulo, descripcion, fondo, accion) in opciones) ...[
                  FilaMenu(icono: icono, titulo: titulo, descripcion: descripcion, fondoIcono: fondo, alTocar: accion),
                  const SizedBox(height: 12),
                ],
                FilaMenu(
                  icono: Icons.logout,
                  titulo: 'Cerrar sesión',
                  colorTitulo: Colores.errorTexto,
                  fondoIcono: Colores.ambarSuave,
                  alTocar: () => confirmarCierre(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
