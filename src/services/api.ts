import { mockAdminOverview, type Activity, type Question } from '../data/mockData'

// Mantiene los endpoints relativos para funcionar en una subcarpeta del hosting.
const apiUrl = (file: string) => new URL(`api/${file}`, window.location.href).toString()

type ApiResponse<T> = { ok?: boolean; message?: string; data?: T } & Partial<T>

export type AdminCourse = {
  id: number
  materia_id: number | null
  materia: string | null
  anio: number | null
  division: string | null
  nombre: string
  especialidad: string | null
  turno: string | null
  ciclo_lectivo: number
  activo: number
}

export type AdminStudent = {
  id: number
  dni: string
  nombre: string
  fecha_nacimiento: string | null
  curso_id: number | null
  curso: string | null
  inscripcion_activa: number | null
}

export type AdminPracticalWork = {
  id: number
  tema_id: number
  tema: string
  titulo: string
  descripcion: string | null
  codigo: string
  activo: number
  secciones: number
}

export type AdminSection = {
  id: number
  trabajo_practico_id: number
  trabajo_practico: string
  titulo: string
  descripcion: string | null
  orden: number
  activo: number
  ejercicios: number
}

export type AdminActivity = {
  id: number
  tema: string
  trabajo_practico: string | null
  seccion: string | null
  actividad: string
  estado: string
  visible_alumno: number
  acceso_habilitado: number
  puntaje_habilitado: number
  ejercicios: number
}

export type ClassActivityCatalogItem = {
  id: number
  activityId: number
  classActivityId: number | null
  assigned: boolean
  title: string
  desc: string
  topic: string
  work: string | null
  section: string | null
  level: string
  points: number
  exercises: number
  state: string
  visible: boolean
  accessEnabled: boolean
  pointsEnabled: boolean
  icon: string
}

export type AdminExercise = {
  id: number
  actividad_id: number
  actividad: string
  seccion_tp_id: number | null
  seccion: string | null
  orden: number
  codigo: string | null
  consigna: string
  formula_respuesta: string | null
  tolerancia: string | null
  activo: number
  combinaciones: number
}

export type AdminValueBank = {
  id: number
  seccion_tp_id: number
  seccion: string
  trabajo_practico: string
  magnitud: string
  magnitud_simbolo: string
  unidad: string
  nombre: string
  codigo: string
  descripcion: string | null
  orden: number
  activo: number
  valores: number
}

export type StudentHistoryItem = {
  attemptId: number
  activityId: number
  activity: string
  mode: string
  state: string
  correct: number
  answers: number
  points: number
  startedAt: string
  lastAccessAt: string
  finishedAt: string | null
  durationSeconds: number
  lastExerciseId: number | null
  lastExercise: string | null
}

export type AttemptStart = {
  attemptId: number
  mode: 'evaluativo' | 'practica'
  pointsEnabled: boolean
  guest?: boolean
  activityType?: string
  languageActivity?: LanguageActivity
  mathActivity?: MathRationalActivity
}

export type LanguageStep = {
  key: 'sujeto' | 'predicado' | 'nucleo_sujeto' | 'verbo'
  prompt: string
  attempts: number
  selection: number[]
}

export type LanguageActivity = {
  title: string
  intro: string
  sentenceId: number
  sentence: string
  words: string[]
  currentStep: LanguageStep['key'] | 'completada'
  currentStepIndex: number
  steps: LanguageStep[]
  completed: boolean
  analysis?: { words: string[]; answer: Record<string, number[]> } | null
  correct?: boolean
  message?: string
}

export type MathRoute = {
  key: string
  title: string
  intro: string
  formula: string
  xLabel: string
  yLabel: string
  unit: string
  parameters: Array<{ label: string; value: string }>
  rows: Array<{ x: number; y: number; label?: string }>
  asymptote?: number | null
}

export type MathTask = {
  id: string
  type: 'calc' | 'choice' | 'closing' | 'completed'
  routeKey?: string
  routeTitle?: string
  prompt?: string
  unit?: string
  xLabel?: string
  options?: string[]
}

export type MathRationalActivity = {
  title: string
  activityType: 'matematica_funcion_racional'
  version: { a: number; b: number }
  currentTaskIndex: number
  totalTasks: number
  totalCalculations: number
  correctCalculations: number
  attempts: number
  completed: boolean
  currentTask: MathTask
  routes: MathRoute[]
  conclusions: string[]
  correct?: boolean
  message?: string
}

export type AnswerValidation = {
  correct: boolean
  correctAnswer: string
  explanation: string
  numericValue?: number | null
  expectedNumericValue?: number
  tolerance?: number
  needsReview?: boolean
}

