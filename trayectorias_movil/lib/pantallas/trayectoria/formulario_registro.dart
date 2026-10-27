import 'package:flutter/material.dart';

import '../../datos/modelos.dart';
import '../../estado/alcance.dart';
import '../../tema/colores.dart';
import '../../widgets/archivos.dart';
import '../../widgets/cabecera.dart';
import '../../widgets/componentes.dart';

/// Formulario para agregar o editar un registro de cualquier apartado de la
/// trayectoria. Sin apartado (desde «Agregar registro») pide elegirlo.
class FormularioRegistro extends StatefulWidget {
  const FormularioRegistro({super.key, this.seccion, this.registro});

  final SeccionTrayectoria? seccion;
  final RegistroTrayectoria? registro;

  @override
  State<FormularioRegistro> createState() => _FormularioRegistroState();
}

class _FormularioRegistroState extends State<FormularioRegistro> {
  final _form = GlobalKey<FormState>();
  late final _titulo = TextEditingController(text: widget.registro?.titulo);
  late final _periodo = TextEditingController(text: widget.registro?.periodo);
  late final _detalle = TextEditingController(text: widget.registro?.detalle);
  late ArchivoElegido? _evidencia = widget.registro?.evidencia;
  late var _seccion = widget.seccion ?? SeccionTrayectoria.formacion;
  String? _problemaEvidencia;

  @override
  void dispose() {
    _titulo.dispose();
    _periodo.dispose();
    _detalle.dispose();
    super.dispose();
  }

  Future<void> _adjuntar() async {
    final selector = context.selector;
    final origen = await preguntarOrigen(context, 'Adjuntar evidencia');
    if (origen == null) return;
    final elegido = await selector.elegir(origen);
    if (elegido == null || !mounted) return;
    setState(() {
      _problemaEvidencia = elegido.problema;
      if (_problemaEvidencia == null) _evidencia = elegido;
    });
  }

  void _guardar() {
    if (!_form.currentState!.validate()) return;
    context.repositorio.guardarRegistro(
      RegistroTrayectoria(
        id: widget.registro?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        seccion: _seccion,
        titulo: _titulo.text.trim(),
        periodo: _periodo.text.trim(),
        detalle: _detalle.text.trim(),
        evidencia: _evidencia,
      ),
    );
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registro guardado en tu trayectoria.')));
  }

  @override
  Widget build(BuildContext context) {
    final s = _seccion;
    final editando = widget.registro != null;
    return Scaffold(
      body: Form(
        key: _form,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            CabeceraMovil(
              volver: true,
              etiqueta: 'Mi trayectoria',
              titulo: editando
                  ? 'Editar registro'
                  : widget.seccion == null
                  ? 'Agregar registro'
                  : s.agregar,
              subtitulo: editando || widget.seccion != null ? s.nombre : null,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.seccion == null && !editando) ...[
                    Text('Apartado', style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<SeccionTrayectoria>(
                      initialValue: _seccion,
                      isExpanded: true,
                      items: [
                        for (final opcion in SeccionTrayectoria.values)
                          DropdownMenuItem(value: opcion, child: Text(opcion.nombre)),
                      ],
                      onChanged: (v) => setState(() => _seccion = v!),
                    ),
                    const SizedBox(height: 14),
                  ],
                  CampoTexto(
                    etiqueta: s.campoTitulo,
                    controlador: _titulo,
                    pista: s.ejemplo,
                    maximo: 200,
                    validar: obligatorio(200),
                  ),
                  CampoTexto(
                    etiqueta: s.campoPeriodo,
                    controlador: _periodo,
                    pista: 'Ej. 2022 – 2023',
                    maximo: 100,
                    validar: obligatorio(100),
                  ),
                  CampoTexto(
                    etiqueta: s.campoDetalle,
                    controlador: _detalle,
                    lineas: 3,
                    maximo: 2000,
                    validar: obligatorio(2000),
                  ),
                  OutlinedButton.icon(
                    onPressed: _adjuntar,
                    style: OutlinedButton.styleFrom(alignment: Alignment.centerLeft),
                    icon: const Icon(Icons.photo_camera_outlined, size: 20),
                    label: Text(_evidencia == null ? 'Adjuntar evidencia' : 'Cambiar evidencia'),
                  ),
                  const SizedBox(height: 8),
                  if (_evidencia != null)
                    Row(
                      children: [
                        const Insignia('Evidencia', tono: TonoInsignia.listo, icono: Icons.check),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${_evidencia!.nombre} · ${tamanoLegible(_evidencia!.tamano)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    )
                  else
                    Text('PDF, JPG o PNG · máx. 2 MB', style: Theme.of(context).textTheme.bodySmall),
                  if (_problemaEvidencia != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        _problemaEvidencia!,
                        style: const TextStyle(color: Colores.errorTexto, fontWeight: FontWeight.w700, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BotonesInferiores(
        secundario: OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
        principal: FilledButton(onPressed: _guardar, child: const Text('Guardar')),
      ),
    );
  }
}
