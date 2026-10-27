# Trayectorias Docentes · app móvil

App en Flutter **solo para docentes** de la UT Tulancingo. Sigue las pantallas
«Móvil – …» y la «Navegación de la app móvil del docente» del canvas de diseño
*Trayectorias Docentes – plataforma integral*.

## Cómo ejecutarla

```bash
flutter pub get
flutter run            # elige un emulador Android, un iPhone, Chrome o Windows
```

Cuentas de demostración (contraseña `Demo2026`):

- `maria@ejemplo.mx`: docente de **nuevo ingreso** que aún sube sus documentos.
- `carlos@ejemplo.mx`: docente **activo** con el expediente de ingreso completo.

## Qué incluye

| Apartado | Pantallas |
|---|---|
| Acceso | Inicio de sesión (con error de credenciales) y recuperar contraseña |
| Inicio | Nuevo ingreso: avance personal, tres documentos por subir y accesos. Activo: expediente completo, cifras de la trayectoria, sugerencias por confirmar y avisos |
| Expediente | Nuevo ingreso: Por subir (por apartado y con buscador), Cargados (hojas de archivo con vista previa y reemplazar) e Institución. Activo: explorador de carpetas como en la web (apartados de la trayectoria, Mi carpeta personal y Nuevo ingreso). Subir con foto, galería o archivo (PDF, JPG o PNG hasta 2 MB) |
| Trayectoria | Los 11 apartados de la web con su color, perfil completo, carpetitas, vista Lista y vista Archivos, detalle de cada apartado y formularios con validación y evidencia |
| Proyectos | Solo para profesores de tiempo completo; lista y detalle (General, Documentos, Cronograma, Avances), solo consulta |
| Más | Publicaciones (sugerencias Es mía / No es mía, lista por año, referencia para copiar), Documentos (CV, Ficha, Informe y Semblanza con apartados a elegir; vista previa sin validez oficial), Indicadores, Información general, Configuración, Cambiar contraseña, Ayuda y Cerrar sesión |

## Datos

Todo es **simulado** y vive en memoria (`lib/datos/demo.dart`): los cambios se
pierden al cerrar la app. Las pantallas solo usan la interfaz
`Repositorio` (`lib/datos/repositorio.dart`), pensada para el modelo de Firebase
(usuarios, docentes, requisitos, expediente, trayectoria, publicaciones,
sugerencias y proyectos). Conectar Firebase consiste en escribir otra
implementación de esa interfaz.

Pendiente: autenticación real, guardar archivos en Storage, acceso con huella,
descarga de PDF de los documentos y registrar publicaciones desde el teléfono.

## Estructura

```
lib/
  datos/        modelos, catálogo de 24 requisitos, datos de muestra y repositorio
  estado/       acceso al repositorio desde las pantallas
  servicios/    selector de archivos (cámara, galería, archivos)
  tema/         paleta y tema (Nunito Sans, bordes y sombras cortas)
  widgets/      cabecera, tarjetas, insignias, anillos de avance, campos
  pantallas/    acceso, inicio, expediente, trayectoria, proyectos, mas
test/           pruebas de datos y recorridos completos
test_capturas/  genera capturas de las pantallas (flutter test test_capturas --update-goldens)
```

## Comprobaciones

```bash
flutter analyze
flutter test
```
