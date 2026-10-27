/// Modelos alineados con el prototipo de base de datos en Firebase
/// (usuarios, docentes, requisitos, expediente, trayectoria,
/// publicaciones, sugerencias y proyectos).
library;

enum Responsable {
  administracion('Administración'),
  docente('Docente'),
  rh('Recursos Humanos');

  const Responsable(this.etiqueta);
  final String etiqueta;
}

enum Nacionalidad { mexicana, extranjera, naturalizada }

enum Contratacion {
  asignatura('Profesor de asignatura'),
  tiempoCompleto('Profesor de tiempo completo');

  const Contratacion(this.etiqueta);
  final String etiqueta;
}

enum EstadoDocente {
  nuevoIngreso('Nuevo ingreso'),
  activo('Activo');

  const EstadoDocente(this.etiqueta);
  final String etiqueta;
}

enum EstadoDocumento {
  pendiente('Pendiente'),
  cargado('Cargado'),
  noAplica('No aplica');

  const EstadoDocumento(this.etiqueta);
  final String etiqueta;
}

/// Apartados en que se agrupan los 14 documentos del docente.
enum CategoriaDocumento {
  cartas('Cartas de recomendación'),
  identidad('Identidad personal'),
  formacion('Formación y currículum'),
  tramites('Trámites y comprobantes');

  const CategoriaDocumento(this.etiqueta);
  final String etiqueta;
}

class Contacto {
  const Contacto({this.correoPersonal = '', this.telefono = '', this.semblanza = ''});

  final String correoPersonal;

  /// Hasta 30 caracteres.
  final String telefono;

  /// Hasta 2,000 caracteres.
  final String semblanza;
}

class Docente {
  const Docente({
    required this.id,
    required this.nombre,
    required this.correoAcceso,
    required this.departamento,
    required this.contratacion,
    required this.estado,
    required this.nacionalidad,
    this.nomina = '',
    this.correoInstitucional = '',
    this.contacto = const Contacto(),
  });

  final String id;
  final String nombre;
  final String correoAcceso;
  final String departamento;
  final Contratacion contratacion;
  final EstadoDocente estado;
  final Nacionalidad nacionalidad;

  /// Solo RH lo asigna; el docente lo consulta.
  final String nomina;

  /// Solo RH lo asigna; el docente lo consulta.
  final String correoInstitucional;

  /// Lo edita el docente.
  final Contacto contacto;

  /// Proyectos solo aplica a profesores de tiempo completo (PTC).
  bool get esPtc => contratacion == Contratacion.tiempoCompleto;

  String get primerNombre => nombre.split(' ').first;

  String get iniciales {
    final partes = nombre.trim().split(RegExp(r'\s+'));
    return partes.take(2).map((p) => p[0]).join().toUpperCase();
  }

  Docente conContacto(Contacto nuevo) => Docente(
    id: id,
    nombre: nombre,
    correoAcceso: correoAcceso,
    departamento: departamento,
    contratacion: contratacion,
    estado: estado,
    nacionalidad: nacionalidad,
    nomina: nomina,
    correoInstitucional: correoInstitucional,
    contacto: nuevo,
  );
}

class Requisito {
  const Requisito({
    required this.id,
    required this.nombre,
    required this.responsable,
    this.nombreCorto,
    this.categoria,
    this.instrucciones,
    this.condicion,
  });

  final int id;
  final String nombre;

  /// Nombre breve para listas en pantallas pequeñas.
  final String? nombreCorto;
  final Responsable responsable;
  final CategoriaDocumento? categoria;
  final String? instrucciones;

  /// Si no es nulo, el requisito solo aplica a esa nacionalidad.
  final Nacionalidad? condicion;

  String get corto => nombreCorto ?? nombre;

  bool aplicaA(Docente docente) => condicion == null || condicion == docente.nacionalidad;
}

/// Archivo elegido en el teléfono, antes de subirlo.
class ArchivoElegido {
  const ArchivoElegido({required this.nombre, required this.tamano});

  final String nombre;

  /// Bytes.
  final int tamano;

  static const tamanoMaximo = 20 * 1024 * 1024;
  static const extensiones = ['pdf', 'jpg', 'jpeg', 'png'];

  String get extension => nombre.contains('.') ? nombre.split('.').last.toLowerCase() : '';

  /// Mensaje de error o null si el archivo es válido.
  String? get problema {
    if (!extensiones.contains(extension)) return '$nombre no es PDF, JPG ni PNG';
    if (tamano > tamanoMaximo) return '$nombre supera 2 MB';
    return null;
  }
}

class ArchivoCargado {
  const ArchivoCargado({
    required this.nombre,
    required this.version,
    required this.subidoPor,
    required this.subidoEn,
    required this.tamano,
  });

  final String nombre;
  final int version;
  final Responsable subidoPor;
  final DateTime subidoEn;
  final int tamano;
}