export type AdminProgressItem = {
  intento_id: number
  alumno_id: number
  dni: string
  alumno: string
  curso_id: number | null
  curso: string | null
  actividad_id: number
  actividad: string
  modo: string
  estado: string
  correctas: number
  cantidad_respuestas: number
  puntaje: number
  iniciado_en: string
  ultimo_acceso_en: string
  finalizado_en: string | null
  duracion_segundos: number
  ultimo_ejercicio: string | null
}

export type AdminProgressAnswer = {
  id: number
  intento_id: number
  ejercicio_id: number
  orden: number
  codigo: string | null
  consigna: string
  respuesta_texto: string | null
  respuesta_numero: string | null
  correcta: number
  estado_revision: string
  puntos_docente: string | null
  comentario_docente: string | null
  revisado_en: string | null
  respondido_en: string
}

export type AdminStudentSummary = {
  alumno: { id: number; dni: string; nombre: string; fecha_nacimiento: string | null }
  totales: {
    intentos: number
    respuestas: number
    pendientes: number
    correctas: number
    puntos_docente: number
    tiempo_segundos: number
  }
  intentos: Array<{
    intento_id: number
    actividad: string
    modo: string
    estado: string
    correctas: number
    cantidad_respuestas: number
    puntaje: number
    iniciado_en: string
    finalizado_en: string | null
    duracion_segundos: number
  }>
}

export type AdminPointsSheet = {
  activities: Array<{
    id: number
    title: string
    points: number
    pointsEnabled: boolean
    visible: boolean
    accessEnabled: boolean
    state: string
  }>
  students: Array<{
    id: number
    dni: string
    nombre: string
    curso: string | null
    points: Record<string, number>
    total: number
  }>
}

export type AdminTeacher = {
  id: number
  dni: string
  nombre: string
  apellido: string
  email: string | null
}

export type TeacherClass = {
  id: number
  nombre: string
  codigo: string
  activa: number
  escuela: string
  materia: string
  curso: string
  ciclo_lectivo: number
  pendientes: number
  validados: number
}

export type ClassEnrollment = {
  id: number
  estado: 'pendiente' | 'validada' | 'rechazada'
  solicitada_en: string
  validada_en: string | null
  alumno_id: number
  dni: string
  nombre: string
  apellido: string | null
  clase_id: number
  codigo: string
  clase: string
  escuela: string
  materia: string
  curso: string
}

async function request<T>(file: string, options?: RequestInit): Promise<T> {
  const response = await fetch(apiUrl(file), {
    headers: { 'Content-Type': 'application/json', ...(options?.headers || {}) },
    credentials: 'same-origin',
    ...options,
  })

  const payload = (await response.json().catch(() => ({}))) as ApiResponse<T>
  if (!response.ok) throw new Error(payload.message || `Error ${response.status}`)
  if (payload.ok === false) throw new Error(payload.message || 'No se pudo completar la solicitud.')

  return (payload.data ?? payload) as T
}

