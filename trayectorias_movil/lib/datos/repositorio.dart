import 'package:flutter/foundation.dart';

import 'catalogo.dart';
import 'demo.dart';
import 'modelos.dart';

/// Preferencias de Configuración (se guardarán en usuarios/{uid}.notificaciones).
class Preferencias {
  const Preferencias({this.huella = true, this.recordatorios = true, this.resumenSemanal = false});

  final bool huella;
  final bool recordatorios;
  final bool resumenSemanal;

  Preferencias copiar({bool? huella, bool? recordatorios, bool? resumenSemanal}) => Preferencias(
    huella: huella ?? this.huella,
    recordatorios: recordatorios ?? this.recordatorios,
    resumenSemanal: resumenSemanal ?? this.resumenSemanal,
  );
}

/// Acceso a los datos del docente que inició sesión. Las pantallas solo
/// conocen esta interfaz; la versión con Firebase sustituirá a
/// [RepositorioDemo] sin tocar la presentación.
abstract class Repositorio extends ChangeNotifier {
  /// Devuelve un mensaje de error o null si las credenciales son correctas.
  Future<String?> iniciarSesion(String correo, String contrasena);
  Future<void> recuperarContrasena(String correo);
  Future<String?> cambiarContrasena(String actual, String nueva);
  void cerrarSesion();

  bool get conSesion;
  Docente get docente;

  List<FilaExpediente> get expediente;
  ArchivoCargado subirDocumento(int requisitoId, ArchivoElegido archivo);

  List<RegistroTrayectoria> get trayectoria;
  void guardarRegistro(RegistroTrayectoria registro);

  List<Publicacion> get publicaciones;
  DecisionSugerencia decision(String publicacionId);
  void decidir(String publicacionId, DecisionSugerencia decision);

  List<Proyecto> get proyectos;
  List<Aviso> get avisos;

  /// Carpeta personal del docente (solo él la ve).
  List<ArchivoPersonal> get carpetaPersonal;

  /// Devuelve un mensaje de error o null si se guardó.
  String? agregarPersonal(String tipo, ArchivoElegido archivo);
  void quitarPersonal(String id);

  void actualizarContacto(Contacto contacto);

  Preferencias get preferencias;
  void actualizarPreferencias(Preferencias preferencias);

  /// Avance de los documentos que sube el docente.
  Avance get avancePropio => Avance.de(expediente.where((f) => f.requisito.responsable == Responsable.docente));
}

/// Implementación en memoria con datos simulados: los cambios duran
/// mientras la app está abierta.
class RepositorioDemo extends Repositorio {
  RepositorioDemo({this.retraso = const Duration(milliseconds: 400)}) {
    _cargarCuenta(docenteDemo);
  }

  static const _cuentas = {correoDemo: docenteDemo, correoActivoDemo: docenteActivoDemo};

  /// Prepara los datos simulados de la cuenta. El docente activo ya tiene
  /// todo su expediente de ingreso cargado.
  void _cargarCuenta(Docente docente) {
    _docente = docente;
    _archivos.clear();
    _trayectoria
      ..clear()
      ..addAll(trayectoriaDemo);
    _decisiones.clear();
    _personales.clear();
    final activo = docente.estado == EstadoDocente.activo;
    for (final requisito in catalogo) {
      final cargado = activo ? requisito.aplicaA(docente) : requisitosCargadosPorAdministracion.contains(requisito.id);
      if (!cargado) continue;
      _archivos[requisito.id] = [
        ArchivoCargado(
          nombre: '${_nombreArchivo(requisito.nombre)}.pdf',
          version: 1,
          subidoPor: requisito.responsable,
          subidoEn: activo ? DateTime(2025, 8, 20) : DateTime(2026, 10, 24),
          tamano: 350000,
        ),
      ];
    }
  }

  /// Simula la espera de la red.
  final Duration retraso;

  Future<void> _esperar() async {
    if (retraso > Duration.zero) await Future<void>.delayed(retraso);
  }

  var _conSesion = false;
  var _contrasena = contrasenaDemo;
  late Docente _docente;
  var _preferencias = const Preferencias();
  final _archivos = <int, List<ArchivoCargado>>{};
  final _trayectoria = [...trayectoriaDemo];
  final _decisiones = <String, DecisionSugerencia>{};
  final _personales = <ArchivoPersonal>[];