class FilaExpediente {
  const FilaExpediente({required this.requisito, required this.estado, this.versiones = const []});

  final Requisito requisito;
  final EstadoDocumento estado;
  final List<ArchivoCargado> versiones;

  ArchivoCargado? get actual => versiones.isEmpty ? null : versiones.last;
}

class Avance {
  const Avance({required this.aplicables, required this.cargados});

  factory Avance.de(Iterable<FilaExpediente> filas) => Avance(
    aplicables: filas.where((f) => f.estado != EstadoDocumento.noAplica).length,
    cargados: filas.where((f) => f.estado == EstadoDocumento.cargado).length,
  );

  final int aplicables;
  final int cargados;

  int get pendientes => aplicables - cargados;
  int get porcentaje => aplicables == 0 ? 0 : (cargados * 100 / aplicables).round();
  double get fraccion => aplicables == 0 ? 0 : cargados / aplicables;
  bool get completo => aplicables > 0 && pendientes == 0;
}

/// Color de cada apartado; es el mismo de su carpeta en la app web.
enum Tono { turquesa, verde, ambar, morado }

/// Apartados de la trayectoria, en el orden de la app web, con los textos de su formulario.
enum SeccionTrayectoria {
  formacion(
    etiqueta: 'Formación',
    nombre: 'Formación académica',
    descripcion: 'Estudios y grados obtenidos, con su comprobante.',
    tono: Tono.turquesa,
    agregar: 'Agregar formación',
    campoTitulo: 'Estudio o grado académico',
    ejemplo: 'Ej. Maestría en Ciencias',
    campoPeriodo: 'Periodo o fecha',
    campoDetalle: 'Institución y descripción',
  ),
  idiomas(
    etiqueta: 'Idiomas',
    nombre: 'Idiomas',
    descripcion: 'Lenguas que dominas, con su nivel y certificado.',
    tono: Tono.morado,
    agregar: 'Agregar idioma',
    campoTitulo: 'Idioma',
    ejemplo: 'Ej. Inglés',
    campoPeriodo: 'Fecha del certificado',
    campoDetalle: 'Nivel y certificado o examen',
  ),
  experiencia(
    etiqueta: 'Experiencia',
    nombre: 'Experiencia profesional',
    descripcion: 'Puestos y funciones dentro y fuera de la institución.',
    tono: Tono.verde,
    agregar: 'Agregar experiencia',
    campoTitulo: 'Puesto o experiencia',
    ejemplo: 'Ej. Docente de Redes',
    campoPeriodo: 'Periodo o fecha',
    campoDetalle: 'Institución y actividades realizadas',
  ),
  capacitacion(
    etiqueta: 'Capacitación',
    nombre: 'Capacitación',
    descripcion: 'Cursos, talleres y diplomados para tu actualización.',
    tono: Tono.ambar,
    agregar: 'Agregar capacitación',
    campoTitulo: 'Curso, taller o diplomado',
    ejemplo: 'Ej. Docencia Digital',
    campoPeriodo: 'Periodo o fecha',
    campoDetalle: 'Institución, duración y descripción',
  ),
  certificaciones(
    etiqueta: 'Certificaciones',
    nombre: 'Certificaciones',
    descripcion: 'Acreditaciones y certificaciones vigentes.',
    tono: Tono.turquesa,
    agregar: 'Agregar certificación',
    campoTitulo: 'Certificación',
    ejemplo: 'Ej. Certificación en Redes (CCNA)',
    campoPeriodo: 'Fecha de obtención / vigencia',
    campoDetalle: 'Institución y descripción',
  ),
  distinciones(
    etiqueta: 'Distinciones',
    nombre: 'Distinciones y premios',
    descripcion: 'Reconocimientos y premios que has recibido.',
    tono: Tono.ambar,
    agregar: 'Agregar distinción',
    campoTitulo: 'Distinción o premio',
    ejemplo: 'Ej. Reconocimiento a la labor docente',
    campoPeriodo: 'Fecha',
    campoDetalle: 'Quién la otorga y por qué',
  ),
  institucional(
    etiqueta: 'Actividad',
    nombre: 'Actividad institucional',
    descripcion: 'Comisiones, tutorías y participaciones en la institución.',
    tono: Tono.verde,
    agregar: 'Agregar actividad',
    campoTitulo: 'Actividad o participación',
    ejemplo: 'Ej. Tutoría de grupo',
    campoPeriodo: 'Periodo o fecha',
    campoDetalle: 'Institución y descripción',
  ),
  estadias(
    etiqueta: 'Estadías y tesis',
    nombre: 'Dirección de estadías y tesis',
    descripcion: 'Estadías, tesis y proyectos de estudiantes que has dirigido.',
    tono: Tono.morado,
    agregar: 'Agregar trabajo dirigido',
    campoTitulo: 'Estadía, tesis o proyecto dirigido',
    ejemplo: 'Ej. Asesoría de estadía: sistema de inventarios',
    campoPeriodo: 'Periodo o fecha',
    campoDetalle: 'Estudiante, nivel y estado',
  ),
  membresias(
    etiqueta: 'Membresías',
    nombre: 'Membresías y cuerpos académicos',
    descripcion: 'Asociaciones, redes, colegios y cuerpos académicos.',
    tono: Tono.turquesa,
    agregar: 'Agregar membresía',
    campoTitulo: 'Asociación, red o cuerpo académico',
    ejemplo: 'Ej. Cuerpo académico de Tecnologías Educativas',
    campoPeriodo: 'Periodo o fecha',
    campoDetalle: 'Tipo de participación',
  ),
  propiedad(
    etiqueta: 'Propiedad intelectual',
    nombre: 'Propiedad intelectual',
    descripcion: 'Derechos de autor, patentes y otros registros.',
    tono: Tono.morado,
    agregar: 'Agregar registro',
    campoTitulo: 'Obra o invención registrada',
    ejemplo: 'Ej. Software de control escolar',
    campoPeriodo: 'Fecha de registro',
    campoDetalle: 'Tipo de registro y número',
  ),
  vinculacion(
    etiqueta: 'Vinculación',
    nombre: 'Vinculación',
    descripcion: 'Proyectos y servicios con empresas y organismos.',
    tono: Tono.verde,
    agregar: 'Agregar vinculación',
    campoTitulo: 'Proyecto o servicio',
    ejemplo: 'Ej. Capacitación en herramientas digitales',
    campoPeriodo: 'Periodo o fecha',
    campoDetalle: 'Empresa u organismo y tu participación',
  );

