import 'modelos.dart';

// DATOS SIMULADOS. Son los ejemplos del diseño móvil y de la app web;
// no corresponden a personas, publicaciones ni proyectos reales.
// Se reemplazarán por los datos de Firebase.

/// Credenciales de la demostración (no hay autenticación real todavía).
const correoDemo = 'maria@ejemplo.mx';
const contrasenaDemo = 'Demo2026';

/// Segunda cuenta: un docente activo que ya terminó su nuevo ingreso.
const correoActivoDemo = 'carlos@ejemplo.mx';

const docenteDemo = Docente(
  id: 'maria',
  nombre: 'María López',
  correoAcceso: correoDemo,
  departamento: 'Tecnologías de la Información',
  contratacion: Contratacion.tiempoCompleto,
  estado: EstadoDocente.nuevoIngreso,
  nacionalidad: Nacionalidad.mexicana,
  contacto: Contacto(
    correoPersonal: 'maria@ejemplo.mx',
    telefono: '771 000 0000',
    semblanza: 'Docente e investigadora en sistemas distribuidos.',
  ),
);

const docenteActivoDemo = Docente(
  id: 'carlos',
  nombre: 'Carlos Ruiz',
  correoAcceso: correoActivoDemo,
  departamento: 'Tecnologías de la Información',
  contratacion: Contratacion.tiempoCompleto,
  estado: EstadoDocente.activo,
  nacionalidad: Nacionalidad.mexicana,
  nomina: '00000 (ejemplo)',
  correoInstitucional: 'carlos.ruiz@ejemplo.edu.mx',
  contacto: Contacto(
    correoPersonal: 'carlos@ejemplo.mx',
    telefono: '771 000 0001',
    semblanza: 'Docente de redes y seguridad informática.',
  ),
);

/// Documentos que Administración ya cargó en el expediente de muestra.
const requisitosCargadosPorAdministracion = [1, 2];

const trayectoriaDemo = <RegistroTrayectoria>[
  RegistroTrayectoria(
    id: 'f1',
    seccion: SeccionTrayectoria.formacion,
    titulo: 'Maestría en Ciencias de la Computación',
    periodo: '2018 – 2020',
    detalle: 'Universidad de ejemplo',
    evidencia: ArchivoElegido(nombre: 'titulo_maestria.pdf', tamano: 512004),
  ),
  RegistroTrayectoria(
    id: 'f2',
    seccion: SeccionTrayectoria.formacion,
    titulo: 'Licenciatura en Ingeniería en Sistemas',
    periodo: '2013 – 2017',
    detalle: 'Instituto de ejemplo',
    evidencia: ArchivoElegido(nombre: 'titulo_licenciatura.pdf', tamano: 498112),
  ),
  RegistroTrayectoria(
    id: 'f3',
    seccion: SeccionTrayectoria.formacion,
    titulo: 'Especialidad en Docencia',
    periodo: '2021',
    detalle: 'Centro de ejemplo',
    evidencia: ArchivoElegido(nombre: 'diploma_especialidad.pdf', tamano: 301877),
  ),
  RegistroTrayectoria(
    id: 'e1',
    seccion: SeccionTrayectoria.experiencia,
    titulo: 'Docente de tiempo completo',
    periodo: '2020 – actual',
    detalle: 'Institución de ejemplo · Asignaturas de redes y sistemas',
  ),
  RegistroTrayectoria(
    id: 'e2',
    seccion: SeccionTrayectoria.experiencia,
    titulo: 'Desarrolladora de sistemas',
    periodo: '2017 – 2020',
    detalle: 'Empresa de ejemplo',
  ),
  RegistroTrayectoria(
    id: 'c1',
    seccion: SeccionTrayectoria.capacitacion,
    titulo: 'Diseño de experiencias de aprendizaje',
    periodo: 'Octubre 2026',
    detalle: 'Taller de muestra · 20 horas',
  ),
  RegistroTrayectoria(
    id: 'c2',
    seccion: SeccionTrayectoria.capacitacion,
    titulo: 'Herramientas digitales para la docencia',
    periodo: 'Agosto 2026',
    detalle: 'Curso de muestra · 30 horas',
  ),
  RegistroTrayectoria(
    id: 'c3',
    seccion: SeccionTrayectoria.capacitacion,
    titulo: 'Evaluación del aprendizaje',
    periodo: 'Junio 2026',
    detalle: 'Curso de muestra · 20 horas',
  ),
  RegistroTrayectoria(
    id: 'i1',
    seccion: SeccionTrayectoria.institucional,
    titulo: 'Participación en academia',
    periodo: '2026',
    detalle: 'Actividad institucional de muestra.',
  ),
  RegistroTrayectoria(
    id: 'l1',
    seccion: SeccionTrayectoria.idiomas,
    titulo: 'Inglés',
    periodo: '2025',
    detalle: 'Nivel B2 · Examen de muestra',
    evidencia: ArchivoElegido(nombre: 'certificado_ingles.pdf', tamano: 286500),
  ),
  RegistroTrayectoria(
    id: 'k1',
    seccion: SeccionTrayectoria.certificaciones,
    titulo: 'Certificación en competencias digitales docentes',
    periodo: '2025',
    detalle: 'Organismo de muestra · Vigente hasta 2028',
    evidencia: ArchivoElegido(nombre: 'certificado_competencias.pdf', tamano: 402300),
  ),
  RegistroTrayectoria(
    id: 'd1',
    seccion: SeccionTrayectoria.distinciones,
    titulo: 'Reconocimiento a la labor docente',
    periodo: '2025',
    detalle: 'Institución de muestra · Por su desempeño en el aula',
  ),
  RegistroTrayectoria(
    id: 's1',
    seccion: SeccionTrayectoria.estadias,
    titulo: 'Asesoría de estadía: sistema de inventarios',
    periodo: 'Mayo – agosto 2026',
    detalle: 'Estudiante de muestra · TSU en Tecnologías de la Información · Concluida',
  ),
  RegistroTrayectoria(
    id: 'm1',
    seccion: SeccionTrayectoria.membresias,
    titulo: 'Cuerpo académico de muestra',
    periodo: '2024 – actualidad',
    detalle: 'Integrante · Línea de tecnologías educativas',
  ),
  RegistroTrayectoria(
    id: 'v1',
    seccion: SeccionTrayectoria.vinculacion,
    titulo: 'Capacitación en herramientas digitales',
    periodo: '2026',
    detalle: 'Empresa de muestra · Instructora',
  ),
];

