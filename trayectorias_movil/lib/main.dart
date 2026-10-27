import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'datos/repositorio.dart';
import 'estado/alcance.dart';
import 'pantallas/acceso/inicio_sesion.dart';
import 'pantallas/principal.dart';
import 'servicios/selector_archivos.dart';
import 'tema/tema.dart';

void main() => runApp(TrayectoriasApp(repositorio: RepositorioDemo(), selector: SelectorArchivosDispositivo()));

class TrayectoriasApp extends StatelessWidget {
  const TrayectoriasApp({super.key, required this.repositorio, required this.selector});

  final Repositorio repositorio;
  final SelectorArchivos selector;

  @override
  Widget build(BuildContext context) {
    return Alcance(
      repositorio: repositorio,
      selector: selector,
      child: MaterialApp(
        title: 'Trayectorias Docentes',
        debugShowCheckedModeBanner: false,
        theme: crearTema(),
        locale: const Locale('es', 'MX'),
        supportedLocales: const [Locale('es', 'MX')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: const _Raiz(),
      ),
    );
  }
}

class _Raiz extends StatelessWidget {
  const _Raiz();

  @override
  Widget build(BuildContext context) =>
      context.repositorio.conSesion ? Principal(key: Principal.clave) : const InicioSesion();
}
