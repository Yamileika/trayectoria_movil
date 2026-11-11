import 'package:flutter_test/flutter_test.dart';
import 'package:trayectorias_movil/datos/catalogo.dart';
import 'package:trayectorias_movil/datos/demo.dart';
import 'package:trayectorias_movil/datos/modelos.dart';
import 'package:trayectorias_movil/datos/repositorio.dart';
import 'package:trayectorias_movil/widgets/componentes.dart';

void main() {
  RepositorioDemo nuevo() => RepositorioDemo(retraso: Duration.zero);
  const pdf = ArchivoElegido(nombre: 'titulo.pdf', tamano: 500000);

  group('Docente', () {
    test('toma las iniciales de las dos primeras palabras del nombre', () {
      expect(docenteDemo.iniciales, 'ML');
      expect(docenteActivoDemo.iniciales, 'CR');
    });

    test('el primer nombre es la primera palabra', () {
      expect(docenteDemo.primerNombre, 'María');
    });

    test('solo el profesor de tiempo completo es PTC', () {
      expect(docenteDemo.esPtc, isTrue);
      const asignatura = Docente(
        id: 'ana',
        nombre: 'Ana Pérez',
        correoAcceso: 'ana@ejemplo.mx',
        departamento: 'TI',
        contratacion: Contratacion.asignatura,
        estado: EstadoDocente.activo,
        nacionalidad: Nacionalidad.mexicana,
      );
      expect(asignatura.esPtc, isFalse);
    });

    test('cambiar el contacto conserva los datos que asigna RH', () {
      final nuevoDocente = docenteActivoDemo.conContacto(const Contacto(telefono: '771 123 4567'));
      expect(nuevoDocente.contacto.telefono, '771 123 4567');
      expect(nuevoDocente.nomina, docenteActivoDemo.nomina);
      expect(nuevoDocente.correoInstitucional, docenteActivoDemo.correoInstitucional);
    });
  });

  group('Archivos', () {
    test('la extensión se lee sin importar mayúsculas', () {
      expect(const ArchivoElegido(nombre: 'Foto.JPEG', tamano: 1).extension, 'jpeg');
    });

    test('un archivo sin extensión se rechaza', () {
      expect(const ArchivoElegido(nombre: 'sinpunto', tamano: 1).problema, contains('no es PDF'));
    });

    test('un archivo de exactamente 2 MB sí se acepta', () {
      expect(const ArchivoElegido(nombre: 'a.pdf', tamano: 2 * 1024 * 1024).problema, isNull);
    });

    test('el tamaño se muestra en KB o MB', () {
      expect(tamanoLegible(512 * 1024), '512 KB');
      expect(tamanoLegible(1258291), '1.2 MB');
    });
  });

  group('Avance', () {
    test('sin documentos aplicables el avance es 0 % y no está completo', () {
      const avance = Avance(aplicables: 0, cargados: 0);
      expect(avance.porcentaje, 0);
      expect(avance.fraccion, 0);
      expect(avance.completo, isFalse);
    });

    test('calcula pendientes y porcentaje redondeado', () {
      const avance = Avance(aplicables: 14, cargados: 5);
      expect(avance.pendientes, 9);
      expect(avance.porcentaje, 36);
    });

    test('los documentos que no aplican no cuentan', () {
      final avance = Avance.de(nuevo().expediente);
      final noAplican = nuevo().expediente.where((f) => f.estado == EstadoDocumento.noAplica).length;
      expect(avance.aplicables, catalogo.length - noAplican);
    });
  });

  group('Requisitos', () {
    test('la tarjeta de residencia solo aplica a docentes extranjeros', () {
      final residencia = catalogo.firstWhere((r) => r.condicion == Nacionalidad.extranjera);
      expect(residencia.aplicaA(docenteDemo), isFalse);
    });

    test('el nombre corto usa el nombre completo si no tiene uno propio', () {
      for (final r in catalogo) {
        expect(r.corto, r.nombreCorto ?? r.nombre);
      }
    });
  });

  group('Expediente', () {
    test('la docente de nuevo ingreso empieza con 0 de 14 documentos propios', () {
      final avance = nuevo().avancePropio;
      expect(avance.cargados, 0);
      expect(avance.aplicables, 14);
    });

    test('reemplazar un documento crea la versión 2', () {
      final repo = nuevo();
      repo.subirDocumento(5, pdf);
      final segunda = repo.subirDocumento(5, pdf);
      expect(segunda.version, 2);
      expect(repo.expediente.firstWhere((f) => f.requisito.id == 5).actual?.version, 2);
    });

    test('el docente activo ya tiene su expediente propio completo', () async {
      final repo = nuevo();
      await repo.iniciarSesion(correoActivoDemo, contrasenaDemo);
      expect(repo.avancePropio.completo, isTrue);
    });
  });

  group('Cuenta', () {
    test('cambiar la contraseña exige la actual y luego entra con la nueva', () async {
      final repo = nuevo();
      expect(await repo.cambiarContrasena('mala', 'Nueva2026'), isNotNull);
      expect(await repo.cambiarContrasena(contrasenaDemo, 'Nueva2026'), isNull);
      expect(await repo.iniciarSesion(correoDemo, contrasenaDemo), isNotNull);
      expect(await repo.iniciarSesion(correoDemo, 'Nueva2026'), isNull);
    });

    test('cerrar sesión deja la cuenta sin sesión', () async {
      final repo = nuevo();
      await repo.iniciarSesion(correoDemo, contrasenaDemo);
      repo.cerrarSesion();
      expect(repo.conSesion, isFalse);
    });

    test('las preferencias cambian solo el valor indicado', () {
      final repo = nuevo();
      repo.actualizarPreferencias(repo.preferencias.copiar(resumenSemanal: true));
      expect(repo.preferencias.resumenSemanal, isTrue);
      expect(repo.preferencias.huella, isTrue);
    });
  });

  group('Carpeta personal', () {
    test('pide un nombre, valida el archivo y permite quitarlo', () {
      final repo = nuevo();
      expect(repo.agregarPersonal('   ', pdf), isNotNull);
      expect(repo.agregarPersonal('CURP', const ArchivoElegido(nombre: 'curp.docx', tamano: 1)), isNotNull);
      expect(repo.agregarPersonal('CURP', pdf), isNull);
      expect(repo.carpetaPersonal.single.tipo, 'CURP');
      repo.quitarPersonal(repo.carpetaPersonal.single.id);
      expect(repo.carpetaPersonal, isEmpty);
    });
  });
}