  static String _nombreArchivo(String texto) => texto
      .toLowerCase()
      .replaceAll(RegExp('[áä]'), 'a')
      .replaceAll(RegExp('[éë]'), 'e')
      .replaceAll(RegExp('[íï]'), 'i')
      .replaceAll(RegExp('[óö]'), 'o')
      .replaceAll(RegExp('[úü]'), 'u')
      .replaceAll('ñ', 'n')
      .replaceAll(RegExp('[^a-z0-9]+'), '_');

  @override
  Future<String?> iniciarSesion(String correo, String contrasena) async {
    await _esperar();
    final docente = _cuentas[correo.trim().toLowerCase()];
    if (docente == null || contrasena != _contrasena) {
      return 'Correo o contraseña incorrectos.';
    }
    if (docente.id != _docente.id) _cargarCuenta(docente);
    _conSesion = true;
    notifyListeners();
    return null;
  }

  @override
  Future<void> recuperarContrasena(String correo) => _esperar();

  @override
  Future<String?> cambiarContrasena(String actual, String nueva) async {
    await _esperar();
    if (actual != _contrasena) return 'La contraseña actual no es correcta.';
    _contrasena = nueva;
    return null;
  }

  @override
  void cerrarSesion() {
    _conSesion = false;
    notifyListeners();
  }

  @override
  bool get conSesion => _conSesion;

  @override
  Docente get docente => _docente;

  @override
  List<FilaExpediente> get expediente => [
    for (final requisito in catalogo)
      FilaExpediente(
        requisito: requisito,
        versiones: List.unmodifiable(_archivos[requisito.id] ?? const []),
        estado: !requisito.aplicaA(_docente)
            ? EstadoDocumento.noAplica
            : (_archivos[requisito.id]?.isNotEmpty ?? false)
            ? EstadoDocumento.cargado
            : EstadoDocumento.pendiente,
      ),
  ];

  @override
  ArchivoCargado subirDocumento(int requisitoId, ArchivoElegido archivo) {
    final requisito = catalogo.firstWhere((r) => r.id == requisitoId);
    if (requisito.responsable != Responsable.docente) {
      throw StateError('El docente no sube «${requisito.nombre}».');
    }
    final problema = archivo.problema;
    if (problema != null) throw ArgumentError(problema);
    final versiones = _archivos.putIfAbsent(requisitoId, () => []);
    final cargado = ArchivoCargado(
      nombre: archivo.nombre,
      version: versiones.length + 1,
      subidoPor: Responsable.docente,
      subidoEn: DateTime.now(),
      tamano: archivo.tamano,
    );
    versiones.add(cargado);
    notifyListeners();
    return cargado;
  }

  @override
  List<RegistroTrayectoria> get trayectoria => List.unmodifiable(_trayectoria);

  @override
  void guardarRegistro(RegistroTrayectoria registro) {
    final i = _trayectoria.indexWhere((r) => r.id == registro.id);
    i >= 0 ? _trayectoria[i] = registro : _trayectoria.insert(0, registro);
    notifyListeners();
  }

  @override
  List<Publicacion> get publicaciones => publicacionesDemo;

  @override
  DecisionSugerencia decision(String publicacionId) => _decisiones[publicacionId] ?? DecisionSugerencia.pendiente;

  @override
  void decidir(String publicacionId, DecisionSugerencia decision) {
    _decisiones[publicacionId] = decision;
    notifyListeners();
  }

  @override
  List<Proyecto> get proyectos => _docente.esPtc ? proyectosDemo : const [];

  @override
  List<Aviso> get avisos => _docente.estado == EstadoDocente.activo ? avisosActivoDemo : avisosDemo;

  @override
  List<ArchivoPersonal> get carpetaPersonal => List.unmodifiable(_personales);

  @override
  String? agregarPersonal(String tipo, ArchivoElegido archivo) {
    final nombre = tipo.trim();
    if (nombre.isEmpty) return 'Escribe qué documento es.';
    final problema = archivo.problema;
    if (problema != null) return problema;
    _personales.insert(
      0,
      ArchivoPersonal(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        tipo: nombre.length > 120 ? nombre.substring(0, 120) : nombre,
        archivo: archivo,
        fecha: DateTime.now(),
      ),
    );
    notifyListeners();
    return null;
  }

  @override
  void quitarPersonal(String id) {
    _personales.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  @override
  void actualizarContacto(Contacto contacto) {
    _docente = _docente.conContacto(contacto);
    notifyListeners();
  }

  @override
  Preferencias get preferencias => _preferencias;

  @override
  void actualizarPreferencias(Preferencias preferencias) {
    _preferencias = preferencias;
    notifyListeners();
  }
}
