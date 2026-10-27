# Práctica de CI con GitHub Actions · app móvil (Flutter)

Esta guía sigue las 5 fases del enunciado con la app móvil de Trayectorias
Docentes tal como está. No se agrega ningún archivo de ejemplo: se usan dos
funcionalidades reales de la app y las pruebas que ya tenía. Donde el
enunciado dice Python y `pytest`, aquí se usa Dart y `flutter test`.

## Las dos funcionalidades elegidas

| | Funcionalidad | Código | Prueba | Qué pasa |
|---|---|---|---|---|
| ✅ | **Inicio de sesión**: solo entra con el correo y la contraseña correctos | `lib/datos/repositorio.dart` → `iniciarSesion` | `test/repositorio_test.dart` → *inicia sesión solo con las credenciales correctas* | Pasa siempre, también en la Fase 5 |
| ❌ | **Límite de 2 MB al subir documentos**: un archivo más grande se rechaza | `lib/datos/modelos.dart` → `ArchivoElegido.tamanoMaximo` | `test/repositorio_test.dart` → *solo se aceptan PDF, JPG o PNG de hasta 2 MB* y `test/recorridos_test.dart` → *rechaza un archivo de más de 2 MB y no deja subirlo* | Pasa en las fases 2 a 4; en la Fase 5 le metemos un error y falla |

Así, en la Fase 5 se ve en la misma salida una funcionalidad que sigue
pasando y otra que falla.

Equivalencias con el enunciado:

| Enunciado (Python) | App móvil (Flutter) |
|---|---|
| `calculadora.py` con `suma` | `lib/datos/repositorio.dart` y `lib/datos/modelos.dart` |
| `test_calculadora.py` | `test/repositorio_test.dart` y `test/recorridos_test.dart` |
| `pip install pytest` | `flutter pub get` |
| `pytest` | `flutter test` |
| `a + b` → `a - b` | `2 * 1024 * 1024` → `20 * 1024 * 1024` |

El repositorio de la práctica es `C:\Trayectorias\trayectoria_movil`
(separado de la app original, que no se toca). Su estructura:

```
C:\Trayectorias\trayectoria_movil\      ← raíz del repositorio (aquí van los comandos git)
  .github\workflows\ci.yml              ← el workflow
  practica-ci\                          ← esta guía, las capturas y el ci.yml corregido
  trayectorias_movil\                   ← la app (aquí van los comandos flutter)
    lib\  test\  pubspec.yaml ...
```

Los comandos `git` se escriben en la raíz y los `flutter` dentro de la app:

```powershell
cd C:\Trayectorias\trayectoria_movil                       # para git
cd C:\Trayectorias\trayectoria_movil\trayectorias_movil    # para flutter
```

Las imágenes de la carpeta `capturas/` son salidas **reales** de estos mismos
comandos corridos en la nube con una copia de la app (Flutter 3.47.8). Te
sirven para saber qué debe aparecer. Las evidencias que entregas las tomas tú
en tu terminal y en GitHub, porque deben mostrar tu repositorio y tu usuario.

---

## Antes de empezar (una sola vez)

1. Comprueba que tienes Git y Flutter:
   ```powershell
   git --version
   flutter --version
   ```
2. Si Git nunca se ha usado en tu equipo, pon tu nombre y correo de GitHub:
   ```powershell
   git config --global user.name "Tu nombre"
   git config --global user.email "tu-correo@ejemplo.com"
   ```

> Nota: no hagas los comandos git en `C:\Trayectorias\Trayectorias\Trayectorias-Docentes`:
> esa carpeta es el repositorio de la app original y se sube a otro lugar.

---

## Fase 1. Crear el repositorio en GitHub

1. En GitHub: **New repository**, nombre `ci-practica-equipo##` (por ejemplo
   `ci-practica-equipo01`), público.
2. **No marques "Add a README file"**. La app ya trae su `README.md` y aparece
   en GitHub con el primer push. Si GitHub crea otro, el push se rechaza
   (`! [rejected] ... fetch first`) porque los dos lados tienen historias
   distintas.
