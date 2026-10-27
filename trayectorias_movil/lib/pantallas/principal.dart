import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../estado/alcance.dart';
import '../tema/colores.dart';
import 'expediente/expediente.dart';
import 'inicio/inicio.dart';
import 'mas/mas.dart';
import 'proyectos/proyectos.dart';
import 'trayectoria/trayectoria.dart';

enum Pestana {
  inicio('Inicio', Icons.home_outlined),
  expediente('Expediente', Icons.description_outlined),
  trayectoria('Trayectoria', Icons.person_outline),
  proyectos('Proyectos', Icons.work_outline),
  mas('Más', Icons.menu);

  const Pestana(this.etiqueta, this.icono);
  final String etiqueta;
  final IconData icono;
}

/// Estructura con la barra inferior. Cada pestaña tiene su propia pila de
/// pantallas, así que las secciones de «Más» conservan la barra.
class Principal extends StatefulWidget {
  const Principal({super.key});

  /// Clave de la estructura activa; permite cambiar de pestaña también
  /// desde pantallas completas (formularios, confirmaciones).
  static final clave = GlobalKey<State<Principal>>();

  /// Cambia de pestaña desde cualquier pantalla.
  static void irA(BuildContext context, Pestana pestana, {VistaExpediente? vista}) =>
      (clave.currentState as _PrincipalState?)?._irA(pestana, vista: vista);

  @override
  State<Principal> createState() => _PrincipalState();
}

class _PrincipalState extends State<Principal> {
  var _actual = Pestana.inicio;
  final _navegadores = {for (final p in Pestana.values) p: GlobalKey<NavigatorState>()};
  final _vistaExpediente = ValueNotifier(VistaExpediente.porSubir);

  @override
  void dispose() {
    _vistaExpediente.dispose();
    super.dispose();
  }

  void _irA(Pestana pestana, {VistaExpediente? vista}) {
    if (vista != null) _vistaExpediente.value = vista;
    if (pestana == _actual) {
      _navegadores[pestana]!.currentState?.popUntil((r) => r.isFirst);
    }
    setState(() => _actual = pestana);
  }

  Widget _raiz(Pestana p) => switch (p) {
    Pestana.inicio => const Inicio(),
    Pestana.expediente => Expediente(vista: _vistaExpediente),
    Pestana.trayectoria => const Trayectoria(),
    Pestana.proyectos => const Proyectos(),
    Pestana.mas => const Mas(),
  };

  @override
  Widget build(BuildContext context) {
    final pestanas = [
      for (final p in Pestana.values)
        if (p != Pestana.proyectos || context.repositorio.docente.esPtc) p,
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (hecho, _) async {
        if (hecho) return;
        final navegador = _navegadores[_actual]!.currentState;
        if (navegador != null && await navegador.maybePop()) return;
        if (_actual != Pestana.inicio) {
          setState(() => _actual = Pestana.inicio);
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: pestanas.indexOf(_actual),
          children: [
            for (final p in pestanas)
              HeroControllerScope.none(
                child: Navigator(
                  key: _navegadores[p],
                  onGenerateRoute: (_) => MaterialPageRoute(builder: (_) => _raiz(p)),
                ),
              ),
          ],
        ),
        bottomNavigationBar: _BarraInferior(pestanas: pestanas, actual: _actual, alElegir: _irA),
      ),
    );
  }
}

class _BarraInferior extends StatelessWidget {
  const _BarraInferior({required this.pestanas, required this.actual, required this.alElegir});

  final List<Pestana> pestanas;
  final Pestana actual;
  final ValueChanged<Pestana> alElegir;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colores.blanco,
        border: Border(top: BorderSide(color: Colores.bordeSuave)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 6, 6, 8),
          child: Row(
            children: [
              for (final p in pestanas)
                Expanded(
                  child: Semantics(
                    selected: p == actual,
                    button: true,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => alElegir(p),
                      child: SizedBox(
                        height: 52,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                              decoration: BoxDecoration(
                                color: p == actual ? Colores.verdeSuave : Colors.transparent,
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: Icon(p.icono, color: p == actual ? Colores.marino : Colores.apoyo, size: 22),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              p.etiqueta,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: p == actual ? FontWeight.w800 : FontWeight.w600,
                                color: p == actual ? Colores.marino : Colores.apoyo,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Abre una pantalla dentro de la pestaña actual (conserva la barra inferior).
Future<T?> abrir<T>(BuildContext context, Widget pantalla) =>
    Navigator.of(context).push<T>(MaterialPageRoute(builder: (_) => pantalla));

/// Abre una pantalla completa, sin barra inferior (formularios y detalles).
Future<T?> abrirCompleta<T>(BuildContext context, Widget pantalla) =>
    Navigator.of(context, rootNavigator: true).push<T>(MaterialPageRoute(builder: (_) => pantalla));
