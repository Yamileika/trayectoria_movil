import 'package:flutter/material.dart';

import '../../datos/demo.dart';
import '../../estado/alcance.dart';
import '../../tema/colores.dart';
import '../../widgets/componentes.dart';
import 'recuperar_contrasena.dart';

/// Inicio de sesión móvil (y su estado de error de credenciales).
class InicioSesion extends StatefulWidget {
  const InicioSesion({super.key});

  @override
  State<InicioSesion> createState() => _InicioSesionState();
}

class _InicioSesionState extends State<InicioSesion> {
  final _form = GlobalKey<FormState>();
  final _correo = TextEditingController();
  final _contrasena = TextEditingController();
  var _verContrasena = false;
  var _recordarme = true;
  var _enviando = false;
  String? _error;

  @override
  void dispose() {
    _correo.dispose();
    _contrasena.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _enviando = true;
      _error = null;
    });
    final error = await context.repositorio.iniciarSesion(_correo.text, _contrasena.text);
    if (!mounted) return;
    setState(() {
      _enviando = false;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final conError = _error != null;
    return Scaffold(
      backgroundColor: Colores.marino,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const _Portada(),
            Container(
              constraints: BoxConstraints(minHeight: MediaQuery.sizeOf(context).height - 250),
              decoration: const BoxDecoration(
                color: Colores.fondo,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: EdgeInsets.fromLTRB(20, 24, 20, 20 + MediaQuery.paddingOf(context).bottom),
              child: AutofillGroup(
                child: Form(
                  key: _form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          'Iniciar sesión',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20),
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (conError) ...[
                        Semantics(
                          liveRegion: true,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colores.errorSuave,
                              border: Border.all(color: Colores.error),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _error!,
                              style: const TextStyle(color: Colores.errorTexto, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],
                      CampoTexto(
                        etiqueta: 'Correo de acceso',
                        controlador: _correo,
                        pista: 'nombre@correo.mx',
                        teclado: TextInputType.emailAddress,
                        autocompletar: const [AutofillHints.email],
                        validar: obligatorio(),
                      ),
                      CampoTexto(
                        etiqueta: 'Contraseña',
                        controlador: _contrasena,
                        oculto: !_verContrasena,
                        autocompletar: const [AutofillHints.password],
                        validar: obligatorio(),
                        error: conError ? 'Contraseña incorrecta' : null,
                        sufijo: IconButton(
                          tooltip: _verContrasena ? 'Ocultar contraseña' : 'Mostrar contraseña',
                          onPressed: () => setState(() => _verContrasena = !_verContrasena),
                          icon: Icon(
                            _verContrasena ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: Colores.marino,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => setState(() => _recordarme = !_recordarme),
                              child: Row(
                                children: [
                                  Checkbox(value: _recordarme, onChanged: (v) => setState(() => _recordarme = v!)),
                                  const Text('Recordarme'),
                                ],
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (_) => const RecuperarContrasena())),
                            child: const Text(
                              '¿Olvidaste tu contraseña?',
                              style: TextStyle(decoration: TextDecoration.underline),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      FilledButton(
                        onPressed: _enviando ? null : _entrar,
                        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)).copyWith(
                          // Hover con mouse y el mismo tono al tocarlo en el teléfono.
                          backgroundColor: WidgetStateProperty.resolveWith(
                            (estados) => estados.contains(WidgetState.disabled)
                                ? Colores.neutro
                                : estados.contains(WidgetState.pressed)
                                ? Colores.verdePresionado
                                : estados.contains(WidgetState.hovered)
                                ? Colores.verdeHover
                                : Colores.verde,
                          ),
                          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
                          elevation: const WidgetStatePropertyAll(0),
                          mouseCursor: const WidgetStatePropertyAll(SystemMouseCursors.click),
                        ),
                        child: _enviando
                            ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2.5))
                            : const Text('Iniciar sesión', style: TextStyle(fontSize: 15)),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('El acceso con huella se activará con las cuentas reales.')),
                        ),
                        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(46)),
                        icon: const Icon(Icons.lock_outline, size: 18),
                        label: const Text('Entrar con huella'),
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        '¿Problemas para entrar? Escribe a Evaluación y Formación Docente.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colores.apoyo, fontSize: 12.5),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Demostración: $correoDemo (nuevo ingreso) o $correoActivoDemo (activo) · $contrasenaDemo',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colores.apoyo, fontSize: 11.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Portada extends StatelessWidget {
  const _Portada();

  @override
  Widget build(BuildContext context) {
    final arriba = MediaQuery.paddingOf(context).top;
    return SizedBox(
      height: 250 + arriba,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          const Positioned(
            right: -60,
            top: -80,
            child: SizedBox(
              width: 230,
              height: 230,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Colores.verde, shape: BoxShape.circle),
              ),
            ),
          ),
          Positioned(
            left: 40,
            bottom: -30,
            child: Transform.rotate(
              angle: 0.3,
              child: const SizedBox(
                width: 90,
                height: 60,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: Colores.ambar, borderRadius: BorderRadius.all(Radius.circular(16))),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(22, 30 + arriba, 22, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset('assets/images/logo.png', width: 46, height: 46, semanticLabel: 'Logotipo'),
                    const SizedBox(width: 10),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TRAYECTORIAS',
                          style: TextStyle(
                            color: Colores.lilaSobreMarino,
                            fontSize: 10,
                            letterSpacing: 1.6,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Docentes',
                          style: TextStyle(color: Colores.blanco, fontSize: 20, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 34),
                const Text(
                  'Tu expediente, en\ntu bolsillo.',
                  style: TextStyle(color: Colores.blanco, fontSize: 27, fontWeight: FontWeight.w800, height: 1.15),
                ),
                const SizedBox(height: 8),
                const Text(
                  'App para docentes de la UT\nTulancingo.',
                  style: TextStyle(color: Colores.lilaSobreMarino, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