3. Copia la URL que te muestra, por ejemplo
   `https://github.com/TU-USUARIO/ci-practica-equipo01.git`.

✅ **Evidencia:** captura del repositorio creado. Después del push de la
Fase 2, toma otra donde ya se vean los archivos y el README.

---

## Fase 2. Probar en tu equipo y subir el proyecto

### 2.1 Descargar dependencias

```powershell
cd C:\Trayectorias\trayectoria_movil\trayectorias_movil
flutter pub get
```

Debe salir `Resolving dependencies...`, una lista de paquetes con versiones
nuevas (es un aviso normal, no un error) y al final **`Got dependencies!`**.
→ captura `01-fase2-flutter-pub-get.png`

### 2.2 Correr las pruebas antes de subir (lo mismo que hará GitHub)

Las pruebas donde están las dos funcionalidades:

```powershell
flutter test test/repositorio_test.dart
```

Deben pasar las 9, entre ellas *inicia sesión solo con las credenciales
correctas* y *solo se aceptan PDF, JPG o PNG de hasta 2 MB*. Termina en
**`00:00 +9: All tests passed!`** (el `+9` son las pruebas que pasaron).
→ captura `02-fase2-pruebas-sesion-y-archivos.png`

Y todas las pruebas de la app:

```powershell
flutter test
```

Debe terminar en **`+21: All tests passed!`** en unos 10 a 30 segundos.
→ captura `03-fase2-flutter-test-completo.png`

### 2.3 Primer commit y push

```powershell
cd C:\Trayectorias\trayectoria_movil
git init
git add .
git commit -m "Primer commit"
git branch -M main
git remote add origin https://github.com/TU-USUARIO/ci-practica-equipo01.git
git push -u origin main
```

Qué debe salir en cada uno:

- `git init` → `Initialized empty Git repository in C:/Trayectorias/trayectoria_movil/.git/`
- `git add .` → nada (si sale `warning: LF will be replaced by CRLF`, es normal
  en Windows).
- `git commit` → `[main (root-commit) xxxxxxx] Primer commit` y unos
  `175 files changed`. Las carpetas `build` y `.dart_tool` no se suben porque
  están en `.gitignore`. → captura `04-fase2-primer-commit.png`
- `git push` → la primera vez se abre una ventana para iniciar sesión en
  GitHub. Luego verás algo así (esto lo capturas tú; en la nube no se puede):
  ```
  Enumerating objects: ..., done.
  Writing objects: 100% (...), ... MiB | ... MiB/s, done.
  To https://github.com/TU-USUARIO/ci-practica-equipo01.git
   * [new branch]      main -> main
  branch 'main' set up to track 'origin/main'.
  ```

En este punto la pestaña **Actions** todavía no hace nada, porque aún no
existe el workflow.

---

## Fase 3. Configurar GitHub Actions

1. Crea la carpeta y copia el workflow (desde la raíz del repositorio):
   ```powershell
   cd C:\Trayectorias\trayectoria_movil
   mkdir .github\workflows
   copy practica-ci\ci.yml .github\workflows\ci.yml
   ```
2. Su contenido (es el `ci.yml` del enunciado, cambiado a Flutter). Las líneas
   `defaults: run: working-directory: trayectorias_movil` le dicen a GitHub
   que la app está en esa subcarpeta:
   ```yaml
   name: Flutter CI

   on:
     push:

   jobs:
     test:
       runs-on: ubuntu-latest
       defaults:
         run:
           working-directory: trayectorias_movil
       steps:
         - uses: actions/checkout@v4

         - name: Instalar Flutter
           uses: subosito/flutter-action@v2
           with:
             channel: stable
             cache: true

         - name: Instalar dependencias
           run: flutter pub get

         - name: Ejecutar pruebas
           run: flutter test
   ```
3. Sube el cambio:
   ```powershell
   git status
   git add .
   git commit -m "Agregar GitHub Actions"
   git push
   ```
   `git status` muestra `.github/` como nuevo, y el commit dice
   `1 file changed ... create mode 100644 .github/workflows/ci.yml`.
   → captura `05-fase3-commit-actions.png`

