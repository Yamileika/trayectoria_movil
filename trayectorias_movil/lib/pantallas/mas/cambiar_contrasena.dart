import 'package:flutter/material.dart';

import '../../estado/alcance.dart';
import '../../tema/colores.dart';
import '../../widgets/cabecera.dart';
import '../../widgets/componentes.dart';

class CambiarContrasena extends StatefulWidget {
  const CambiarContrasena({super.key});

  @override
  State<CambiarContrasena> createState() => _CambiarContrasenaState();
}

class _CambiarContrasenaState extends State<CambiarContrasena> {
  final _form = GlobalKey<FormState>();
  final _actual = TextEditingController();
  final _nueva = TextEditingController();
  final _confirmar = TextEditingController();
  final _ver = <int>{};
  String? _errorActual;
  var _enviando = false;

  @override
  void initState() {
    super.initState();
    _nueva.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _actual.dispose();
    _nueva.dispose();
    _confirmar.dispose();
    super.dispose();
  }

  /// 0 a 3 según longitud y variedad de caracteres.
  int get _fuerza {
    final t = _nueva.text;
    if (t.length < 8) return t.isEmpty ? 0 : 1;
    final variedad = [
      RegExp('[a-z]'),
      RegExp('[A-Z]'),
      RegExp(r'\d'),
      RegExp(r'[^A-Za-z0-9]'),
    ].where((r) => r.hasMatch(t)).length;
    return variedad >= 3 ? 3 : 2;
  }

  Future<void> _guardar() async {
    setState(() => _errorActual = null);
    if (!_form.currentState!.validate()) return;
    setState(() => _enviando = true);
    final error = await context.repositorio.cambiarContrasena(_actual.text, _nueva.text);
    if (!mounted) return;
    setState(() {
      _enviando = false;
      _errorActual = error;
    });
    if (error == null) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contraseña actualizada.')));
    }
  }

  Widget _ojo(int i) => IconButton(
    tooltip: _ver.contains(i) ? 'Ocultar' : 'Mostrar',
    onPressed: () => setState(() => _ver.contains(i) ? _ver.remove(i) : _ver.add(i)),
    icon: Icon(_ver.contains(i) ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colores.marino),
  );

  @override
  Widget build(BuildContext context) {
    final fuerza = _fuerza;
    const nombres = ['', 'baja', 'media', 'alta'];
    const colores = [Colores.neutro, Colores.error, Colores.verde, Colores.exito];

    return Scaffold(
      body: Form(
        key: _form,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const CabeceraMovil(volver: true, etiqueta: 'Seguridad', titulo: 'Cambiar contraseña'),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CampoTexto(
                    etiqueta: 'Contraseña actual',
                    controlador: _actual,
                    oculto: !_ver.contains(0),
                    sufijo: _ojo(0),
                    validar: obligatorio(),
                    error: _errorActual,
                  ),
                  CampoTexto(
                    etiqueta: 'Nueva contraseña',
                    controlador: _nueva,
                    oculto: !_ver.contains(1),
                    sufijo: _ojo(1),
                    validar: (v) => (v ?? '').length < 8 ? 'Usa al menos 8 caracteres' : null,
                  ),
                  BarraAvance(fraccion: fuerza / 3, color: colores[fuerza]),
                  const SizedBox(height: 6),
                  Text(
                    fuerza == 0 ? 'Mínimo 8 caracteres' : 'Seguridad: ${nombres[fuerza]} · mínimo 8 caracteres',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 14),
                  CampoTexto(
                    etiqueta: 'Confirmar contraseña',
                    controlador: _confirmar,
                    oculto: !_ver.contains(2),
                    sufijo: _ojo(2),
                    validar: (v) => v != _nueva.text ? 'Las contraseñas no coinciden' : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BotonesInferiores(
        principal: FilledButton(onPressed: _enviando ? null : _guardar, child: const Text('Actualizar contraseña')),
      ),
    );
  }
}