export const api = {
  async adminSession(): Promise<{ authorized: boolean; teacher?: AdminTeacher | null }> {
    return request<{ authorized: boolean; teacher?: AdminTeacher | null }>('admin/sesion.php')
  },

  async adminLogin(dni: string): Promise<{ authorized: boolean; teacher?: AdminTeacher | null }> {
    return request<{ authorized: boolean; teacher?: AdminTeacher | null }>('admin/login.php', {
      method: 'POST',
      body: JSON.stringify({ dni }),
    })
  },

  async adminRegister(payload: { dni: string; nombre: string; apellido: string; email?: string }): Promise<{ authorized: boolean; teacher?: AdminTeacher | null }> {
    return request<{ authorized: boolean; teacher?: AdminTeacher | null }>('admin/registro.php', {
      method: 'POST',
      body: JSON.stringify(payload),
    })
  },

  async teacherClasses(): Promise<TeacherClass[]> {
    return request<TeacherClass[]>('admin/clases.php')
  },

  async createTeacherClass(payload: { escuela: string; materia: string; curso: string; anio?: number; division?: string }): Promise<TeacherClass> {
    return request<TeacherClass>('admin/clases.php', {
      method: 'POST',
      body: JSON.stringify(payload),
    })
  },

  async classEnrollments(): Promise<ClassEnrollment[]> {
    return request<ClassEnrollment[]>('admin/inscripciones-clase.php')
  },

  async updateClassEnrollment(id: number, estado: 'validada' | 'rechazada'): Promise<{ id: number; estado: string }> {
    return request<{ id: number; estado: string }>(`admin/inscripciones-clase.php?id=${encodeURIComponent(id)}`, {
      method: 'PATCH',
      body: JSON.stringify({ estado }),
    })
  },

  async registerStudentInClass(payload: { dni: string; clave: string; nombre: string; apellido: string; codigo: string }) {
    return request<{ status: string }>('registro-alumno.php', {
      method: 'POST',
      body: JSON.stringify(payload),
    })
  },

  async adminLogout(): Promise<{ authorized: boolean }> {
    return request<{ authorized: boolean }>('admin/logout.php', {
      method: 'POST',
      body: JSON.stringify({}),
    })
  },

  async activities(studentId?: number): Promise<Activity[]> {
    const query = studentId ? `?student_id=${encodeURIComponent(studentId)}` : ''
    return request<Activity[]>(`obtener-ejercicio.php${query}`)
  },

  async login(dni: string) {
    return request<{ student: { id: number; name: string; guest?: boolean } }>('validar-dni.php', {
      method: 'POST',
      body: JSON.stringify({ dni }),
    })
  },

  async guestLogin() {
    return request<{ student: { id: number; name: string; guest: boolean } }>('invitado.php', {
      method: 'POST',
      body: JSON.stringify({}),
    })
  },

  async questions(activityId: number, attemptId?: number): Promise<Question[]> {
    const query = new URLSearchParams({ actividad_id: String(activityId) })
    if (attemptId) query.set('intento_id', String(attemptId))
    return request<Question[]>(`obtener-ejercicio.php?${query.toString()}`)
  },

  async startAttempt(payload: { activityId: number; studentId: number; guest?: boolean; classActivityId?: number | null }): Promise<AttemptStart> {
    return request<AttemptStart>('iniciar-intento.php', {
      method: 'POST',
      body: JSON.stringify(payload),
    })
  },

  async languageActivity(activityId: number, studentId: number): Promise<LanguageActivity> {
    const query = new URLSearchParams({ actividad_id: String(activityId), student_id: String(studentId) })
    return request<LanguageActivity>(`lengua-actividad.php?${query.toString()}`)
  },

  async validateLanguageStep(payload: { activityId: number; studentId: number; attemptId: number; step: string; selection: number[]; elapsedSeconds?: number }): Promise<LanguageActivity> {
    return request<LanguageActivity>('lengua-actividad.php', {
      method: 'POST',
      body: JSON.stringify(payload),
    })
  },

  async mathRationalActivity(activityId: number, studentId: number): Promise<MathRationalActivity> {
    const query = new URLSearchParams({ actividad_id: String(activityId), student_id: String(studentId) })
    return request<MathRationalActivity>(`matematica-racional.php?${query.toString()}`)
  },

  async validateMathRational(payload: { activityId: number; studentId: number; attemptId: number; answer?: string; optionIndex?: number; elapsedSeconds?: number }): Promise<MathRationalActivity> {
    return request<MathRationalActivity>('matematica-racional.php', {
      method: 'POST',
      body: JSON.stringify(payload),
    })
  },

  async validateAnswer(payload: { exerciseId: number; answer: string; attemptId?: number }): Promise<AnswerValidation> {
    return request<AnswerValidation>('validar-respuesta.php', {
      method: 'POST',
      body: JSON.stringify(payload),
    })
  },

  async saveProgress(payload: { attemptId: number; exerciseId: number; answer: string; correct: boolean; numericValue?: number | null; elapsedSeconds?: number }) {
    return request<{ saved: boolean }>('guardar-progreso.php', {
      method: 'POST',
      body: JSON.stringify(payload),
    })
  },

  async saveResult(payload: { activityId: number; studentId: number; attemptId?: number; correct: number; attempts: number; score: number; elapsedSeconds?: number }) {
    try {
      return await request<{ saved: boolean; points: number; alreadyAwarded?: boolean }>('finalizar-actividad.php', {
        method: 'POST',
        body: JSON.stringify(payload),
      })
    } catch {
      return { saved: false }
    }
  },

  async studentHistory(studentId: number): Promise<StudentHistoryItem[]> {
    return request<StudentHistoryItem[]>(`historial-alumno.php?student_id=${encodeURIComponent(studentId)}`)
  },

  async results() {
    try {
      return await request<typeof mockAdminOverview>('resultados.php')
    } catch {
      return mockAdminOverview
    }
  },

  async adminCourses(): Promise<AdminCourse[]> {
    return request<AdminCourse[]>('admin/cursos.php')
  },

  async adminStudents(courseId?: number): Promise<AdminStudent[]> {
    const query = courseId ? `?curso_id=${encodeURIComponent(courseId)}` : ''
    return request<AdminStudent[]>(`admin/alumnos.php${query}`)
  },

  async adminPracticalWorks(): Promise<AdminPracticalWork[]> {
    return request<AdminPracticalWork[]>('admin/trabajos-practicos.php')
  },

  async adminSections(practicalWorkId?: number): Promise<AdminSection[]> {
    const query = practicalWorkId ? `?trabajo_practico_id=${encodeURIComponent(practicalWorkId)}` : ''
    return request<AdminSection[]>(`admin/secciones.php${query}`)
  },

  async adminActivities(): Promise<AdminActivity[]> {
    return request<AdminActivity[]>('admin/actividades.php')
  },

  async classActivityCatalog(classId?: number): Promise<ClassActivityCatalogItem[]> {
    const query = classId ? `?clase_id=${encodeURIComponent(classId)}` : ''
    return request<ClassActivityCatalogItem[]>(`admin/actividades-clase.php${query}`)
  },

  async assignClassActivity(payload: { clase_id: number; actividad_id: number; visible_alumno?: boolean; acceso_habilitado?: boolean; puntaje_habilitado?: boolean; estado?: string }): Promise<unknown> {
    return request<unknown>('admin/actividades-clase.php', {
      method: 'POST',
      body: JSON.stringify(payload),
    })
  },

  async setClassActivityStatus(
    id: number,
    payload: { visible_alumno: boolean; acceso_habilitado: boolean; puntaje_habilitado: boolean; estado: string },
  ): Promise<unknown> {
    return request<unknown>(`admin/actividades-clase.php?id=${encodeURIComponent(id)}`, {
      method: 'PATCH',
      body: JSON.stringify(payload),
    })
  },

  async unassignClassActivity(id: number): Promise<unknown> {
    return request<unknown>(`admin/actividades-clase.php?id=${encodeURIComponent(id)}`, {
      method: 'DELETE',
    })
  },

  async adminExercises(activityId?: number): Promise<AdminExercise[]> {
    const query = activityId ? `?actividad_id=${encodeURIComponent(activityId)}` : ''
    return request<AdminExercise[]>(`admin/ejercicios.php${query}`)
  },

  async adminValueBanks(sectionId?: number): Promise<AdminValueBank[]> {
    const query = sectionId ? `?seccion_id=${encodeURIComponent(sectionId)}` : ''
    return request<AdminValueBank[]>(`admin/bancos-valores.php${query}`)
  },

  async adminProgress(filters?: { courseId?: number; activityId?: number; state?: string; pendingOnly?: boolean }): Promise<AdminProgressItem[]> {
    const params = new URLSearchParams()
    if (filters?.courseId) params.set('curso_id', String(filters.courseId))
    if (filters?.activityId) params.set('actividad_id', String(filters.activityId))
    if (filters?.state) params.set('estado', filters.state)
    if (filters?.pendingOnly) params.set('pendientes', '1')
    const query = params.toString() ? `?${params.toString()}` : ''
    return request<AdminProgressItem[]>(`admin/progreso.php${query}`)
  },

  async adminPointsSheet(courseId?: number): Promise<AdminPointsSheet> {
    const query = courseId ? `?curso_id=${encodeURIComponent(courseId)}` : ''
    return request<AdminPointsSheet>(`admin/planilla-puntos.php${query}`)
  },

  async adminProgressAnswers(attemptId: number): Promise<AdminProgressAnswer[]> {
    return request<AdminProgressAnswer[]>(`admin/progreso.php?intento_id=${encodeURIComponent(attemptId)}`)
  },

  async reviewAnswer(id: number, payload: { estado_revision: 'pendiente' | 'correcta' | 'incorrecta'; comentario_docente?: string; puntos_docente?: number | null }) {
    return request<AdminProgressAnswer>(`admin/corregir-respuesta.php?id=${encodeURIComponent(id)}`, {
      method: 'PATCH',
      body: JSON.stringify(payload),
    })
  },

  async studentSummary(studentId: number): Promise<AdminStudentSummary> {
    return request<AdminStudentSummary>(`admin/resumen-alumno.php?alumno_id=${encodeURIComponent(studentId)}`)
  },

  progressExportUrl(filters?: { courseId?: number; activityId?: number; state?: string; pendingOnly?: boolean }) {
    const params = new URLSearchParams()
    if (filters?.courseId) params.set('curso_id', String(filters.courseId))
    if (filters?.activityId) params.set('actividad_id', String(filters.activityId))
    if (filters?.state) params.set('estado', filters.state)
    if (filters?.pendingOnly) params.set('pendientes', '1')
    const query = params.toString() ? `?${params.toString()}` : ''
    return apiUrl(`admin/exportar-progreso.php${query}`)
  },

  async setActivityStatus(
    id: number,
    payload: { visible_alumno: boolean; acceso_habilitado: boolean; puntaje_habilitado: boolean; estado: string },
  ): Promise<unknown> {
    return request<unknown>(`admin/habilitar-actividad.php?id=${encodeURIComponent(id)}`, {
      method: 'PATCH',
      body: JSON.stringify(payload),
    })
  },
}
