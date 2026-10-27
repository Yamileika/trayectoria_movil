import 'package:flutter/widgets.dart';

import '../datos/repositorio.dart';
import '../servicios/selector_archivos.dart';

/// Hace disponibles el repositorio y el selector de archivos en todo el
/// árbol, y reconstruye a quien los use cuando cambian los datos.
class Alcance extends InheritedNotifier<Repositorio> {
  const Alcance({super.key, required Repositorio repositorio, required this.selector, required super.child})
    : super(notifier: repositorio);

  final SelectorArchivos selector;

  static Alcance _de(BuildContext context) => context.dependOnInheritedWidgetOfExactType<Alcance>()!;
}

extension AccesoAlcance on BuildContext {
  Repositorio get repositorio => Alcance._de(this).notifier!;
  SelectorArchivos get selector => Alcance._de(this).selector;
}
