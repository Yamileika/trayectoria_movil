import 'package:flutter_test/flutter_test.dart';
import 'package:trayectorias_movil/datos/demo.dart';
import 'package:trayectorias_movil/datos/modelos.dart';
import 'package:trayectorias_movil/datos/repositorio.dart';
import 'package:trayectorias_movil/pantallas/expediente/explorador.dart';
import 'package:trayectorias_movil/pantallas/mas/publicaciones.dart';
import 'package:trayectorias_movil/pantallas/trayectoria/trayectoria.dart';
import 'package:trayectorias_movil/widgets/archivos.dart';
import 'package:trayectorias_movil/widgets/componentes.dart';

/// Pruebas unitarias de las funciones de apoyo: búsqueda, validación de
/// formularios, formatos, publicaciones, trayectoria y expediente.
void main() {
  RepositorioDemo nuevo() => RepositorioDemo(retraso: Duration.zero);
  const pdf = ArchivoElegido(nombre: 'evidencia.pdf', tamano: 300000);

  group('Búsqueda', () {
    test('normalizar quita acentos, la ñ y las mayúsculas', () {
      expect(normalizar('Formación ÁCADÉMICA'), 'formacion academica');
      expect(normalizar('Diseño'), 'diseno');
      expect(normalizar('Lingüística'), 'linguistica');
    });

    test('una búsqueda vacía coincide con todo', () {
      expect(coincide('', ['Currículum vitae']), isTrue);
      expect(coincide('   ', ['Acta de nacimiento']), isTrue);
    });

    test('las palabras pueden estar repartidas en varios campos', () {
      expect(coincide('maestria universidad', ['Maestría en Ciencias', 'Universidad de ejemplo']), isTrue);
      expect(coincide('doctorado', ['Maestría en Ciencias', 'Universidad de ejemplo']), isFalse);
    });
  });

  group('Formularios', () {
    test('un campo obligatorio rechaza nulos, vacíos y solo espacios', () {
      final validar = obligatorio();
      expect(validar(null), 'Este campo es obligatorio');
      expect(validar(''), 'Este campo es obligatorio');
      expect(validar('   '), 'Este campo es obligatorio');
      expect(validar('Inglés'), isNull);
    });

    test('respeta el límite de caracteres exacto', () {
      final validar = obligatorio(100);
      expect(validar('a' * 100), isNull);
      expect(validar('a' * 101), 'Máximo 100 caracteres');
    });
  });

  group('Formatos', () {
    test('tamanoLegible cambia de KB a MB justo en 1 MB', () {
      expect(tamanoLegible(1024 * 1024 - 1), '1024 KB');
      expect(tamanoLegible(1024 * 1024), '1.0 MB');
      expect(tamanoLegible(2 * 1024 * 1024), '2.0 MB');
    });

    test('tipoArchivo muestra la extensión en mayúsculas o vacío', () {
      expect(tipoArchivo('titulo_maestria.pdf'), 'PDF');
      expect(tipoArchivo('foto.final.jpg'), 'JPG');
      expect(tipoArchivo('sinextension'), '');
    });

    test('fechaCorta usa el mes abreviado en español', () {
      expect(fechaCorta(DateTime(2026, 1, 5)), '5 ene 2026');
      expect(fechaCorta(DateTime(2025, 12, 31)), '31 dic 2025');
    });
  });

  group('Archivos', () {
    test('acepta PNG y JPG aunque la extensión venga en mayúsculas', () {
      expect(const ArchivoElegido(nombre: 'INE.PNG', tamano: 1000).problema, isNull);
      expect(const ArchivoElegido(nombre: 'curp.Jpg', tamano: 1000).problema, isNull);
    });

    test('un byte más de 2 MB ya se rechaza', () {
      const grande = ArchivoElegido(nombre: 'acta.pdf', tamano: 2 * 1024 * 1024 + 1);
      expect(grande.problema, 'acta.pdf supera 2 MB');
    });

    test('subir un archivo no válido lanza error y no crea versión', () {
      final repo = nuevo();
      expect(
        () => repo.subirDocumento(6, const ArchivoElegido(nombre: 'cv.docx', tamano: 1000)),
        throwsArgumentError,
      );
      expect(repo.expediente.firstWhere((f) => f.requisito.id == 6).versiones, isEmpty);
    });
  });

  group('Publicaciones', () {
    test('la referencia sigue el formato autores (año). título. fuente.', () {
      expect(
        referencia(publicacionesDemo.first),
        'María López (2023). Detección de anomalías en redes. Revista de ejemplo.',
      );
    });

    test('una sugerencia marcada como ajena no cuenta como registrada', () {
      final repo = nuevo();
      final p3 = publicacionesDemo.firstWhere((p) => p.id == 'p3');
      expect(esSugerenciaPendiente(repo, p3), isTrue);
      repo.decidir('p3', DecisionSugerencia.ajena);
      expect(esRegistrada(repo, p3), isFalse);
      expect(esSugerenciaPendiente(repo, p3), isFalse);
    });

    test('las publicaciones que no son sugerencia siempre están registradas', () {
      final repo = nuevo();
      for (final p in publicacionesDemo.where((p) => !p.sugerencia)) {
        expect(esRegistrada(repo, p), isTrue);
      }
    });
  });

  group('Trayectoria', () {
    test('guardar un registro con id existente lo reemplaza sin duplicarlo', () {
      final repo = nuevo();
      final total = repo.trayectoria.length;
      final original = repo.trayectoria.firstWhere((r) => r.id == 'f1');
      repo.guardarRegistro(
        RegistroTrayectoria(
          id: 'f1',
          seccion: original.seccion,
          titulo: 'Doctorado en Ciencias',
          periodo: original.periodo,
          detalle: original.detalle,
        ),
      );
      expect(repo.trayectoria.length, total);
      expect(repo.trayectoria.firstWhere((r) => r.id == 'f1').titulo, 'Doctorado en Ciencias');
    });

    test('un registro nuevo aparece al principio de la lista', () {
      final repo = nuevo();
      repo.guardarRegistro(
        const RegistroTrayectoria(
          id: 'nuevo',
          seccion: SeccionTrayectoria.idiomas,
          titulo: 'Francés',
          periodo: '2026',
          detalle: 'Nivel B1',
        ),
      );
      expect(repo.trayectoria.first.id, 'nuevo');
    });

    test('el perfil completo sube al llenar un apartado vacío', () {
      final repo = nuevo();
      final antes = perfilCompleto(repo);
      final vacia = SeccionTrayectoria.values.firstWhere((s) => !repo.trayectoria.any((r) => r.seccion == s));
      repo.guardarRegistro(
        RegistroTrayectoria(id: 'x', seccion: vacia, titulo: 'Prueba', periodo: '2026', detalle: 'Detalle'),
      );
      expect(perfilCompleto(repo), closeTo(antes + 1 / SeccionTrayectoria.values.length, 1e-9));
      expect(perfilCompleto(repo), lessThanOrEqualTo(1));
    });

    test('un registro sin evidencia se marca como «Falta evidencia»', () {
      final repo = nuevo();
      repo.guardarRegistro(
        const RegistroTrayectoria(
          id: 'sin',
          seccion: SeccionTrayectoria.idiomas,
          titulo: 'Alemán',
          periodo: '2026',
          detalle: 'Nivel A2',
        ),
      );
      final elemento = elementosTrayectoria(repo).firstWhere((e) => e.id == 'registro-sin');
      expect(elemento.tipo, TipoElemento.faltaEvidencia);
      expect(elemento.detalle, 'Falta evidencia');
      expect(elemento.faltante, isTrue);
    });
  });

  group('Expediente', () {
    test('un pendiente de RH indica quién lo carga', () {
      final fila = nuevo().expediente.firstWhere((f) => f.requisito.id == 18);
      final elemento = elementoDeFila(fila);
      expect(elemento.tipo, TipoElemento.pendiente);
      expect(elemento.detalle, 'Pendiente · Lo carga Recursos Humanos');
    });

    test('el docente activo ve su carpeta personal y solo lo cargado', () async {
      final repo = nuevo();
      await repo.iniciarSesion(correoActivoDemo, contrasenaDemo);
      repo.agregarPersonal('CURP', pdf);
      final elementos = elementosActivo(repo);
      expect(elementos.where((e) => e.tipo == TipoElemento.personal).single.nombre, 'CURP');
      expect(elementos.where((e) => e.tipo == TipoElemento.pendiente), isEmpty);
      final cargados = repo.expediente.where((f) => f.estado == EstadoDocumento.cargado).length;
      expect(elementos.where((e) => e.tipo == TipoElemento.ingreso).length, cargados);
    });

    test('el correo se acepta con mayúsculas y espacios, y los avisos cambian por cuenta', () async {
      final repo = nuevo();
      expect(repo.avisos, avisosDemo);
      expect(await repo.iniciarSesion('  CARLOS@Ejemplo.mx ', contrasenaDemo), isNull);
      expect(repo.docente.id, 'carlos');
      expect(repo.avisos, avisosActivoDemo);
    });
  });
}