---

## Fase 4. Verificar la ejecución automática

Entra a tu repositorio → pestaña **Actions**. Verás la ejecución
"Agregar GitHub Actions" del workflow **Flutter CI**: primero amarilla (en
curso) y luego ✅ verde. Entra a ella y abre el job **test** para ver cada paso.

Respuestas para las preguntas:

- **¿Se ejecutó automáticamente?** Sí. Nadie la lanzó a mano: la disparó el
  `git push`, porque el `ci.yml` dice `on: push`.
- **¿Cuánto tardó?** Lo ves arriba en el resumen (*Total duration*) o junto al
  job. Calcula entre 1 y 3 minutos; la primera vez tarda más porque descarga
  Flutter. Anota el número exacto que te salga.
- **¿Qué tareas realizó?** Las que salen en el job: *Set up job*, *Run
  actions/checkout@v4* (descarga tu código), *Instalar Flutter*, *Instalar
  dependencias* (`flutter pub get`), *Ejecutar pruebas* (`flutter test`, con
  las 21 pruebas, incluidas inicio de sesión y límite de 2 MB, y
  `All tests passed!`) y *Complete job*.

✅ **Evidencias:** captura de la lista en Actions con la palomita verde y
captura del job abierto con los pasos.

---

## Fase 5. Provocar un fallo

1. Abre `trayectorias_movil/lib/datos/modelos.dart`, busca la clase `ArchivoElegido` (cerca de la
   línea 157) y cambia
   ```dart
   static const tamanoMaximo = 2 * 1024 * 1024;
   ```
   por
   ```dart
   static const tamanoMaximo = 20 * 1024 * 1024;
   ```
   Es un error "de dedo" creíble: ahora la app dejaría subir archivos de hasta
   20 MB aunque el mensaje siga diciendo 2 MB. Guarda.
2. (Recomendado) pruébalo antes de subir:
   ```powershell
   flutter test test/repositorio_test.dart
   ```
   *inicia sesión solo con las credenciales correctas* sigue pasando, y en rojo
   sale `solo se aceptan PDF, JPG o PNG de hasta 2 MB [E]` con
   `Expected: contains '2 MB'` y `Actual: <null>`: un archivo de 3 MB ya no
   da error. Termina en **`+8 -1: Some tests failed.`**
   → captura `06-fase5-error-intencional.png`

   Con todas las pruebas (`flutter test`) el resumen es **`+19 -2`**: también
   falla el recorrido *rechaza un archivo de más de 2 MB y no deja subirlo*,
   que simula al docente eligiendo una foto de 3 MB.
   → captura `07-fase5-resumen-y-commit.png`
3. Súbelo de todos modos, como pide la práctica:
   ```powershell
   git add .
   git commit -m "Error intencional"
   git push
   ```
4. En **Actions** la ejecución "Error intencional" sale con ❌ roja. Al abrir el
   paso *Ejecutar pruebas* verás las mismas 2 pruebas fallidas y al final
   `Process completed with exit code 1`. GitHub también te puede mandar un
   correo avisando que el workflow falló.

✅ **Evidencias:** captura del ❌ en Actions y del paso con el error.

### Reflexión: ¿qué ventaja tiene detectar el error antes de liberar el software?

El cambio de 2 MB a 20 MB se descubrió segundos después del push, en un
servidor de GitHub, sin que nadie revisara a mano y antes de que la app llegara
a un docente. Arreglarlo así es barato: sabes qué commit lo causó, qué prueba
falló y qué valor dio. Si se hubiera liberado, los docentes subirían archivos
que el sistema de la institución no acepta, y costaría más rastrear por qué.
Además, el inicio de sesión siguió en verde: las pruebas también confirman que
lo que no se tocó sigue funcionando, así que el equipo puede cambiar el código
con confianza.

### Al terminar (opcional)

Para dejar el repositorio en verde otra vez, regresa `20` a `2` y sube:

```powershell
git add .
git commit -m "Corregir límite de 2 MB"
git push
```
