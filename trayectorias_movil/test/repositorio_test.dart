import 'package:flutter_test/flutter_test.dart';
import 'package:trayectorias_movil/datos/catalogo.dart';
import 'package:trayectorias_movil/datos/demo.dart';
import 'package:trayectorias_movil/datos/modelos.dart';
import 'package:trayectorias_movil/datos/repositorio.dart';
import 'package:trayectorias_movil/widgets/componentes.dart';

void main() {
  RepositorioDemo nuevo() => RepositorioDemo(retraso: Duration.zero);
  const pdf = ArchivoElegido(nombre: 'carta.pdf', tamano: 400000);

  test('el catálogo tiene 24 requisitos: 4 de Administración, 14 del docente y 6 de RH', () {
    expect(catalogo, hasLength(24));
    expect(catalogo.where((r) => r.responsable == Responsable.administracion), hasLength(4));
    expect(catalogo.where((r) => r.responsable == Responsable.docente), hasLength(14));
    expect(catalogo.where((r) => r.responsable == Responsable.rh), hasLength(6));
  });

  test('con el retraso de red simulado, como en la app, la sesión termina', () async {
    final repo = RepositorioDemo(retraso: const Duration(milliseconds: 20));
    final error = await repo.iniciarSesion(correoDemo, contrasenaDemo).timeout(const Duration(seconds: 2));
    expect(error, isNull);
    expect(repo.conSesion, isTrue);
  });

  test('inicia sesión solo con las credenciales correctas', () async {
    final repo = nuevo();
    expect(await repo.iniciarSesion(correoDemo, 'otra'), isNotNull);
    expect(repo.conSesion, isFalse);
    expect(await repo.iniciarSesion(' MARIA@ejemplo.mx ', contrasenaDemo), isNull);
    expect(repo.conSesion, isTrue);
  });

  test('a una docente mexicana no le aplican tarjeta de residencia ni naturalización', () {
    final rh = nuevo().expediente.where((f) => f.requisito.responsable == Responsable.rh);
    expect(Avance.de(rh).aplicables, 4);
  });

  test('las dos cartas son independientes y reemplazar no suma avance', () {
    final repo = nuevo();
    repo.subirDocumento(5, pdf);
    expect(repo.expediente.firstWhere((f) => f.requisito.id == 24).estado, EstadoDocumento.pendiente);
    final v2 = repo.subirDocumento(5, pdf);
    expect(v2.version, 2);
    expect(repo.avancePropio.cargados, 1);
    expect(repo.avancePropio.aplicables, 14);
  });

  test('el docente no sube documentos de Administración ni de RH', () {
    expect(() => nuevo().subirDocumento(1, pdf), throwsStateError);
    expect(() => nuevo().subirDocumento(18, pdf), throwsStateError);
  });

  test('solo se aceptan PDF, JPG o PNG de hasta 2 MB', () {
    expect(const ArchivoElegido(nombre: 'a.PDF', tamano: 100).problema, isNull);
    expect(const ArchivoElegido(nombre: 'a.png', tamano: 3 * 1024 * 1024).problema, contains('2 MB'));
    expect(const ArchivoElegido(nombre: 'a.docx', tamano: 100).problema, contains('no es PDF'));
    expect(() => nuevo().subirDocumento(5, const ArchivoElegido(nombre: 'a.docx', tamano: 1)), throwsArgumentError);
  });

  test('confirmar una sugerencia la vuelve publicación registrada', () {
    final repo = nuevo();
    repo.decidir('p3', DecisionSugerencia.mia);
    expect(repo.decision('p3'), DecisionSugerencia.mia);
    expect(repo.decision('p4'), DecisionSugerencia.pendiente);
  });

  test('la búsqueda admite varias palabras en cualquier orden y sin acentos', () {
    expect(coincide('cedula profesional', ['Cédula profesional']), isTrue);
    expect(coincide('carta 2', ['Carta de recomendación laboral 1']), isFalse);
  });
}
