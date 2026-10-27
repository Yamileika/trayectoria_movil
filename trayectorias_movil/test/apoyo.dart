import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trayectorias_movil/datos/demo.dart';
import 'package:trayectorias_movil/datos/modelos.dart';
import 'package:trayectorias_movil/datos/repositorio.dart';
import 'package:trayectorias_movil/main.dart';
import 'package:trayectorias_movil/servicios/selector_archivos.dart';

/// Selector de archivos simulado: devuelve el archivo que indique la prueba.
class SelectorFalso implements SelectorArchivos {
  ArchivoElegido? siguiente = const ArchivoElegido(nombre: 'carta_laboral_1.pdf', tamano: 1258291);
  OrigenArchivo? ultimoOrigen;

  @override
  Future<ArchivoElegido?> elegir(OrigenArchivo origen) async {
    ultimoOrigen = origen;
    return siguiente;
  }
}

/// Monta la app en un teléfono de 390 × 844.
Future<(RepositorioDemo, SelectorFalso)> montar(
  WidgetTester tester, {
  bool conSesion = false,
  String correo = correoDemo,
  double alto = 844,
}) async {
  tester.view.physicalSize = Size(390 * 2, alto * 2);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  final repo = RepositorioDemo(retraso: Duration.zero);
  final selector = SelectorFalso();
  if (conSesion) await repo.iniciarSesion(correo, contrasenaDemo);
  await tester.pumpWidget(TrayectoriasApp(repositorio: repo, selector: selector));
  await tester.pumpAndSettle();
  return (repo, selector);
}

/// Toca un texto aunque esté fuera de la pantalla visible.
Future<void> tocar(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}
