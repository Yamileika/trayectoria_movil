import 'package:flutter/material.dart';

import '../../estado/alcance.dart';
import '../../tema/colores.dart';
import '../../widgets/cabecera.dart';
import '../../widgets/componentes.dart';

class RecuperarContrasena extends StatefulWidget {
  const RecuperarContrasena({super.key});

  @override
  State<RecuperarContrasena> createState() => _RecuperarContrasenaState();
}

class _RecuperarContrasenaState extends State<RecuperarContrasena> {
  final _form = GlobalKey<FormState>();
  final _correo = TextEditingController();
  var _enviando = false;
  var _enviado = false;

  @override
  void dispose() {
    _correo.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _enviando = true);
    await context.repositorio.recuperarContrasena(_correo.text);
    if (mounted) {
      setState(() {
        _enviando = false;
        _enviado = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const CabeceraMovil(
            volver: true,
            etiqueta: 'Acceso',
            titulo: 'Recupera tu contraseña',
            subtitulo: 'Te enviamos un enlace por correo.',
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Tarjeta(
                    color: Colores.ambarSuave,
                    destacada: true,
                    child: Row(
                      children: [
                        CajaIcono(Icons.mail_outline, fondo: Colores.blanco),
                        SizedBox(width: 12),
                        Expanded(child: Text('Escribe el correo con el que accedes a la app.')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  CampoTexto(
                    etiqueta: 'Correo de acceso',
                    controlador: _correo,
                    pista: 'nombre@correo.mx',
                    teclado: TextInputType.emailAddress,
                    validar: (v) {
                      if (v == null || v.trim().isEmpty) return 'Este campo es obligatorio';
                      if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) return 'Escribe un correo válido';
                      return null;
                    },
                  ),
                  FilledButton(
                    onPressed: _enviando ? null : _enviar,
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                    child: const Text('Enviar enlace'),
                  ),
                  if (_enviado) ...[
                    const SizedBox(height: 14),
                    Semantics(
                      liveRegion: true,
                      child: const Tarjeta(
                        color: Colores.verdeSuave,
                        child: Row(
                          children: [
                            Icon(Icons.check, color: Colores.verdeTexto),
                            SizedBox(width: 10),
                            Expanded(child: Text('Si el correo está registrado, recibirás el enlace en unos minutos.')),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