  const SeccionTrayectoria({
    required this.etiqueta,
    required this.nombre,
    required this.descripcion,
    required this.tono,
    required this.agregar,
    required this.campoTitulo,
    required this.ejemplo,
    required this.campoPeriodo,
    required this.campoDetalle,
  });

  /// Nombre corto para carpetas y pestañas.
  final String etiqueta;

  /// Nombre completo del apartado.
  final String nombre;
  final String descripcion;
  final Tono tono;
  final String agregar;
  final String campoTitulo;
  final String ejemplo;
  final String campoPeriodo;
  final String campoDetalle;
}

class RegistroTrayectoria {
  const RegistroTrayectoria({
    required this.id,
    required this.seccion,
    required this.titulo,
    required this.periodo,
    required this.detalle,
    this.evidencia,
  });

  final String id;
  final SeccionTrayectoria seccion;

  /// Hasta 200 caracteres.
  final String titulo;

  /// Hasta 100 caracteres.
  final String periodo;

  /// Hasta 2,000 caracteres.
  final String detalle;
  final ArchivoElegido? evidencia;
}

/// Archivo de la carpeta personal: solo lo ve el propio docente.
class ArchivoPersonal {
  const ArchivoPersonal({required this.id, required this.tipo, required this.archivo, required this.fecha});

  final String id;

  /// Qué documento es (por ejemplo «CURP»); lo escribe el docente.
  final String tipo;
  final ArchivoElegido archivo;
  final DateTime fecha;
}

/// Solo sugerencias para nombrar archivos personales; se puede escribir cualquier nombre.
const sugerenciasPersonales = [
  'CURP',
  'INE',
  'Acta de nacimiento',
  'Comprobante de domicilio',
  'Constancia de situación fiscal',
  'RFC',
];

enum DecisionSugerencia { pendiente, mia, ajena }

class Publicacion {
  const Publicacion({
    required this.id,
    required this.titulo,
    required this.tipo,
    required this.autores,
    required this.anio,
    required this.fuente,
    this.sugerencia = false,
  });

  final String id;
  final String titulo;
  final String tipo;
  final String autores;
  final int anio;
  final String fuente;

  /// Coincidencia de nombre que el docente confirma o descarta.
  final bool sugerencia;
}

class FaseProyecto {
  const FaseProyecto(this.titulo, this.fechas);

  final String titulo;
  final String fechas;
}

class Proyecto {
  const Proyecto({
    required this.id,
    required this.titulo,
    required this.tituloCorto,
    required this.descripcion,
    required this.categoria,
    required this.responsable,
    required this.periodo,
    required this.avance,
    required this.cronograma,
  });

  final String id;
  final String titulo;
  final String tituloCorto;
  final String descripcion;
  final String categoria;
  final String responsable;
  final String periodo;

  /// Porcentaje 0–100.
  final int avance;
  final List<FaseProyecto> cronograma;
}

enum TipoAviso { fecha, avance, institucional, publicacion }

class Aviso {
  const Aviso({required this.tipo, required this.titulo, required this.detalle, required this.cuando});

  final TipoAviso tipo;
  final String titulo;
  final String detalle;
  final String cuando;
}
