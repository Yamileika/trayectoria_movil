import 'package:flutter/material.dart';

import '../../datos/modelos.dart';
import '../../estado/alcance.dart';
import '../../tema/colores.dart';
import '../../widgets/cabecera.dart';
import '../../widgets/componentes.dart';
import '../expediente/expediente.dart';
import '../expediente/subir_documento.dart';
import '../mas/documentos.dart';
import '../mas/publicaciones.dart';
import '../principal.dart';
import 'notificaciones.dart';

/// Inicio. Cambia según el estado del docente: en nuevo ingreso muestra
/// su avance y los documentos por subir; ya activo, su trayectoria.
class Inicio extends StatelessWidget {
  const Inicio({super.key});

  @override
  Widget build(BuildContext context) =>
      context.repositorio.docente.estado == EstadoDocente.activo ? const _InicioActivo() : const _InicioNuevoIngreso();
}

/// Inicio de nuevo ingreso: avance personal, documentos que sube el docente y accesos.
class _InicioNuevoIngreso extends StatelessWidget {
  const _InicioNuevoIngreso();

  static const _fondos = [Colores.turquesaSuave, Colores.verdeSuave, Colores.ambarSuave];

  @override
  Widget build(BuildContext context) {
    final repo = context.repositorio;
    final docente = repo.docente;
    final avance = repo.avancePropio;
    final pendientes = repo.expediente
        .where((f) => f.requisito.responsable == Responsable.docente && f.estado == EstadoDocumento.pendiente)
        .take(3)
        .toList();

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          CabeceraMovil(
            encabezado: PerfilCabecera(
              iniciales: docente.iniciales,
              arriba: 'Docente',
              abajo: 'Hola, ${docente.primerNombre}.',
              grande: false,
              accion: _Campana(nuevos: repo.avisos.length),
            ),
            pie: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    AnilloAvance(
                      fraccion: avance.fraccion,
                      texto: '${avance.cargados}/${avance.aplicables}',
                      fondo: Colores.blanco.withValues(alpha: 0.15),
                      colorTexto: Colores.blanco,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TU AVANCE PERSONAL',
                            style: TextStyle(
                              color: Colores.verdeSobreMarino,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            avance.completo
                                ? 'Ya subiste todos tus documentos de ingreso'
                                : 'Completa tus documentos de nuevo ingreso',
                            style: const TextStyle(color: Colores.blanco, fontWeight: FontWeight.w800, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: () => Principal.irA(context, Pestana.expediente, vista: VistaExpediente.porSubir),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Text('Subir mis documentos'), SizedBox(width: 8), Icon(Icons.arrow_forward, size: 18)],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: Text('Estos los subes tú', style: Theme.of(context).textTheme.titleLarge)),
                    if (!avance.completo) Insignia('${avance.pendientes} por subir', fuerte: true),
                  ],
                ),
                const SizedBox(height: 12),
                if (pendientes.isEmpty)
                  const Tarjeta(
                    color: Colores.verdeSuave,
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colores.verdeTexto),
                        SizedBox(width: 10),
                        Expanded(child: Text('No tienes documentos pendientes. ¡Gracias!')),
                      ],
                    ),
                  ),
                for (final (i, fila) in pendientes.indexed) ...[
                  Tarjeta(
                    color: _fondos[i % _fondos.length],
                    destacada: true,
                    child: Row(
                      children: [
                        const CajaIcono(Icons.description_outlined, fondo: Colores.blanco),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(fila.requisito.corto, style: const TextStyle(fontWeight: FontWeight.w700)),
                              Text('PDF, JPG o PNG', style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ),
                        IconButton.filled(
                          tooltip: 'Subir ${fila.requisito.corto}',
                          onPressed: () => abrirCompleta(context, SubirDocumento(requisito: fila.requisito)),
                          style: IconButton.styleFrom(
                            backgroundColor: Colores.marino,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                            minimumSize: const Size(44, 40),
                          ),
                          icon: const Icon(Icons.upload, color: Colores.blanco, size: 20),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                const SizedBox(height: 4),
                const _Accesos(),
                const AvisoSimulado(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Campana extends StatelessWidget {
  const _Campana({required this.nuevos});

  final int nuevos;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton.filled(
          tooltip: 'Notificaciones, $nuevos nuevas',
          onPressed: () => abrirCompleta(context, const Notificaciones()),
          style: IconButton.styleFrom(
            backgroundColor: Colores.blanco.withValues(alpha: 0.14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            minimumSize: const Size(44, 44),
          ),
          icon: const Icon(Icons.notifications_none, color: Colores.blanco),
        ),
        if (nuevos > 0)
          const Positioned(
            right: 9,
            top: 9,
            child: SizedBox.square(
              dimension: 9,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Colores.ambar, shape: BoxShape.circle),
              ),
            ),
          ),
      ],
    );
  }
}

class _Acceso extends StatelessWidget {
  const _Acceso({required this.icono, required this.texto, required this.fondo, required this.alTocar});

  final IconData icono;
  final String texto;
  final Color fondo;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    return Tarjeta(
      alTocar: alTocar,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          CajaIcono(icono, fondo: fondo, tamano: 34),
          const SizedBox(width: 10),
          Expanded(
            child: Text(texto, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

/// Accesos rápidos que comparten ambos inicios.
class _Accesos extends StatelessWidget {
  const _Accesos();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.6,
      children: [
        _Acceso(
          icono: Icons.description_outlined,
          texto: 'Mis archivos',
          fondo: Colores.turquesaSuave,
          alTocar: () => Principal.irA(context, Pestana.expediente, vista: VistaExpediente.cargados),
        ),
        _Acceso(
          icono: Icons.person_outline,
          texto: 'Trayectoria',
          fondo: Colores.ambarSuave,
          alTocar: () => Principal.irA(context, Pestana.trayectoria),
        ),
        _Acceso(
          icono: Icons.article_outlined,
          texto: 'Mi currículum',
          fondo: Colores.turquesaSuave,
          alTocar: () => abrir(context, const Documentos()),
        ),
        _Acceso(
          icono: Icons.menu_book_outlined,
          texto: 'Publicaciones',
          fondo: Colores.turquesaSuave,
          alTocar: () => abrir(context, const Publicaciones()),
        ),
      ],
    );
  }
}

/// Inicio de un docente activo: ya completó su expediente de ingreso, así
/// que el foco pasa a mantener al día su trayectoria.
class _InicioActivo extends StatelessWidget {
  const _InicioActivo();

  @override
  Widget build(BuildContext context) {
    final repo = context.repositorio;
    final docente = repo.docente;
    final publicaciones = repo.publicaciones.where((p) => esRegistrada(repo, p)).length;
    final sugerencias = repo.publicaciones.where((p) => esSugerenciaPendiente(repo, p)).length;
    final avisos = repo.avisos.take(2).toList();

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          CabeceraMovil(
            encabezado: PerfilCabecera(
              iniciales: docente.iniciales,
              arriba: 'Docente activo',
              abajo: 'Hola, ${docente.primerNombre}.',
              grande: false,
              accion: _Campana(nuevos: repo.avisos.length),
            ),
            pie: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Row(
                  children: [
                    SizedBox.square(
                      dimension: 44,
                      child: DecoratedBox(
                        decoration: BoxDecoration(color: Colores.verde, shape: BoxShape.circle),
                        child: Icon(Icons.check, color: Colores.blanco),
                      ),
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TU EXPEDIENTE',
                            style: TextStyle(
                              color: Colores.verdeSobreMarino,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Expediente de ingreso completo',
                            style: TextStyle(color: Colores.blanco, fontWeight: FontWeight.w800, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _Cifra(valor: repo.trayectoria.length, texto: 'Registros'),
                    const SizedBox(width: 8),
                    _Cifra(valor: publicaciones, texto: 'Publicaciones'),
                    if (docente.esPtc) ...[
                      const SizedBox(width: 8),
                      _Cifra(valor: repo.proyectos.length, texto: 'Proyectos'),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => Principal.irA(context, Pestana.trayectoria),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Actualizar mi trayectoria'),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (sugerencias > 0) ...[
                  Row(
                    children: [
                      Expanded(child: Text('Por confirmar', style: Theme.of(context).textTheme.titleLarge)),
                      Insignia(sugerencias == 1 ? '1 sugerencia' : '$sugerencias sugerencias', fuerte: true),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Tarjeta(
                    color: Colores.ambarSuave,
                    destacada: true,
                    alTocar: () => abrir(context, const Publicaciones()),
                    child: Row(
                      children: [
                        const CajaIcono(Icons.menu_book_outlined, fondo: Colores.blanco),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sugerencias == 1
                                    ? 'Encontramos 1 publicación que podría ser tuya'
                                    : 'Encontramos $sugerencias publicaciones que podrían ser tuyas',
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                              Text(
                                'Confirma si son tuyas para agregarlas',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colores.marino),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
                Row(
                  children: [
                    Expanded(child: Text('Avisos recientes', style: Theme.of(context).textTheme.titleLarge)),
                    TextButton(
                      onPressed: () => abrirCompleta(context, const Notificaciones()),
                      child: const Text('Ver todos'),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                for (final aviso in avisos) ...[
                  Tarjeta(
                    child: Row(
                      children: [
                        CajaIcono(Notificaciones.iconoAviso(aviso.tipo), fondo: Notificaciones.fondoAviso(aviso.tipo)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(aviso.titulo, style: const TextStyle(fontWeight: FontWeight.w700)),
                              Text(aviso.detalle, style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                const SizedBox(height: 8),
                const _Accesos(),
                const AvisoSimulado(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Cifra pequeña sobre la cabecera marino.
class _Cifra extends StatelessWidget {
  const _Cifra({required this.valor, required this.texto});

  final int valor;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colores.blanco.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              '$valor',
              style: const TextStyle(color: Colores.blanco, fontSize: 20, fontWeight: FontWeight.w800),
            ),
            Text(texto, style: const TextStyle(color: Colores.lilaSobreMarino, fontSize: 11.5)),
          ],
        ),
      ),
    );
  }
}