const publicacionesDemo = <Publicacion>[
  Publicacion(
    id: 'p1',
    titulo: 'Detección de anomalías en redes',
    tipo: 'Artículo',
    autores: 'María López',
    anio: 2023,
    fuente: 'Revista de ejemplo',
  ),
  Publicacion(
    id: 'p2',
    titulo: 'Plataformas educativas abiertas',
    tipo: 'Capítulo',
    autores: 'María López, Ana Martínez',
    anio: 2022,
    fuente: 'Editorial de ejemplo',
  ),
  Publicacion(
    id: 'p3',
    titulo: 'Modelo de seguimiento de egresados',
    tipo: 'Artículo',
    autores: 'M. L. (ejemplo)',
    anio: 2021,
    fuente: 'Congreso de ejemplo',
    sugerencia: true,
  ),
  Publicacion(
    id: 'p4',
    titulo: 'Competencias digitales en educación superior',
    tipo: 'Artículo',
    autores: 'M. López (ejemplo)',
    anio: 2026,
    fuente: 'Revista de muestra',
    sugerencia: true,
  ),
];

const _cronograma = [
  FaseProyecto('Preparación', 'Ene – Mar 2026'),
  FaseProyecto('Desarrollo', 'Abr – Oct 2026'),
  FaseProyecto('Cierre', 'Nov – Dic 2026'),
];

const proyectosDemo = <Proyecto>[
  Proyecto(
    id: 'pr1',
    titulo: 'Sistema de monitoreo de laboratorios',
    tituloCorto: 'Monitoreo de laboratorios',
    descripcion: 'Proyecto de muestra para dar seguimiento al uso de los laboratorios.',
    categoria: 'Investigación aplicada',
    responsable: 'M. L.',
    periodo: '2026 – 2027',
    avance: 40,
    cronograma: _cronograma,
  ),
  Proyecto(
    id: 'pr2',
    titulo: 'Rediseño de contenidos de Redes',
    tituloCorto: 'Contenidos de Redes',
    descripcion: 'Proyecto de muestra para actualizar los materiales de la asignatura.',
    categoria: 'Docencia',
    responsable: 'M. L.',
    periodo: '2026',
    avance: 70,
    cronograma: _cronograma,
  ),
  Proyecto(
    id: 'pr3',
    titulo: 'Vinculación con la industria',
    tituloCorto: 'Vinculación con la industria',
    descripcion: 'Proyecto de muestra de colaboración con empresas de la región.',
    categoria: 'Vinculación',
    responsable: 'M. L.',
    periodo: '2025 – 2026',
    avance: 15,
    cronograma: _cronograma,
  ),
];

const avisosDemo = <Aviso>[
  Aviso(
    tipo: TipoAviso.fecha,
    titulo: 'Fecha límite próxima',
    detalle: 'Sube tus documentos antes del 30 de octubre',
    cuando: 'Hoy',
  ),
  Aviso(
    tipo: TipoAviso.avance,
    titulo: 'Administración cargó 2 documentos',
    detalle: 'Tu expediente avanzó',
    cuando: 'Ayer',
  ),
  Aviso(
    tipo: TipoAviso.publicacion,
    titulo: 'Sugerencia de publicación',
    detalle: 'Confirma si es tuya',
    cuando: 'Hace 4 d',
  ),
];

/// Avisos de un docente activo: ya no hay fechas de nuevo ingreso.
const avisosActivoDemo = <Aviso>[
  Aviso(
    tipo: TipoAviso.publicacion,
    titulo: 'Sugerencia de publicación',
    detalle: 'Confirma si es tuya',
    cuando: 'Hoy',
  ),
  Aviso(
    tipo: TipoAviso.fecha,
    titulo: 'Actualiza tu trayectoria',
    detalle: 'Agrega lo que hiciste este cuatrimestre antes del 15 de diciembre',
    cuando: 'Ayer',
  ),
  Aviso(
    tipo: TipoAviso.institucional,
    titulo: 'Expediente completo',
    detalle: 'RH validó tu expediente de ingreso',
    cuando: 'Hace 2 sem',
  ),
];
