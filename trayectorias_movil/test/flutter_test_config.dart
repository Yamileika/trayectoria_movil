import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Carga las fuentes reales para que las pruebas midan el texto como en el
/// teléfono (sin esto se usa una fuente de cuadros más ancha).
Future<void> testExecutable(FutureOr<void> Function() pruebas) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final nunito = FontLoader('NunitoSans');
  for (final peso in [400, 600, 700, 800]) {
    nunito.addFont(rootBundle.load('assets/fonts/NunitoSans-$peso.ttf'));
  }
  await nunito.load();

  final sdk = Platform.environment['FLUTTER_ROOT'];
  final iconos = File('$sdk/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
  if (sdk != null && iconos.existsSync()) {
    final cargador = FontLoader('MaterialIcons')..addFont(Future.value(ByteData.sublistView(iconos.readAsBytesSync())));
    await cargador.load();
  }
  await pruebas();
}
