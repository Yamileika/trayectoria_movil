import 'package:flutter/material.dart';

import '../../datos/modelos.dart';
import '../../estado/alcance.dart';
import '../../widgets/cabecera.dart';
import '../../widgets/componentes.dart';

/// Información general: contacto y semblanza (los edita el docente);
/// nómina y correo institucional solo se consultan.
class InformacionGeneral extends StatefulWidget {
  const InformacionGeneral({super.key});

  @override
  State<InformacionGeneral> createState() => _InformacionGeneralState();
}

class _InformacionGeneralState extends State<InformacionGeneral> {
  final _form = GlobalKey<FormState>();
  late final Docente _docente = context.repositorio.docente;
  late final _correo = TextEditingController(text: _docente.contacto.correoPersonal);
  late final _telefono = TextEditingController(text: _docente.contacto.telefono);
  late final _semblanza = TextEditingController(text: _docente.contacto.semblanza);

  @override
  void dispose() {
    _correo.dispose();
    _telefono.dispose();
    _semblanza.dispose();
    super.dispose();
  }

  void _guardar() {
    if (!_form.currentState!.validate()) return;
    context.repositorio.actualizarContacto(
      Contacto(correoPersonal: _correo.text.trim(), telefono: _telefono.text.trim(), semblanza: _semblanza.text.trim()),
    );
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cambios guardados.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _form,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const CabeceraMovil(volver: true, etiqueta: 'Mi perfil', titulo: 'Información general'),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CampoTexto(
                    etiqueta: 'Correo personal',
                    controlador: _correo,
                    teclado: TextInputType.emailAddress,
                    validar: (v) =>
                        v != null && v.trim().isNotEmpty && !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())
                        ? 'Escribe un correo válido'
                        : null,
                  ),
                  CampoTexto(etiqueta: 'Teléfono', controlador: _telefono, teclado: TextInputType.phone, maximo: 30),
                  CampoTexto(etiqueta: 'Semblanza', controlador: _semblanza, lineas: 3, maximo: 2000),
                  CampoTexto(
                    etiqueta: 'Número de nómina',
                    controlador: TextEditingController(
                      text: _docente.nomina.isEmpty ? 'Pendiente de asignación' : _docente.nomina,
                    ),
                    soloLectura: true,
                  ),
                  CampoTexto(
                    etiqueta: 'Correo institucional',
                    controlador: TextEditingController(
                      text: _docente.correoInstitucional.isEmpty
                          ? 'Pendiente de asignación'
                          : _docente.correoInstitucional,
                    ),
                    soloLectura: true,
                  ),
                  Text(
                    'Recursos Humanos asigna la nómina y el correo institucional.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BotonesInferiores(
        principal: FilledButton(onPressed: _guardar, child: const Text('Guardar cambios')),
      ),
    );
  }
}
