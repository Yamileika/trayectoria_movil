import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trayectorias_movil/datos/demo.dart';
import 'package:trayectorias_movil/datos/modelos.dart';

import 'apoyo.dart';

void main() {
  testWidgets('con credenciales incorrectas muestra el error y con las correctas entra al inicio', (tester) async {
    await montar(tester);
    await tester.enterText(find.byType(TextFormField).at(0), correoDemo);
    await tester.enterText(find.byType(TextFormField).at(1), 'equivocada');
    await tocar(tester, find.text('Iniciar sesión').last);
    expect(find.text('Correo o contraseña incorrectos.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(1), contrasenaDemo);
    await tocar(tester, find.text('Iniciar sesión').last);
    expect(find.text('Hola, María.'), findsOneWidget);
    expect(find.text('0/14'), findsOneWidget);
  });

  testWidgets('sube una carta desde Inicio y el avance pasa a 1 de 14', (tester) async {
    final (repo, selector) = await montar(tester, conSesion: true);
    await tocar(tester, find.byTooltip('Subir Carta laboral 1'));
    expect(find.text('Elige cómo subirlo'), findsOneWidget);

    await tocar(tester, find.text('Elegir archivo'));
    expect(selector.ultimoOrigen, isNotNull);
    expect(find.text('carta_laboral_1.pdf'), findsOneWidget);

    await tocar(tester, find.text('Subir archivo'));
    expect(find.text('¡Listo, María!'), findsOneWidget);
    expect(find.textContaining('versión 1'), findsOneWidget);
    expect(repo.avancePropio.cargados, 1);

    await tocar(tester, find.text('Volver a mi expediente'));
    expect(find.text('Por subir 13'), findsOneWidget);
    expect(find.text('Cargados 1'), findsOneWidget);
  });

  testWidgets('rechaza un archivo de más de 2 MB y no deja subirlo', (tester) async {
    final (_, selector) = await montar(tester, conSesion: true);
    selector.siguiente = const ArchivoElegido(nombre: 'carta_scan.png', tamano: 3 * 1024 * 1024);
    await tocar(tester, find.byTooltip('Subir Carta laboral 1'));
    await tocar(tester, find.text('Elegir de la galería'));
    expect(find.text('carta_scan.png supera 2 MB'), findsOneWidget);
    final boton = tester.widget<ButtonStyleButton>(
      find.ancestor(of: find.text('Subir archivo'), matching: find.bySubtype<ButtonStyleButton>()),
    );
    expect(boton.onPressed, isNull);
  });

  testWidgets('el expediente busca sin acentos y muestra lo que sube la institución', (tester) async {
    await montar(tester, conSesion: true);
    await tocar(tester, find.text('Expediente'));
    expect(find.text('Cartas de recomendación'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'cedula');
    await tester.pumpAndSettle();
    expect(find.text('Cédula profesional'), findsOneWidget);
    expect(find.text('Carta laboral 1'), findsNothing);

    await tocar(tester, find.text('Institución'));
    expect(find.text('Datos que asigna Recursos Humanos'), findsOneWidget);
    expect(find.text('2 de 4'), findsOneWidget);
    expect(find.text('Subir'), findsNothing);
  });

  testWidgets('agrega un registro de propiedad intelectual con validación', (tester) async {
    await montar(tester, conSesion: true);
    await tocar(tester, find.text('Trayectoria').last);
    expect(find.text('Apartados de mi trayectoria'), findsOneWidget);
    await tocar(tester, find.text('Propiedad intelectual').first);
    expect(find.text('Todavía no hay registros.'), findsOneWidget);

    await tocar(tester, find.text('Agregar registro'));
    expect(find.text('Obra o invención registrada'), findsOneWidget);
    await tocar(tester, find.text('Guardar'));
    expect(find.text('Este campo es obligatorio'), findsNWidgets(3));

    await tester.enterText(find.byType(TextFormField).at(0), 'Software de control escolar');
    await tester.enterText(find.byType(TextFormField).at(1), '2025');
    await tester.enterText(find.byType(TextFormField).at(2), 'Derecho de autor · Registro de ejemplo');
    await tocar(tester, find.text('Adjuntar evidencia'));
    await tocar(tester, find.text('Elegir archivo'));
    await tocar(tester, find.text('Guardar'));
    expect(find.text('Software de control escolar'), findsOneWidget);
    expect(find.text('Evidencia adjunta'), findsOneWidget);
  });

  testWidgets('en Archivos las carpetas filtran las evidencias de la trayectoria', (tester) async {
    await montar(tester, conSesion: true);
    await tocar(tester, find.text('Trayectoria').last);
    await tocar(tester, find.text('Archivos'));
    expect(find.text('Todos los apartados'), findsOneWidget);
    await tocar(tester, find.text('Idiomas').first);
    expect(find.text('Inglés · 2025'), findsOneWidget);
    expect(find.text('titulo_maestria.pdf'), findsNothing);
  });

  testWidgets('confirma una sugerencia de publicación desde Más', (tester) async {
    await montar(tester, conSesion: true);
    await tocar(tester, find.text('Más'));
    await tocar(tester, find.text('Publicaciones'));
    expect(find.text('2 publicaciones podrían ser tuyas'), findsOneWidget);

    await tocar(tester, find.text('Es mía').first);
    expect(find.text('1 publicación podría ser tuya'), findsOneWidget);
    expect(find.text('Registradas'), findsNWidgets(2));
    // La barra inferior sigue visible dentro de Más.
    expect(find.text('Trayectoria'), findsOneWidget);
  });

  testWidgets('cambia la contraseña y cierra sesión', (tester) async {
    final (repo, _) = await montar(tester, conSesion: true);
    await tocar(tester, find.text('Más'));
    await tocar(tester, find.text('Configuración'));
    await tocar(tester, find.text('Cambiar contraseña'));
    await tester.enterText(find.byType(TextFormField).at(0), contrasenaDemo);
    await tester.enterText(find.byType(TextFormField).at(1), 'Nueva2026!');
    await tester.enterText(find.byType(TextFormField).at(2), 'Nueva2027!');
    await tocar(tester, find.text('Actualizar contraseña'));
    expect(find.text('Las contraseñas no coinciden'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(2), 'Nueva2026!');
    await tocar(tester, find.text('Actualizar contraseña'));
    expect(find.text('Contraseña actualizada.'), findsOneWidget);

    await tocar(tester, find.text('Cerrar sesión'));
    await tocar(tester, find.widgetWithText(FilledButton, 'Cerrar sesión'));
    expect(repo.conSesion, isFalse);
    expect(find.text('Tu expediente, en\ntu bolsillo.'), findsOneWidget);
    expect(await repo.iniciarSesion(correoDemo, 'Nueva2026!'), isNull);
  });

  testWidgets('el docente activo ve su trayectoria en Inicio, no el nuevo ingreso', (tester) async {
    final (repo, _) = await montar(tester, conSesion: true, correo: correoActivoDemo);
    expect(repo.avancePropio.completo, isTrue);
    expect(find.text('Expediente de ingreso completo'), findsOneWidget);
    expect(find.text('Estos los subes tú'), findsNothing);
    await tocar(tester, find.text('Actualizar mi trayectoria'));
    expect(find.text('Agregar registro'), findsOneWidget);
  });

  testWidgets('el docente de nuevo ingreso no tiene documentos personales', (tester) async {
    await montar(tester, conSesion: true);
    await tocar(tester, find.text('Expediente'));
    expect(find.text('Mis documentos personales'), findsNothing);
    await tocar(tester, find.text('Más'));
    expect(find.text('Mis documentos personales'), findsNothing);
  });

  testWidgets('el docente de nuevo ingreso abre lo que cargó la institución', (tester) async {
    await montar(tester, conSesion: true);
    await tocar(tester, find.text('Expediente'));
    await tocar(tester, find.text('Institución'));
    await tocar(tester, find.text('Resultado del examen de conocimientos').first);
    expect(find.text('Archivo de muestra, sin contenido real'), findsOneWidget);
    expect(find.text('Reemplazar'), findsNothing);
  });

  testWidgets('el docente activo guarda un archivo en su carpeta personal', (tester) async {
    final (repo, _) = await montar(tester, conSesion: true, correo: correoActivoDemo);
    await tocar(tester, find.text('Expediente'));
    expect(find.text('Todas las evidencias'), findsOneWidget);
    await tocar(tester, find.text('Mis documentos personales'));
    await tocar(tester, find.text('Agregar documento'));
    await tocar(tester, find.text('Elegir archivo'));
    expect(find.text('Escribe qué documento es.'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Pasaporte');
    await tocar(tester, find.text('Elegir archivo'));
    await tocar(tester, find.text('Elegir archivo'));
    expect(repo.carpetaPersonal.single.tipo, 'Pasaporte');
    await tocar(tester, find.text('Pasaporte').first);
    expect(find.text('Solo tú puedes ver este archivo.'), findsOneWidget);
    await tocar(tester, find.text('Quitar'));
    await tocar(tester, find.text('Sí, quitar'));
    expect(repo.carpetaPersonal, isEmpty);
    await tocar(tester, find.text('Volver').last);

    // También ve lo que cargó la institución al ingresar.
    await tocar(tester, find.textContaining('Ingreso '));
    expect(find.text('Recursos Humanos'), findsOneWidget);
    await tocar(tester, find.text('Formato de compatibilidad de empleo').first);
    expect(find.text('Formato de compatibilidad de empleo'), findsWidgets);
    expect(find.text('Reemplazar'), findsNothing);
  });
}
