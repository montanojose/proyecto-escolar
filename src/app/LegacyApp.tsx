import { useEffect, useMemo, useRef, useState, type ReactNode } from 'react'
import {
  api,
  type AdminActivity,
  type AdminCourse,
  type AdminProgressAnswer,
  type AdminExercise,
  type AdminValueBank,
  type AdminProgressItem,
  type AdminStudentSummary,
  type AdminPracticalWork,
  type AdminSection,
  type AdminStudent,
  type AdminPointsSheet,
  type AdminTeacher,
  type TeacherClass,
  type ClassEnrollment,
  type ClassActivityCatalogItem,
  type AttemptStart,
  type LanguageActivity,
  type MathRationalActivity,
  type MathRoute,
  type StudentHistoryItem,
} from '../services/api'
import { mockActivities, type Activity, type Question } from '../data/mockData'

type Screen = 'home' | 'activities' | 'access' | 'instructions' | 'challenge' | 'result' | 'history' | 'admin'
type AdminTab = 'points' | 'activities' | 'students' | 'works' | 'sections' | 'progress' | 'exercises' | 'banks' | 'classes' | 'enrollments'
type SubjectFilter = 'electrotecnia1' | 'electrotecnia2' | 'aconcagua' | 'lengua' | 'matematica'

const defaultStudent = { id: 0, name: '' }

const displayState = (value?: string | null) => {
  const text = value || ''
  const labels: Record<string, string> = {
    Practica: 'Práctica',
    practica: 'práctica',
    Proximamente: 'Próximamente',
    proximamente: 'próximamente',
  }
  return labels[text] || text
}

function Bolt() {
  return <span className="bolt" aria-hidden="true">*</span>
}

function Brand({ onHome }: { onHome: () => void }) {
  return <button className="brand" onClick={onHome} aria-label="Ir al inicio"><span className="brand-mark"><Bolt /></span><span>Electro<span>Desafio</span></span></button>
}

function Circuit({ active = false }: { active?: boolean }) {
  return <div className={`circuit ${active ? 'on' : ''}`} aria-hidden="true"><div className="wire h one"/><div className="wire h two"/><div className="wire v one"/><div className="node n1"/><div className="node n2"/><div className="node n3"/><div className="lamp">O</div><div className="resistor">R</div></div>
}

function MathGraph({ route, zoom }: { route: MathRoute; zoom?: boolean }) {
  const rows = route.rows || []
  const visibleRows = zoom && rows.length > 2 ? rows.slice(0, Math.max(2, rows.length - 1)) : rows
  const points = visibleRows.length ? visibleRows : [{ x: 0, y: 0 }]
  const maxX = Math.max(...points.map((row) => Number(row.x) || 0), 1)
  const maxY = Math.max(...points.map((row) => Number(row.y) || 0), Number(route.asymptote || 0), 1)
  const minX = Math.min(...points.map((row) => Number(row.x) || 0), 0)
  const pad = 34
  const width = 420
  const height = 250
  const sx = (x: number) => pad + ((x - minX) / Math.max(maxX - minX, 0.000001)) * (width - pad * 2)
  const sy = (y: number) => height - pad - (y / Math.max(maxY, 0.000001)) * (height - pad * 2)
  const polyline = points.map((row) => `${sx(row.x)},${sy(row.y)}`).join(' ')
  const asymptoteY = route.asymptote ? sy(route.asymptote) : null

  return <svg className="math-graph-svg" viewBox={`0 0 ${width} ${height}`} role="img" aria-label={`GrÃ¡fico ${route.title}`}>
    <line x1={pad} y1={height - pad} x2={width - pad} y2={height - pad}/>
    <line x1={pad} y1={pad} x2={pad} y2={height - pad}/>
    {asymptoteY !== null && <line className="asymptote" x1={pad} y1={asymptoteY} x2={width - pad} y2={asymptoteY}/>}
    {points.length > 1 && <polyline points={polyline}/>}
    {points.map((row, index) => <g key={`${route.key}-${index}`}><circle cx={sx(row.x)} cy={sy(row.y)} r="5"/><text x={sx(row.x) + 7} y={sy(row.y) - 7}>{index + 1}</text></g>)}
    <text className="axis-label" x={width - 90} y={height - 7}>{route.xLabel}</text>
    <text className="axis-label" x={8} y={18}>{route.yLabel}</text>
  </svg>
}

function MathFormulaImage({ route }: { route?: MathRoute }) {
  const key = route?.key || ''
  const title = route?.title || 'FunciÃ³n racional'

  return <svg className="math-formula-image" viewBox="0 0 560 170" role="img" aria-label={`FÃ³rmula ${title}`}>
    <rect x="1" y="1" width="558" height="168" rx="12"/>
    {key === 'coulomb' && <>
      <text className="eq-title" x="22" y="30">FÃ³rmula que vas a usar</text>
      <text className="eq-main" x="32" y="76">F(r) = F0 Â· (r0 / r)Â²</text>
      <text className="eq-sub" x="32" y="112">Para cada paso: F(ri) = F0 Â· (r0 / ri)Â²</text>
      <text className="eq-note" x="32" y="142">Dato conocido: F(r0) = F0</text>
      <text className="eq-note" x="32" y="160">Sale de Coulomb cuando las cargas no cambian.</text>
    </>}
    {key === 'campo' && <>
      <text className="eq-title" x="22" y="30">FÃ³rmula que vas a usar</text>
      <text className="eq-main" x="32" y="76">E(r) = k Â· |Q| / rÂ²</text>
      <text className="eq-sub" x="32" y="112">Para cada paso: E(ri) = k Â· |Q| / riÂ²</text>
      <text className="eq-note" x="32" y="145">Dato fijo: k = 9 Ã— 10â¹ NÂ·mÂ²/CÂ²</text>
    </>}
    {key === 'resistencia' && <>
      <text className="eq-title" x="22" y="30">FÃ³rmula que vas a usar</text>
      <text className="eq-main" x="32" y="76">R(x) = Rf Â· x / (Rf + x)</text>
      <text className="eq-sub" x="32" y="112">Para cada paso: R(xi) = Rf Â· xi / (Rf + xi)</text>
      <text className="eq-note" x="32" y="145">Dato conocido: Rf es la resistencia fija.</text>
    </>}
    {key === 'poblacion' && <>
      <text className="eq-title" x="22" y="30">FÃ³rmula que vas a usar</text>
      <text className="eq-main" x="32" y="76">P(t) = Pmax Â· t / (t + c)</text>
      <text className="eq-sub" x="32" y="112">Para cada paso: P(ti) = Pmax Â· ti / (ti + c)</text>
      <text className="eq-note" x="32" y="145">Dato conocido: Pmax es el valor lÃ­mite.</text>
    </>}
    {!['coulomb', 'campo', 'resistencia', 'poblacion'].includes(key) && <text className="eq-main" x="42" y="92">{route?.formula || 'FunciÃ³n racional'}</text>}
  </svg>
}

function formatDuration(seconds: number) {
  if (!seconds) return '0 min'
  const minutes = Math.floor(seconds / 60)
  const rest = seconds % 60
  return minutes > 0 ? `${minutes} min ${rest}s` : `${rest}s`
}

function statusLabel(item: Activity) {
  if (item.accessEnabled === false || item.state === 'Proximamente') return 'Bloqueada'
  if (item.pointsEnabled) return 'Con puntos'
  return 'Practica'
}

function AdminDashboard({ nav }: { nav: ReactNode }) {
  const [tab, setTab] = useState<AdminTab>('classes')
  const [courses, setCourses] = useState<AdminCourse[]>([])
  const [students, setStudents] = useState<AdminStudent[]>([])
  const [works, setWorks] = useState<AdminPracticalWork[]>([])
  const [sections, setSections] = useState<AdminSection[]>([])
  const [adminActivities, setAdminActivities] = useState<AdminActivity[]>([])
  const [adminExercises, setAdminExercises] = useState<AdminExercise[]>([])
  const [valueBanks, setValueBanks] = useState<AdminValueBank[]>([])
  const [progress, setProgress] = useState<AdminProgressItem[]>([])
  const [pointsSheet, setPointsSheet] = useState<AdminPointsSheet>({ activities: [], students: [] })
  const [teacher, setTeacher] = useState<AdminTeacher | null>(null)
  const [teacherClasses, setTeacherClasses] = useState<TeacherClass[]>([])
  const [classEnrollments, setClassEnrollments] = useState<ClassEnrollment[]>([])
  const [classActivityCatalog, setClassActivityCatalog] = useState<ClassActivityCatalogItem[]>([])
  const [selectedAttempt, setSelectedAttempt] = useState<AdminProgressItem | null>(null)
  const [selectedAnswers, setSelectedAnswers] = useState<AdminProgressAnswer[]>([])
  const [studentSummary, setStudentSummary] = useState<AdminStudentSummary | null>(null)
  const [selectedCourse, setSelectedCourse] = useState(101)
  const [selectedClass, setSelectedClass] = useState(0)
  const [progressActivity, setProgressActivity] = useState(0)
  const [progressState, setProgressState] = useState('')
  const [pendingOnly, setPendingOnly] = useState(false)
  const [loadingAdmin, setLoadingAdmin] = useState(true)
  const [adminError, setAdminError] = useState('')
  const [authorized, setAuthorized] = useState(false)
  const [checkingAuth, setCheckingAuth] = useState(true)
  const [adminDni, setAdminDni] = useState('')
  const [authMessage, setAuthMessage] = useState('')
  const [authMode, setAuthMode] = useState<'login' | 'register'>('login')
  const [teacherForm, setTeacherForm] = useState({ dni: '', nombre: '', apellido: '', email: '' })
  const [classForm, setClassForm] = useState({ escuela: '', materia: '', curso: '', anio: '', division: '' })

  const loadAdmin = async () => {
    if (!authorized) return
    setLoadingAdmin(true)
    setAdminError('')
    try {
      const [courseRows, studentRows, workRows, sectionRows, activityRows, exerciseRows, bankRows, progressRows, pointsRows, classRows, enrollmentRows, catalogRows] = await Promise.all([
        api.adminCourses(),
        api.adminStudents(selectedCourse),
        api.adminPracticalWorks(),
        api.adminSections(),
        api.adminActivities(),
        api.adminExercises(),
        api.adminValueBanks(),
        api.adminProgress({ courseId: selectedCourse, activityId: progressActivity, state: progressState, pendingOnly }),
        api.adminPointsSheet(selectedCourse),
        api.teacherClasses(),
        api.classEnrollments(),
        api.classActivityCatalog(selectedClass || undefined),
      ])
      setCourses(courseRows)
      setStudents(studentRows)
      setWorks(workRows)
      setSections(sectionRows)
      setAdminActivities(activityRows)
      setAdminExercises(exerciseRows)
      setValueBanks(bankRows)
      setProgress(progressRows)
      setPointsSheet(pointsRows)
      setTeacherClasses(classRows)
      setClassEnrollments(enrollmentRows)
      setClassActivityCatalog(catalogRows)
      if (selectedAttempt && !progressRows.some((item) => item.intento_id === selectedAttempt.intento_id)) {
        setSelectedAttempt(null)
        setSelectedAnswers([])
      }
      if (!courseRows.some((course) => course.id === selectedCourse) && courseRows[0]) setSelectedCourse(courseRows[0].id)
      if (!selectedClass && classRows[0]) setSelectedClass(classRows[0].id)
    } catch (error) {
      setAdminError(error instanceof Error ? error.message : 'No se pudieron cargar los datos del panel.')
    } finally {
      setLoadingAdmin(false)
    }
  }

  useEffect(() => {
    api.adminSession()
      .then((session) => {
        setAuthorized(Boolean(session.authorized))
        setTeacher(session.teacher || null)
      })
      .catch(() => setAuthorized(false))
      .finally(() => {
        setCheckingAuth(false)
        setLoadingAdmin(false)
      })
  }, [])

  useEffect(() => {
    if (authorized) loadAdmin()
  }, [authorized, selectedCourse, selectedClass, progressActivity, progressState, pendingOnly])

  const loginDocente = async () => {
    const cleanDni = adminDni.replace(/\D/g, '')
    if (cleanDni.length < 7) {
      setAuthMessage('Ingresá tu DNI docente.')
      return
    }

    setLoadingAdmin(true)
    setAuthMessage('Validando acceso docente...')
    try {
      await api.adminLogin(cleanDni)
      const session = await api.adminSession()
      setTeacher(session.teacher || null)
      setAuthorized(true)
      setAuthMessage('')
      setAdminDni('')
    } catch (error) {
      setAuthorized(false)
      setAuthMessage(error instanceof Error ? error.message : 'DNI docente no autorizado.')
    } finally {
      setLoadingAdmin(false)
    }
  }

  const registerDocente = async () => {
    const cleanDni = teacherForm.dni.replace(/\D/g, '')
    if (cleanDni.length < 7 || !teacherForm.nombre.trim() || !teacherForm.apellido.trim()) {
      setAuthMessage('Completá nombre, apellido y DNI.')
      return
    }

    setLoadingAdmin(true)
    setAuthMessage('Creando acceso docente...')
    try {
      const response = await api.adminRegister({ ...teacherForm, dni: cleanDni })
      setTeacher(response.teacher || null)
      setAuthorized(true)
      setAuthMessage('')
      setTeacherForm({ dni: '', nombre: '', apellido: '', email: '' })
    } catch (error) {
      setAuthorized(false)
      setAuthMessage(error instanceof Error ? error.message : 'No se pudo registrar el docente.')
    } finally {
      setLoadingAdmin(false)
    }
  }

  const createClass = async () => {
    if (!classForm.escuela.trim() || !classForm.materia.trim() || !classForm.curso.trim()) {
      setAdminError('Completá escuela, materia y curso para crear la clase.')
      return
    }

    await api.createTeacherClass({
      escuela: classForm.escuela,
      materia: classForm.materia,
      curso: classForm.curso,
      anio: Number(classForm.anio) || undefined,
      division: classForm.division,
    })
    setClassForm({ escuela: '', materia: '', curso: '', anio: '', division: '' })
    await loadAdmin()
    setTab('classes')
  }

  const updateEnrollment = async (id: number, estado: 'validada' | 'rechazada') => {
    await api.updateClassEnrollment(id, estado)
    await loadAdmin()
  }

  const logoutDocente = async () => {
    await api.adminLogout().catch(() => null)
    setAuthorized(false)
    setTeacher(null)
    setAdminActivities([])
    setProgress([])
    setSelectedAttempt(null)
    setSelectedAnswers([])
    setStudentSummary(null)
  }

  const togglePoints = async (activity: AdminActivity) => {
    await api.setActivityStatus(activity.id, {
      visible_alumno: Boolean(activity.visible_alumno),
      acceso_habilitado: Boolean(activity.acceso_habilitado),
      puntaje_habilitado: !activity.puntaje_habilitado,
      estado: activity.puntaje_habilitado ? 'Practica' : 'Disponible',
    })
    await loadAdmin()
  }

  const setActivityMode = async (
    activity: AdminActivity,
    mode: 'hidden' | 'blocked' | 'practice' | 'points',
  ) => {
    const config = {
      hidden: { visible_alumno: false, acceso_habilitado: false, puntaje_habilitado: false, estado: 'Oculta' },
      blocked: { visible_alumno: true, acceso_habilitado: false, puntaje_habilitado: false, estado: 'Bloqueada' },
      practice: { visible_alumno: true, acceso_habilitado: true, puntaje_habilitado: false, estado: 'Practica' },
      points: { visible_alumno: true, acceso_habilitado: true, puntaje_habilitado: true, estado: 'Disponible' },
    }[mode]
    await api.setActivityStatus(activity.id, config)
    await loadAdmin()
  }

  const assignActivityToClass = async (item: ClassActivityCatalogItem) => {
    if (!selectedClass) {
      setAdminError('Primero creá o seleccioná una clase.')
      return
    }

    await api.assignClassActivity({
      clase_id: selectedClass,
      actividad_id: item.activityId,
      visible_alumno: true,
      acceso_habilitado: true,
      puntaje_habilitado: false,
      estado: 'Practica',
    })
    await loadAdmin()
  }

  const setClassActivityMode = async (
    item: ClassActivityCatalogItem,
    mode: 'hidden' | 'blocked' | 'practice' | 'points',
  ) => {
    if (!item.classActivityId) return
    const config = {
      hidden: { visible_alumno: false, acceso_habilitado: false, puntaje_habilitado: false, estado: 'Oculta' },
      blocked: { visible_alumno: true, acceso_habilitado: false, puntaje_habilitado: false, estado: 'Bloqueada' },
      practice: { visible_alumno: true, acceso_habilitado: true, puntaje_habilitado: false, estado: 'Practica' },
      points: { visible_alumno: true, acceso_habilitado: true, puntaje_habilitado: true, estado: 'Disponible' },
    }[mode]
    await api.setClassActivityStatus(item.classActivityId, config)
    await loadAdmin()
  }

  const showAttempt = async (item: AdminProgressItem) => {
    setSelectedAttempt(item)
    setSelectedAnswers(await api.adminProgressAnswers(item.intento_id))
    setStudentSummary(await api.studentSummary(item.alumno_id))
    setTab('progress')
  }

  const reviewAnswer = async (answerId: number, state: 'correcta' | 'incorrecta') => {
    const puntosRaw = window.prompt('Puntos manuales para esta respuesta (opcional):', state === 'correcta' ? '1' : '0')
    const comment = window.prompt('Comentario docente (opcional):', '')
    const points = puntosRaw === null || puntosRaw.trim() === '' ? null : Number(puntosRaw.replace(',', '.'))
    await api.reviewAnswer(answerId, { estado_revision: state, comentario_docente: comment || '', puntos_docente: Number.isFinite(points) ? points : null })
    if (selectedAttempt) {
      setSelectedAnswers(await api.adminProgressAnswers(selectedAttempt.intento_id))
      setStudentSummary(await api.studentSummary(selectedAttempt.alumno_id))
    }
    await loadAdmin()
  }

  const enabledActivities = adminActivities.filter((item) => item.visible_alumno && item.acceso_habilitado).length
  const pointActivities = adminActivities.filter((item) => item.puntaje_habilitado).length
  const awardedPoints = pointsSheet.students.reduce((sum, item) => sum + Number(item.total || 0), 0)
  const totalExercises = adminActivities.reduce((sum, item) => sum + Number(item.ejercicios || 0), 0)
  const reviewPending = progress.reduce((sum, item) => sum + Math.max(0, Number(item.cantidad_respuestas || 0) - Number(item.correctas || 0)), 0)
  const exportUrl = api.progressExportUrl({ courseId: selectedCourse, activityId: progressActivity, state: progressState, pendingOnly })
  const selectedClassRow = teacherClasses.find((item) => item.id === selectedClass) || null
  const visibleClassEnrollments = classEnrollments.filter((item) => !selectedClass || item.clase_id === selectedClass)
  const pendingClassEnrollments = visibleClassEnrollments.filter((item) => item.estado === 'pendiente')
  const validatedClassEnrollments = visibleClassEnrollments.filter((item) => item.estado === 'validada')
  const assignedClassActivities = classActivityCatalog.filter((item) => item.assigned)
  const enabledClassActivities = assignedClassActivities.filter((item) => item.visible && item.accessEnabled)
  const mainAdminTabs: { id: AdminTab; label: string; hint: string }[] = [
    { id: 'classes', label: 'Mi clase', hint: 'Actividades y código' },
    { id: 'enrollments', label: 'Solicitudes', hint: `${pendingClassEnrollments.length} pendientes` },
    { id: 'progress', label: 'Seguimiento', hint: 'Intentos y respuestas' },
    { id: 'points', label: 'Puntos', hint: `${awardedPoints} pts` },
  ]
  const advancedAdminTabs: { id: AdminTab; label: string }[] = [
    { id: 'activities', label: 'Catálogo global' },
    { id: 'students', label: 'Alumnos' },
    { id: 'exercises', label: 'Ejercicios' },
    { id: 'banks', label: 'Bancos' },
    { id: 'works', label: 'TPs' },
    { id: 'sections', label: 'Secciones' },
  ]

  if (checkingAuth) {
    return <main className="site-shell page compact">{nav}<section className="access-layout admin-login"><div><p className="eyebrow"><span/> Vista docente</p><h1>Verificando<br/><em>acceso</em></h1><p className="lead">Estamos comprobando si ya tenés una sesión docente abierta.</p></div><div className="mission-card"><strong>Cargando...</strong></div></section></main>
  }

  if (!authorized) {
    return <main className="site-shell page compact">{nav}<section className="access-layout admin-login"><div><p className="eyebrow"><span/> Vista docente</p><h1>{authMode === 'login' ? 'Acceso' : 'Registro'}<br/><em>docente.</em></h1><p className="lead">Cada profesora entra con su DNI, crea su clase y valida las inscripciones de sus alumnos.</p></div><form className="access-card" onSubmit={(event) => { event.preventDefault(); authMode === 'login' ? loginDocente() : registerDocente() }}>{authMode === 'login' ? <><label htmlFor="admin-dni">DNI docente</label><input id="admin-dni" value={adminDni} onChange={(event) => setAdminDni(event.target.value.replace(/[^0-9]/g, ''))} placeholder="Tu DNI" inputMode="numeric" autoComplete="off"/></> : <><label htmlFor="teacher-name">Nombre</label><input id="teacher-name" value={teacherForm.nombre} onChange={(event) => setTeacherForm((value) => ({ ...value, nombre: event.target.value }))} placeholder="Nombre"/><label htmlFor="teacher-last">Apellido</label><input id="teacher-last" value={teacherForm.apellido} onChange={(event) => setTeacherForm((value) => ({ ...value, apellido: event.target.value }))} placeholder="Apellido"/><label htmlFor="teacher-dni">DNI</label><input id="teacher-dni" value={teacherForm.dni} onChange={(event) => setTeacherForm((value) => ({ ...value, dni: event.target.value.replace(/[^0-9]/g, '') }))} placeholder="DNI" inputMode="numeric"/><label htmlFor="teacher-email">Email opcional</label><input id="teacher-email" value={teacherForm.email} onChange={(event) => setTeacherForm((value) => ({ ...value, email: event.target.value }))} placeholder="correo@escuela.edu"/></>}<p className={authMessage.includes('Validando') || authMessage.includes('Creando') ? 'success-message' : 'error-message'} aria-live="polite">{authMessage || (authMode === 'login' ? 'Panel protegido.' : 'El DNI será tu acceso docente.')}</p><button className="button primary full" type="submit" disabled={loadingAdmin}>{loadingAdmin ? 'Procesando...' : authMode === 'login' ? 'Entrar al panel' : 'Crear acceso'}</button><button className="text-button full switch-auth" type="button" onClick={() => { setAuthMode(authMode === 'login' ? 'register' : 'login'); setAuthMessage('') }}>{authMode === 'login' ? 'Registrar nueva profesora' : 'Ya tengo acceso docente'}</button></form></section></main>
  }

  return <main className="site-shell page admin">
    {nav}
    <section className="admin-head teacher-head"><div><p className="eyebrow"><span/> Vista docente</p><h1>Panel <em>docente</em></h1>{teacher && <p className="lead admin-teacher-name">{teacher.nombre} {teacher.apellido} / DNI {teacher.dni}</p>}</div><div className="admin-head-actions"><button className="button primary" onClick={loadAdmin} disabled={loadingAdmin}>{loadingAdmin ? 'Actualizando...' : 'Actualizar'}</button><button className="button dark" onClick={logoutDocente}>Salir</button></div></section>
    <section className="teacher-context">
      <div className="teacher-context-main">
        <small>CLASE ACTUAL</small>
        <h2>{selectedClassRow ? selectedClassRow.curso : 'Elegí o creá una clase'}</h2>
        <p>{selectedClassRow ? `${selectedClassRow.materia} / ${selectedClassRow.escuela}` : 'Desde acá vas a validar alumnos, asignar actividades y revisar avances sin mezclar cursos.'}</p>
      </div>
      <label className="teacher-picker"><span>Cambiar clase</span><select value={selectedClass} onChange={(event) => setSelectedClass(Number(event.target.value))}><option value={0}>Sin clase seleccionada</option>{teacherClasses.map((item) => <option key={item.id} value={item.id}>{item.curso} / {item.codigo}</option>)}</select></label>
      <div className="teacher-code"><small>CÓDIGO</small><strong>{selectedClassRow?.codigo || '-'}</strong></div>
    </section>
    <div className="admin-kpis teacher-kpis"><div><small>SOLICITUDES</small><b>{pendingClassEnrollments.length}</b><span>pendientes de validar</span></div><div><small>ALUMNOS</small><b>{validatedClassEnrollments.length}</b><span>validados en esta clase</span></div><div><small>ACTIVIDADES</small><b>{enabledClassActivities.length}</b><span>{assignedClassActivities.length} asignadas en total</span></div></div>
    {adminError && <p className="server-notice" role="status">{adminError}</p>}
    <section className="admin-panel real-admin">
      <div className="panel-heading teacher-panel-heading"><div><h2>Trabajo de la clase</h2><p>Usá estas cuatro vistas para manejar el día a día. Las herramientas de carga quedan abajo.</p></div><label className="course-picker"><span>Curso base</span><select value={selectedCourse} onChange={(event) => setSelectedCourse(Number(event.target.value))}>{courses.map((course) => <option key={course.id} value={course.id}>{course.nombre} - {course.ciclo_lectivo}</option>)}</select></label></div>
      <div className="teacher-worktabs">{mainAdminTabs.map((item) => <button key={item.id} className={tab === item.id ? 'active' : ''} onClick={() => setTab(item.id)}><strong>{item.label}</strong><small>{item.hint}</small></button>)}</div>
      <details className="admin-tools" open={advancedAdminTabs.some((item) => item.id === tab)}><summary>Herramientas avanzadas</summary><div className="admin-tabs advanced-tabs">{advancedAdminTabs.map((item) => <button key={item.id} className={tab === item.id ? 'active' : ''} onClick={() => setTab(item.id)}>{item.label}</button>)}</div></details>
      {loadingAdmin ? <p className="admin-empty">Cargando datos...</p> : <>
        {tab === 'points' && <div className="points-sheet"><div className="sheet-head"><div><h2>Planilla de puntos</h2><p>Estos son los puntos reales guardados para sumar al examen en papel.</p></div><strong>{awardedPoints} pts</strong></div>{pointsSheet.activities.length === 0 ? <p className="admin-empty">Todavía no hay actividades visibles o con puntaje.</p> : <div className="sheet-scroll"><table><thead><tr><th>Alumno</th>{pointsSheet.activities.map((activity) => <th key={activity.id}><span>{activity.title}</span><small>{activity.pointsEnabled ? `${activity.points} pts` : 'práctica'}</small></th>)}<th>Total</th></tr></thead><tbody>{pointsSheet.students.map((student) => <tr key={student.id}><td><strong>{student.nombre}</strong><small>DNI {student.dni}</small></td>{pointsSheet.activities.map((activity) => <td key={activity.id}>{Number(student.points[String(activity.id)] || 0)}</td>)}<td><b>{student.total}</b></td></tr>)}</tbody></table></div>}</div>}
        {tab === 'classes' && <div className="teacher-classes"><div className="class-overview"><article><small>RESUMEN</small><h3>{selectedClassRow ? selectedClassRow.curso : 'Todavía no hay clase seleccionada'}</h3><p>{selectedClassRow ? `${validatedClassEnrollments.length} alumnos validados, ${pendingClassEnrollments.length} solicitudes pendientes y ${assignedClassActivities.length} actividades asignadas.` : 'Creá una clase o elegí una existente para empezar a trabajar.'}</p></article><button className="button dark" onClick={() => setTab('enrollments')}>Ver solicitudes</button></div><details className="class-form-panel"><summary>Crear nueva clase</summary><div className="class-form"><input value={classForm.escuela} onChange={(event) => setClassForm((value) => ({ ...value, escuela: event.target.value }))} placeholder="Escuela"/><input value={classForm.materia} onChange={(event) => setClassForm((value) => ({ ...value, materia: event.target.value }))} placeholder="Materia"/><input value={classForm.curso} onChange={(event) => setClassForm((value) => ({ ...value, curso: event.target.value }))} placeholder="Curso, ej. 3 1 - Electrotecnia I"/><input value={classForm.anio} onChange={(event) => setClassForm((value) => ({ ...value, anio: event.target.value.replace(/[^0-9]/g, '') }))} placeholder="Año"/><input value={classForm.division} onChange={(event) => setClassForm((value) => ({ ...value, division: event.target.value }))} placeholder="División"/><button className="button primary" onClick={createClass}>Crear clase</button></div></details><details className="class-list-panel"><summary>Mis clases ({teacherClasses.length})</summary><div className="admin-table admin-table-classes"><div className="tr th"><span>CLASE</span><span>CÓDIGO</span><span>ESCUELA</span><span>ALUMNOS</span><span>ESTADO</span></div>{teacherClasses.length === 0 ? <p className="admin-empty">Todavía no creaste clases.</p> : teacherClasses.map((item) => <div className="tr" key={item.id}><strong>{item.curso}<small>{item.materia}</small></strong><span>{item.codigo}</span><span>{item.escuela}</span><span>{Number(item.validados || 0)} validados / {Number(item.pendientes || 0)} pendientes</span><span><i className={item.activa ? 'dot active' : 'dot'}/>{item.activa ? 'Activa' : 'Inactiva'}</span></div>)}</div></details><div className="catalog-head"><h2>Actividades para esta clase</h2><p>{selectedClass ? 'Asigná actividades y configurá cómo las ve este curso.' : 'Creá o seleccioná una clase para asignar actividades.'}</p></div><div className="admin-table admin-table-class-catalog"><div className="tr th"><span>ACTIVIDAD</span><span>TEMA</span><span>ESTADO EN CLASE</span><span>EJERCICIOS</span><span>ACCIONES</span></div>{classActivityCatalog.map((item) => <div className="tr" key={item.id}><strong>{item.title}<small>{item.work || item.section || item.desc}</small></strong><span>{item.topic}</span><span><i className={item.assigned && item.accessEnabled ? 'dot active' : 'dot'}/>{item.assigned ? displayState(item.state) : 'No asignada'}</span><span>{item.exercises}</span><div className="state-actions">{!item.assigned ? <button className="pill on" onClick={() => assignActivityToClass(item)}>Asignar</button> : <><button className="pill" onClick={() => setClassActivityMode(item, 'hidden')}>Ocultar</button><button className="pill" onClick={() => setClassActivityMode(item, 'blocked')}>Bloquear</button><button className={!item.pointsEnabled && item.accessEnabled ? 'pill on' : 'pill'} onClick={() => setClassActivityMode(item, 'practice')}>Práctica</button><button className={item.pointsEnabled ? 'pill on' : 'pill'} onClick={() => setClassActivityMode(item, 'points')}>Puntos</button>{item.classActivityId && <button className="pill danger" onClick={async () => { await api.unassignClassActivity(item.classActivityId!); await loadAdmin() }}>Quitar</button>}</>}</div></div>)}</div></div>}
        {tab === 'enrollments' && <div className="admin-table admin-table-enrollments"><div className="tr th"><span>ALUMNO</span><span>CLASE</span><span>ESTADO</span><span>FECHA</span><span>ACCIONES</span></div>{visibleClassEnrollments.length === 0 ? <p className="admin-empty">Todavía no hay solicitudes para esta clase.</p> : visibleClassEnrollments.map((item) => <div className="tr" key={item.id}><strong>{item.nombre} {item.apellido || ''}<small>DNI {item.dni}</small></strong><span>{item.curso} / {item.codigo}</span><span><i className={item.estado === 'validada' ? 'dot active' : 'dot'}/>{item.estado}</span><span>{item.solicitada_en}</span><div className="state-actions"><button className="pill on" onClick={() => updateEnrollment(item.id, 'validada')}>Validar</button><button className="pill danger" onClick={() => updateEnrollment(item.id, 'rechazada')}>Rechazar</button></div></div>)}</div>}
        {tab === 'activities' && <div className="admin-table admin-table-activities"><div className="tr th"><span>ACTIVIDAD</span><span>SECCIÓN</span><span>ESTADO</span><span>EJERCICIOS</span><span>ACCIONES</span></div>{adminActivities.map((item) => <div className="tr" key={item.id}><strong>{item.actividad}<small>{item.tema}{item.trabajo_practico ? ` / ${item.trabajo_practico}` : ''}</small></strong><span>{item.seccion || 'Sin sección'}</span><span><i className={item.acceso_habilitado ? 'dot active' : 'dot'}/>{item.visible_alumno ? displayState(item.estado) : 'Oculta'}</span><span>{item.ejercicios}</span><div className="state-actions"><button className="pill" onClick={() => setActivityMode(item, 'hidden')}>Ocultar</button><button className="pill" onClick={() => setActivityMode(item, 'blocked')}>Bloquear</button><button className={!item.puntaje_habilitado && item.acceso_habilitado ? 'pill on' : 'pill'} onClick={() => setActivityMode(item, 'practice')}>Práctica</button><button className={item.puntaje_habilitado ? 'pill on' : 'pill'} onClick={() => setActivityMode(item, 'points')}>Puntos</button></div></div>)}</div>}
        {tab === 'students' && <div className="admin-table admin-table-students"><div className="tr th"><span>ALUMNO</span><span>DNI</span><span>NACIMIENTO</span><span>CURSO</span><span>ESTADO</span></div>{students.map((item) => <div className="tr" key={item.id}><strong>{item.nombre}</strong><span>{item.dni}</span><span>{item.fecha_nacimiento || '-'}</span><span>{item.curso || '-'}</span><span><i className={item.inscripcion_activa ? 'dot active' : 'dot'}/>{item.inscripcion_activa ? 'Activo' : 'Sin curso'}</span></div>)}</div>}
        {tab === 'exercises' && <div className="admin-table admin-table-exercises"><div className="tr th"><span>EJERCICIO</span><span>ACTIVIDAD</span><span>FÓRMULA</span><span>TOL.</span><span>COMB.</span></div>{adminExercises.map((item) => <div className="tr" key={item.id}><strong>{item.orden}. {item.codigo || `Ejercicio ${item.id}`}<small>{item.consigna}</small></strong><span>{item.actividad}</span><span>{item.formula_respuesta || 'Revisión'}</span><span>{item.tolerancia ? `${Number(item.tolerancia) * 100}%` : '-'}</span><span><i className={item.activo ? 'dot active' : 'dot'}/>{item.combinaciones}</span></div>)}</div>}
        {tab === 'banks' && <div className="admin-table admin-table-banks"><div className="tr th"><span>BANCO</span><span>SECCIÓN</span><span>MAGNITUD</span><span>UNIDAD</span><span>VALORES</span></div>{valueBanks.length === 0 ? <p className="admin-empty">Todavía no hay bancos de valores cargados para las secciones.</p> : valueBanks.map((item) => <div className="tr" key={item.id}><strong>{item.codigo} - {item.nombre}<small>{item.descripcion || item.trabajo_practico}</small></strong><span>{item.seccion}</span><span>{item.magnitud}</span><span>{item.unidad}</span><span><i className={item.activo ? 'dot active' : 'dot'}/>{item.valores}</span></div>)}</div>}
        {tab === 'progress' && <div className="progress-section"><details className="progress-filter-panel"><summary>Filtros y exportación</summary><div className="progress-filters"><select value={progressActivity} onChange={(event) => setProgressActivity(Number(event.target.value))}><option value={0}>Todas las actividades</option>{adminActivities.map((item) => <option key={item.id} value={item.id}>{item.actividad}</option>)}</select><select value={progressState} onChange={(event) => setProgressState(event.target.value)}><option value="">Todos los estados</option><option value="iniciado">Iniciado</option><option value="en_progreso">En progreso</option><option value="finalizado">Finalizado</option></select><label><input type="checkbox" checked={pendingOnly} onChange={(event) => setPendingOnly(event.target.checked)}/> Solo pendientes</label><a className="button dark export-link" href={exportUrl}>Exportar CSV</a></div></details><div className="progress-admin"><div className="admin-table admin-table-progress"><div className="tr th"><span>ALUMNO</span><span>ACTIVIDAD</span><span>ESTADO</span><span>RESP.</span><span>DETALLE</span></div>{progress.length === 0 ? <p className="admin-empty">Todavía no hay intentos para este curso.</p> : progress.map((item) => <div className="tr" key={item.intento_id}><strong>{item.alumno}<small>DNI {item.dni} / {formatDuration(Number(item.duracion_segundos || 0))}</small></strong><span>{item.actividad}</span><span><i className={item.estado === 'finalizado' ? 'dot active' : 'dot'}/>{item.estado} / {displayState(item.modo)}</span><span>{item.cantidad_respuestas} ({item.correctas} correctas)</span><button className="pill" onClick={() => showAttempt(item)}>Ver</button></div>)}</div>{selectedAttempt && <aside className="attempt-detail"><div><small>INTENTO #{selectedAttempt.intento_id}</small><h3>{selectedAttempt.alumno}</h3><p>{selectedAttempt.actividad}</p><p>Inicio: {selectedAttempt.iniciado_en} / Último acceso: {selectedAttempt.ultimo_acceso_en}</p>{studentSummary && <div className="summary-strip"><span><b>{studentSummary.totales.intentos}</b><small>intentos</small></span><span><b>{studentSummary.totales.respuestas}</b><small>respuestas</small></span><span><b>{studentSummary.totales.pendientes}</b><small>pendientes</small></span><span><b>{formatDuration(studentSummary.totales.tiempo_segundos)}</b><small>total</small></span></div>}</div><div className="answer-list">{selectedAnswers.length === 0 ? <p>No hay respuestas guardadas para este intento.</p> : selectedAnswers.map((answer) => <article key={answer.id}><small>Ejercicio {answer.orden} / {answer.estado_revision}{answer.puntos_docente ? ` / ${answer.puntos_docente} pts` : ''}</small><strong>{answer.consigna}</strong><p>{answer.respuesta_texto || answer.respuesta_numero || 'Sin respuesta'}</p>{answer.comentario_docente && <p>Comentario: {answer.comentario_docente}</p>}<div className="review-actions"><button className={answer.estado_revision === 'correcta' ? 'pill on' : 'pill'} onClick={() => reviewAnswer(answer.id, 'correcta')}>Correcta</button><button className={answer.estado_revision === 'incorrecta' ? 'pill danger' : 'pill'} onClick={() => reviewAnswer(answer.id, 'incorrecta')}>Incorrecta</button></div></article>)}</div></aside>}</div></div>}
        {tab === 'works' && <div className="admin-table admin-table-works"><div className="tr th"><span>TRABAJO PRÁCTICO</span><span>TEMA</span><span>CÓDIGO</span><span>SECCIONES</span><span>ESTADO</span></div>{works.map((item) => <div className="tr" key={item.id}><strong>{item.titulo}<small>{item.descripcion || ''}</small></strong><span>{item.tema}</span><span>{item.codigo}</span><span>{item.secciones}</span><span><i className={item.activo ? 'dot active' : 'dot'}/>{item.activo ? 'Activo' : 'Inactivo'}</span></div>)}</div>}
        {tab === 'sections' && <div className="admin-table admin-table-sections"><div className="tr th"><span>SECCIÓN</span><span>TP</span><span>ORDEN</span><span>EJERCICIOS</span><span>ESTADO</span></div>{sections.map((item) => <div className="tr" key={item.id}><strong>{item.titulo}<small>{item.descripcion || ''}</small></strong><span>{item.trabajo_practico}</span><span>{item.orden}</span><span>{item.ejercicios}</span><span><i className={item.activo ? 'dot active' : 'dot'}/>{item.activo ? 'Activa' : 'Inactiva'}</span></div>)}</div>}
      </>}
    </section>
  </main>
}

export default function App() {
  const [screen, setScreen] = useState<Screen>('home')
  const [activities, setActivities] = useState<Activity[]>([])
  const [activity, setActivity] = useState<Activity>(mockActivities[0])
  const [questions, setQuestions] = useState<Question[]>([])
  const [history, setHistory] = useState<StudentHistoryItem[]>([])
  const [attempt, setAttempt] = useState<AttemptStart | null>(null)
  const [student, setStudent] = useState(defaultStudent)
  const [loading, setLoading] = useState(false)
  const [serverError, setServerError] = useState('')
  const [dni, setDni] = useState('')
  const [accessMessage, setAccessMessage] = useState('')
  const [studentAccessMode, setStudentAccessMode] = useState<'login' | 'register'>('login')
  const [studentRegisterForm, setStudentRegisterForm] = useState({ nombre: '', apellido: '', dni: '', clave: '', codigo: '' })
  const [step, setStep] = useState(1)
  const [answer, setAnswer] = useState('')
  const [selectedWords, setSelectedWords] = useState<number[]>([])
  const [languageActivity, setLanguageActivity] = useState<LanguageActivity | null>(null)
  const [mathActivity, setMathActivity] = useState<MathRationalActivity | null>(null)
  const [selectedOption, setSelectedOption] = useState<number | null>(null)
  const [graphZoom, setGraphZoom] = useState<Record<string, boolean>>({})
  const [unit, setUnit] = useState('')
  const [checked, setChecked] = useState(false)
  const [feedback, setFeedback] = useState('')
  const [feedbackCorrect, setFeedbackCorrect] = useState(false)
  const [score, setScore] = useState(0)
  const [subjectFilter, setSubjectFilter] = useState<SubjectFilter>('electrotecnia1')
  const [resultPoints, setResultPoints] = useState(0)
  const [pointsAlreadyAwarded, setPointsAlreadyAwarded] = useState(false)
  const [guestMode, setGuestMode] = useState(false)
  const activeStartedAt = useRef<number | null>(null)
  const activeMilliseconds = useRef(0)
  const [activeSeconds, setActiveSeconds] = useState(0)

  useEffect(() => {
    api.activities().then(setActivities).catch(() => setServerError('No pudimos cargar las actividades reales.'))
  }, [])

  const currentQuestion = questions[step - 1]
  const isLanguageActivity = activity.activityType === 'lengua_sujeto_predicado' || activity.topic === 'Lengua'
  const isMathActivity = activity.activityType === 'matematica_funcion_racional' || activity.topic === 'MatemÃ¡tica'
  const currentLanguageStep = languageActivity?.steps.find((item) => item.key === languageActivity.currentStep)
  const currentMathRoute = mathActivity?.routes.find((route) => route.key === mathActivity.currentTask.routeKey) || mathActivity?.routes[0]
  const totalSteps = Math.max(questions.length, 1)
  const languageTotalSteps = 4
  const canEnterActivity = activity.accessEnabled !== false && activity.state !== 'Proximamente'
  const modeLabel = attempt?.pointsEnabled || activity.pointsEnabled ? 'Con puntos' : 'Practica'

  const getActiveSeconds = () => {
    let milliseconds = activeMilliseconds.current
    if (screen === 'challenge' && activeStartedAt.current !== null) {
      milliseconds += Date.now() - activeStartedAt.current
    }

    return Math.max(0, Math.round(milliseconds / 1000))
  }

  const pauseActiveClock = () => {
    if (activeStartedAt.current === null) return
    activeMilliseconds.current += Date.now() - activeStartedAt.current
    activeStartedAt.current = null
    setActiveSeconds(Math.max(0, Math.round(activeMilliseconds.current / 1000)))
  }

  const resumeActiveClock = () => {
    if (screen !== 'challenge' || activeStartedAt.current !== null) return
    activeStartedAt.current = Date.now()
  }

  useEffect(() => {
    if (screen !== 'challenge' || !attempt) {
      pauseActiveClock()
      return
    }

    resumeActiveClock()
    const update = () => setActiveSeconds(getActiveSeconds())
    const handleVisibility = () => {
      if (document.visibilityState === 'hidden') pauseActiveClock()
      else resumeActiveClock()
      update()
    }

    const timer = window.setInterval(update, 1000)
    document.addEventListener('visibilitychange', handleVisibility)
    window.addEventListener('blur', pauseActiveClock)
    window.addEventListener('focus', resumeActiveClock)

    return () => {
      window.clearInterval(timer)
      document.removeEventListener('visibilitychange', handleVisibility)
      window.removeEventListener('blur', pauseActiveClock)
      window.removeEventListener('focus', resumeActiveClock)
    }
  }, [screen, attempt?.attemptId])

  const reset = () => {
    setScreen('home')
    setStep(1)
    setScore(0)
    setChecked(false)
    setAnswer('')
    setSelectedWords([])
    setLanguageActivity(null)
    setMathActivity(null)
    setSelectedOption(null)
    setGraphZoom({})
    setUnit('')
    setFeedback('')
    setFeedbackCorrect(false)
    setAttempt(null)
    setResultPoints(0)
    setPointsAlreadyAwarded(false)
    setGuestMode(false)
  }

  const choose = (selected: Activity) => {
    setActivity(selected)
    setScreen('access')
    setAccessMessage('')
    setStudentAccessMode('login')
    setAnswer('')
    setSelectedWords([])
    setLanguageActivity(null)
    setMathActivity(null)
    setSelectedOption(null)
    setGraphZoom({})
    setUnit('')
    setFeedback('')
    setFeedbackCorrect(false)
    setChecked(false)
    setStep(1)
  }

  const registerStudent = async () => {
    const cleanDni = studentRegisterForm.dni.replace(/\D/g, '')
    const cleanClave = studentRegisterForm.clave.replace(/\D/g, '')
    if (!studentRegisterForm.nombre.trim() || !studentRegisterForm.apellido.trim() || cleanDni.length < 7 || !studentRegisterForm.codigo.trim()) {
      setAccessMessage('CompletÃ¡ nombre, apellido, DNI y cÃ³digo de clase.')
      return
    }

    setLoading(true)
    setAccessMessage('Enviando inscripciÃ³n...')
    try {
      await api.registerStudentInClass({
        ...studentRegisterForm,
        dni: cleanDni,
        clave: cleanClave,
        codigo: studentRegisterForm.codigo.trim().toUpperCase(),
      })
      setStudentRegisterForm({ nombre: '', apellido: '', dni: '', clave: '', codigo: '' })
      setStudentAccessMode('login')
      setDni(cleanDni)
      setAccessMessage('InscripciÃ³n enviada. EsperÃ¡ la validaciÃ³n de tu profesora para entrar.')
    } catch (error) {
      setAccessMessage(error instanceof Error ? error.message : 'No se pudo enviar la inscripciÃ³n.')
    } finally {
      setLoading(false)
    }
  }

  const validateDni = async () => {
    const cleanDni = dni.replace(/\D/g, '')
    if (cleanDni.length < 7) {
      setAccessMessage('Ingresa un DNI valido de al menos 7 cifras.')
      return
    }

    setLoading(true)
    setAccessMessage('Comprobando DNI...')
    try {
      const result = await api.login(cleanDni)
      const loadedHistory = await api.studentHistory(result.student.id)
      const assignedActivities = await api.activities(result.student.id)
      if (assignedActivities.length > 0) {
        setActivities(assignedActivities)
        const sameActivity = assignedActivities.find((item) => item.id === activity.id)
        if (sameActivity) setActivity(sameActivity)
      }
      setStudent(result.student)
      setGuestMode(false)
      setHistory(loadedHistory)
      setAccessMessage(`Identidad confirmada: ${result.student.name}.`)
      setTimeout(() => setScreen('instructions'), 450)
    } catch (error) {
      setAccessMessage(error instanceof Error ? error.message : 'No se pudo validar el DNI.')
    } finally {
      setLoading(false)
    }
  }

  const enterAsGuest = async () => {
    setLoading(true)
    setAccessMessage('Preparando modo invitado...')
    try {
      const result = await api.guestLogin()
      setStudent(result.student)
      setGuestMode(true)
      setHistory([])
      setAccessMessage('Entraste como invitado. No se guardan puntos reales.')
      setTimeout(() => setScreen('instructions'), 300)
    } catch (error) {
      setAccessMessage(error instanceof Error ? error.message : 'No se pudo iniciar como invitado.')
    } finally {
      setLoading(false)
    }
  }

  const startChallenge = async () => {
    if (!student.id) {
      setScreen('access')
      return
    }
    setLoading(true)
    setServerError('')
    try {
      const attemptRow = await api.startAttempt({ activityId: activity.id, studentId: student.id, guest: guestMode, classActivityId: activity.classActivityId })
      const loadedLanguageActivity = attemptRow.languageActivity || (isLanguageActivity ? await api.languageActivity(activity.id, student.id) : null)
      const loadedMathActivity = attemptRow.mathActivity || (isMathActivity ? await api.mathRationalActivity(activity.id, student.id) : null)
      const questionRows = loadedLanguageActivity || loadedMathActivity ? [] : await api.questions(activity.id, attemptRow.attemptId)
      setQuestions(questionRows)
      setLanguageActivity(loadedLanguageActivity)
      setMathActivity(loadedMathActivity)
      setAttempt(attemptRow)
      setStep(loadedLanguageActivity ? loadedLanguageActivity.currentStepIndex + 1 : loadedMathActivity ? loadedMathActivity.currentTaskIndex + 1 : 1)
      setScore(loadedLanguageActivity ? loadedLanguageActivity.currentStepIndex : loadedMathActivity ? loadedMathActivity.correctCalculations : 0)
      setAnswer('')
      setSelectedWords(loadedLanguageActivity?.steps.find((item) => item.key === loadedLanguageActivity.currentStep)?.selection || [])
      setSelectedOption(null)
      setUnit('')
      setFeedback('')
      setFeedbackCorrect(false)
      setChecked(false)
      activeMilliseconds.current = 0
      activeStartedAt.current = Date.now()
      setActiveSeconds(0)
      setScreen('challenge')
      setResultPoints(0)
      setPointsAlreadyAwarded(false)
    } catch (error) {
      setServerError(error instanceof Error ? error.message : 'No se pudo iniciar la actividad.')
    } finally {
      setLoading(false)
    }
  }

  const validate = async () => {
    if (isMathActivity) {
      if (!attempt || !mathActivity) return
      const task = mathActivity.currentTask
      if (task.type === 'calc' && !answer.trim()) {
        setFeedback('IngresÃ¡ un valor numÃ©rico.')
        setFeedbackCorrect(false)
        return
      }
      if ((task.type === 'choice' || task.type === 'closing') && selectedOption === null) {
        setFeedback('SeleccionÃ¡ una opciÃ³n.')
        setFeedbackCorrect(false)
        return
      }

      setLoading(true)
      try {
        const result = await api.validateMathRational({
          activityId: activity.id,
          studentId: student.id,
          attemptId: attempt.attemptId,
          answer: answer.trim(),
          optionIndex: selectedOption ?? undefined,
          elapsedSeconds: getActiveSeconds(),
        })
        setMathActivity(result)
        setScore(result.correctCalculations)
        setFeedback(result.message || '')
        setFeedbackCorrect(Boolean(result.correct))
        if (result.correct) {
          setAnswer('')
          setSelectedOption(null)
          setStep(Math.min(result.currentTaskIndex + 1, result.totalTasks))
          setChecked(result.completed)
        } else {
          setChecked(false)
        }
      } catch (error) {
        setFeedback(error instanceof Error ? error.message : 'No se pudo verificar la respuesta.')
        setFeedbackCorrect(false)
      } finally {
        setLoading(false)
      }
      return
    }

    if (isLanguageActivity) {
      if (!attempt || !languageActivity || !currentLanguageStep) return
      if (selectedWords.length === 0) {
        setFeedback('Selecciona al menos una palabra para verificar.')
        setFeedbackCorrect(false)
        return
      }

      setLoading(true)
      try {
        const result = await api.validateLanguageStep({
          activityId: activity.id,
          studentId: student.id,
          attemptId: attempt.attemptId,
          step: currentLanguageStep.key,
          selection: selectedWords,
          elapsedSeconds: getActiveSeconds(),
        })
        setLanguageActivity(result)
        setFeedback(result.message || '')
        setFeedbackCorrect(Boolean(result.correct))
        if (result.correct) {
          setScore(result.completed ? languageTotalSteps : Math.max(score + 1, result.currentStepIndex))
          if (result.completed) {
            setChecked(true)
          } else {
            const nextStep = result.steps.find((item) => item.key === result.currentStep)
            setStep(result.currentStepIndex + 1)
            setSelectedWords(nextStep?.selection || [])
            setChecked(false)
          }
        } else {
          setChecked(false)
        }
      } catch (error) {
        setFeedback(error instanceof Error ? error.message : 'No se pudo verificar la respuesta.')
        setFeedbackCorrect(false)
        setChecked(false)
      } finally {
        setLoading(false)
      }
      return
    }

    if (!currentQuestion || !attempt) return
    const numericQuestion = Boolean(currentQuestion.formula)
    if (numericQuestion && !unit) {
      setFeedback('Selecciona la unidad de la respuesta.')
      return
    }
    setLoading(true)
    try {
      let correct = false
      const submittedAnswer = numericQuestion ? `${answer} ${unit}`.trim() : answer
      const result = await api.validateAnswer({ exerciseId: currentQuestion.id, answer: submittedAnswer, attemptId: attempt.attemptId })
      correct = result.correct
      if (!correct && !result.needsReview) {
        setFeedback('Respuesta incorrecta, vuelve a intentarlo.')
        setChecked(false)
        return
      }

      await api.saveProgress({ attemptId: attempt.attemptId, exerciseId: currentQuestion.id, answer: submittedAnswer, correct, numericValue: result.numericValue ?? null, elapsedSeconds: getActiveSeconds() })
      if (correct) setScore((value) => value + 1)
      setFeedback(result.needsReview ? 'Respuesta guardada para revision docente.' : 'Respuesta correcta.')
      setChecked(true)
    } catch (error) {
      setFeedback(error instanceof Error ? error.message : 'No se pudo guardar la respuesta.')
      setChecked(false)
    } finally {
      setLoading(false)
    }
  }

  const next = async () => {
    if (isMathActivity) {
      if (!mathActivity) return
      if (mathActivity.completed) {
        setScreen('result')
      }
      return
    }

    if (isLanguageActivity) {
      if (!languageActivity || !attempt) return
      if (languageActivity.completed) {
        setLoading(true)
        try {
          const saved = await api.saveResult({
            activityId: activity.id,
            studentId: student.id,
            attemptId: attempt.attemptId,
            correct: languageTotalSteps,
            attempts: languageTotalSteps,
            score: !guestMode && attempt.pointsEnabled ? activity.points : 0,
            elapsedSeconds: getActiveSeconds(),
          })
          setResultPoints(Number(saved.points || 0))
          setPointsAlreadyAwarded(Boolean(saved.alreadyAwarded))
          if (!guestMode) setHistory(await api.studentHistory(student.id))
          setScore(languageTotalSteps)
          setScreen('result')
        } catch (error) {
          setServerError(error instanceof Error ? error.message : 'No se pudo finalizar la actividad.')
        } finally {
          setLoading(false)
        }
        return
      }

      setStep(languageActivity.currentStepIndex + 1)
      setChecked(false)
      setSelectedWords(currentLanguageStep?.selection || [])
      setFeedback('')
      setFeedbackCorrect(false)
      return
    }

    if (step >= questions.length) {
      setLoading(true)
      try {
        const saved = await api.saveResult({
          activityId: activity.id,
          studentId: student.id,
          attemptId: attempt?.attemptId,
          correct: score,
          attempts: questions.length,
          score: !guestMode && attempt?.pointsEnabled ? activity.points : 0,
          elapsedSeconds: getActiveSeconds(),
        })
        setResultPoints(Number(saved.points || 0))
        setPointsAlreadyAwarded(Boolean(saved.alreadyAwarded))
        if (!guestMode) setHistory(await api.studentHistory(student.id))
        setScreen('result')
      } catch (error) {
        setServerError(error instanceof Error ? error.message : 'No se pudo finalizar la actividad.')
      } finally {
        setLoading(false)
      }
    } else {
      setStep((value) => value + 1)
      setChecked(false)
      setAnswer('')
      setUnit('')
      setFeedback('')
      setFeedbackCorrect(false)
    }
  }

  const toggleWord = (index: number) => {
    if (checked) return
    setFeedback('')
    setFeedbackCorrect(false)
    setSelectedWords((current) => (
      current.includes(index)
        ? current.filter((item) => item !== index)
        : [...current, index].sort((a, b) => a - b)
    ))
  }

  const chooseOption = (index: number) => {
    setSelectedOption(index)
    setFeedback('')
    setFeedbackCorrect(false)
  }

  const activityHistory = useMemo(() => history.filter((item) => item.activityId === activity.id), [history, activity.id])
  const studentTotalPoints = useMemo(() => history.reduce((sum, item) => sum + Number(item.points || 0), 0), [history])
  const numericQuestion = Boolean(currentQuestion?.formula)
  const unitOptions = currentQuestion?.unitOptions?.length ? currentQuestion.unitOptions : []
  const filteredActivities = useMemo(
    () => {
      if (subjectFilter === 'aconcagua') {
        return activities.filter((item) => item.topic === 'Mision Aconcagua' || item.title.includes('Aconcagua'))
      }

      if (subjectFilter === 'lengua') {
        return activities.filter((item) => item.topic === 'Lengua' || item.activityType === 'lengua_sujeto_predicado')
      }

      if (subjectFilter === 'matematica') {
        return activities.filter((item) => item.topic === 'MatemÃ¡tica' || item.activityType === 'matematica_funcion_racional')
      }

      if (subjectFilter === 'electrotecnia1') {
        return activities.filter((item) => item.topic !== 'Mision Aconcagua' && item.topic !== 'Lengua' && item.topic !== 'MatemÃ¡tica' && !item.title.includes('Aconcagua'))
      }

      return []
    },
    [activities, subjectFilter],
  )
  const nav = <header className="topbar"><Brand onHome={reset}/><nav><button onClick={() => setScreen('activities')}>Actividades</button>{student.id > 0 && <button onClick={() => setScreen('history')}>Mis avances</button>}<button onClick={() => setScreen('admin')}>Panel docente</button></nav><button className="nav-bolt" onClick={() => setScreen('activities')}><Bolt /> Empezar</button></header>

  if (screen === 'admin') return <AdminDashboard nav={nav} />

  if (screen === 'home') return <main className="site-shell home">{nav}<section className="hero"><div className="hero-copy"><p className="eyebrow"><span/> Plataforma escolar</p><h1>Aprende,<br/><em>resolve</em> y gana<br/>puntos.</h1><p className="lead">Desafios cortos, actividades reales y progreso guardado por DNI.</p><div className="hero-actions"><button className="button primary" onClick={() => setScreen('activities')}>Elegir actividad <span>-&gt;</span></button><button className="text-button" onClick={() => setScreen('admin')}>Panel docente</button></div><div className="steps"><div><b>01</b><span>Elegi una<br/>actividad</span></div><i>-</i><div><b>02</b><span>Ingresa<br/>tu DNI</span></div><i>-</i><div><b>03</b><span>Queda<br/>guardado</span></div></div></div><div className="hero-visual"><div className="score-chip"><Bolt/> <strong>DB</strong><span>datos reales</span></div><div className="circuit-board"><div className="board-label">AULA <span>ACTIVIDADES</span></div><Circuit active/><div className="board-readout"><span>PHP + MySQL</span><span>PROGRESO</span></div></div><div className="orbit o1">L</div><div className="orbit o2">V</div><div className="orbit o3">I</div></div></section><div className="ticker"><span>CURSOS</span><span>TP</span><span>LENGUA</span><span>PROGRESO</span></div></main>

  if (screen === 'activities') return <main className="site-shell page">{nav}<section className="page-head"><p className="eyebrow"><span/> Actividades</p><h1>Elegir<br/><em>trabajo</em></h1><p>Las actividades pueden estar en prÃ¡ctica, con puntos o bloqueadas por el profesor.</p><div className="subject-filter"><button className={subjectFilter === 'electrotecnia1' ? 'active' : ''} onClick={() => setSubjectFilter('electrotecnia1')}>Electrotecnia I</button><button className={subjectFilter === 'electrotecnia2' ? 'active' : ''} onClick={() => setSubjectFilter('electrotecnia2')}>Electrotecnia II</button><button className={subjectFilter === 'aconcagua' ? 'active' : ''} onClick={() => setSubjectFilter('aconcagua')}>Mision Aconcagua</button><button className={subjectFilter === 'lengua' ? 'active' : ''} onClick={() => setSubjectFilter('lengua')}>Lengua</button><button className={subjectFilter === 'matematica' ? 'active' : ''} onClick={() => setSubjectFilter('matematica')}>MatemÃ¡tica</button></div></section>{serverError && <p className="server-notice" role="status">{serverError}</p>}{filteredActivities.length === 0 ? <section className="empty-activities"><strong>Por ahora no hay actividades.</strong><p>Cuando el profesor habilite contenido para esta materia va a aparecer acÃ¡.</p></section> : <section className="activity-grid">{filteredActivities.map((item) => { const blocked = item.accessEnabled === false || item.state === 'Proximamente'; return <article className={`activity-card ${blocked ? 'locked' : ''} ${item.topic === 'Lengua' ? 'language-card' : item.topic === 'MatemÃ¡tica' ? 'math-card' : ''}`} key={`${item.id}-${item.classActivityId || 0}`}><div className="activity-art"><span>{item.icon}</span><Circuit active={!blocked}/><small>{statusLabel(item).toUpperCase()}</small></div><div className="activity-body"><div className="card-meta"><span className={!blocked ? 'available' : ''}>{statusLabel(item)}</span><span>{item.level}</span></div><h2>{item.title}</h2><p>{item.className ? `${item.desc} Clase: ${item.className}.` : item.desc}</p><div className="stats"><span>{item.activityType === 'lengua_sujeto_predicado' ? `${item.combinations || item.exercises} oraciones` : item.activityType === 'matematica_funcion_racional' ? `${item.combinations || 64} versiones` : `${item.exercises} ejercicios`}</span><b>{item.pointsEnabled ? `+${item.points} pts` : 'PrÃ¡ctica'}</b></div><button className="button dark" disabled={blocked} onClick={() => choose(item)}>{blocked ? 'No habilitada' : 'Entrar'}</button></div></article> })}</section>}</main>

  if (screen === 'access') return <main className="site-shell page compact">{nav}<section className="access-layout"><div><p className="eyebrow"><span/> Identificacion</p><h1>{studentAccessMode === 'login' ? 'Ingresa' : 'RegistrÃ¡'}<br/><em>{studentAccessMode === 'login' ? 'tu DNI.' : 'tu usuario.'}</em></h1><p className="lead">{studentAccessMode === 'login' ? 'Con el DNI registramos intentos, tiempo, respuestas y puntos cuando la actividad este habilitada.' : 'UsÃ¡ el cÃ³digo que te dio la profesora. La inscripciÃ³n queda pendiente hasta que la valide.'}</p><div className="selected-activity"><span>{activity.icon}</span><div><small>ACTIVIDAD SELECCIONADA</small><strong>{activity.title}</strong><p>{activity.exercises} ejercicios - {activity.pointsEnabled ? `hasta ${activity.points} puntos` : 'modo practica'}</p></div></div></div><form className="access-card" onSubmit={(event) => { event.preventDefault(); studentAccessMode === 'login' ? validateDni() : registerStudent() }}>{studentAccessMode === 'login' ? <><label htmlFor="dni">DNI del alumno</label><input id="dni" value={dni} onChange={(event) => setDni(event.target.value.replace(/[^0-9]/g, ''))} placeholder="Ej. 90000003" inputMode="numeric"/></> : <><label htmlFor="student-name">Nombre</label><input id="student-name" value={studentRegisterForm.nombre} onChange={(event) => setStudentRegisterForm((value) => ({ ...value, nombre: event.target.value }))} placeholder="Nombre"/><label htmlFor="student-last">Apellido</label><input id="student-last" value={studentRegisterForm.apellido} onChange={(event) => setStudentRegisterForm((value) => ({ ...value, apellido: event.target.value }))} placeholder="Apellido"/><label htmlFor="student-dni">DNI</label><input id="student-dni" value={studentRegisterForm.dni} onChange={(event) => setStudentRegisterForm((value) => ({ ...value, dni: event.target.value.replace(/[^0-9]/g, ''), clave: event.target.value.replace(/[^0-9]/g, '') }))} placeholder="DNI" inputMode="numeric"/><label htmlFor="student-pass">ContraseÃ±a inicial</label><input id="student-pass" value={studentRegisterForm.clave} onChange={(event) => setStudentRegisterForm((value) => ({ ...value, clave: event.target.value.replace(/[^0-9]/g, '') }))} placeholder="Debe ser tu DNI" inputMode="numeric"/><label htmlFor="class-code">CÃ³digo de clase</label><input id="class-code" value={studentRegisterForm.codigo} onChange={(event) => setStudentRegisterForm((value) => ({ ...value, codigo: event.target.value.toUpperCase() }))} placeholder="Ej. CL000AB"/></>}<p className={accessMessage.includes('confirmada') || accessMessage.includes('invitado') || accessMessage.includes('enviada') ? 'success-message' : 'error-message'} aria-live="polite">{accessMessage || (studentAccessMode === 'login' ? 'IngresÃ¡ con el DNI validado por tu profesora.' : 'La contraseÃ±a inicial es tu DNI.')}</p><button className="button primary full" type="submit" disabled={loading}>{loading ? 'Procesando...' : studentAccessMode === 'login' ? 'Continuar' : 'Enviar inscripciÃ³n'}</button><button className="text-button full switch-auth" type="button" onClick={() => { setStudentAccessMode(studentAccessMode === 'login' ? 'register' : 'login'); setAccessMessage('') }}>{studentAccessMode === 'login' ? 'Registrarme en una clase' : 'Ya estoy validado'}</button>{studentAccessMode === 'login' && <><button className="button dark full guest-button" type="button" onClick={enterAsGuest} disabled={loading}>Entrar como invitado</button><small className="guest-note">Modo demo: permite resolver sin sumar puntos reales.</small></>}</form></section></main>

  if (screen === 'instructions') return <main className="site-shell page compact">{nav}<section className="instructions"><div className="instruction-head"><p className="eyebrow"><span/> {guestMode ? 'Invitado' : modeLabel}</p><h1>{activity.title}</h1><p>{activity.desc}</p><p>{guestMode ? 'Vas a resolver en modo demo. No suma puntos reales ni historial del alumno.' : 'Vas a resolver la actividad con progreso guardado. Si esta en practica, no suma puntos aunque registra el trabajo.'}</p>{activityHistory.length > 0 && <div className="selected-activity"><span>H</span><div><small>HISTORIAL</small><strong>{activityHistory.length} intento(s)</strong><p>Ultimo estado: {activityHistory[0].state} - respuestas: {activityHistory[0].answers}</p></div></div>}</div><div className="mission-card"><div className="mission-row"><span>T</span><div><small>MODO</small><strong>{guestMode ? 'Invitado' : modeLabel}</strong></div><span>E</span><div><small>EJERCICIOS</small><strong>{activity.exercises}</strong></div></div><div className="points-callout"><Bolt/><div><strong>{guestMode ? 'Modo demo' : activity.pointsEnabled ? `Hasta +${activity.points} puntos` : 'Modo practica'}</strong><span>{guestMode ? 'No suma puntos reales' : activity.pointsEnabled ? 'Suma al finalizar' : 'No suma puntos'}</span></div></div>{serverError && <p className="error-message">{serverError}</p>}<button className="button primary full" onClick={startChallenge} disabled={loading || !canEnterActivity}>{loading ? 'Preparando...' : 'Comenzar actividad'}</button></div></section></main>

  if (screen === 'history') return <main className="site-shell page">{nav}<section className="page-head"><p className="eyebrow"><span/> Alumno</p><h1>Mis<br/><em>avances</em></h1><p>{student.name || 'Ingresa con DNI para ver tu historial.'}</p>{student.id > 0 && <div className="student-points-total"><small>PUNTOS ACUMULADOS</small><b>{studentTotalPoints}</b><span>para sumar al examen</span></div>}</section><section className="history-layout">{history.length === 0 ? <div className="history-empty"><strong>Todavia no hay intentos guardados.</strong><p>Cuando completes o empieces una actividad, va a aparecer aca con tiempo, estado y puntos.</p><button className="button primary" onClick={() => setScreen('activities')}>Ver actividades</button></div> : history.map((item) => <article className="history-card" key={item.attemptId}><div><small>{item.mode === 'evaluativo' ? 'CON PUNTOS' : 'PRACTICA'}</small><h2>{item.activity}</h2><p>{item.lastExercise ? `Ultimo ejercicio: ${item.lastExercise}` : 'Sin respuestas registradas.'}</p></div><div className="history-stats"><span><b>{item.state}</b><small>estado</small></span><span><b>{item.answers}</b><small>respuestas</small></span><span><b>{formatDuration(item.durationSeconds)}</b><small>tiempo</small></span><span><b>{item.points}</b><small>puntos</small></span></div></article>)}</section></main>

  if (screen === 'challenge' && isMathActivity) return <main className="challenge-shell math-shell"><header className="challenge-top"><Brand onHome={reset}/><div className="progress-wrap"><div><span>{mathActivity ? `Paso ${Math.min(mathActivity.currentTaskIndex + 1, mathActivity.totalTasks)} de ${mathActivity.totalTasks}` : 'Cargando'}</span><b>{mathActivity ? Math.round((mathActivity.currentTaskIndex / Math.max(mathActivity.totalTasks, 1)) * 100) : 0}%</b></div><div className="progress"><i style={{ width: `${mathActivity ? (mathActivity.currentTaskIndex / Math.max(mathActivity.totalTasks, 1)) * 100 : 0}%` }}/></div></div><div className="score">M {mathActivity?.correctCalculations || 0}/{mathActivity?.totalCalculations || 20}</div></header><main className="math-activity"><aside className="math-side"><p className="eyebrow"><span/> MatemÃ¡tica</p><small>VERSIÃ“N [{mathActivity?.version.a || '-'}, {mathActivity?.version.b || '-'}]</small><h1>{mathActivity?.title || activity.title}</h1><p>{currentMathRoute?.intro || activity.desc}</p><MathFormulaImage route={currentMathRoute}/><div className="math-route-list">{mathActivity?.routes.map((route) => <span className={route.key === mathActivity.currentTask.routeKey ? 'active' : route.rows.length > 0 ? 'done' : ''} key={route.key}>{route.title}</span>)}</div></aside><section className="math-board">{mathActivity?.completed ? <><div className="math-complete"><small>CIERRE COMPARATIVO</small><h2>Actividad completada</h2><p>Completaste los cuatro recorridos y comparaste los modelos racionales.</p></div><div className="math-mini-grid">{mathActivity.routes.map((route) => <article key={route.key}><strong>{route.title}</strong><MathGraph route={route}/></article>)}</div><div className="math-summary"><span><b>{mathActivity.correctCalculations}</b><small>cÃ¡lculos correctos</small></span><span><b>{mathActivity.attempts}</b><small>intentos realizados</small></span></div><div className="math-conclusions">{mathActivity.conclusions.map((item) => <p key={item}>{item}</p>)}</div><button className="button primary" onClick={() => setScreen('activities')}>Volver a actividades</button></> : <><div className="math-task-head"><small>{mathActivity?.currentTask.routeTitle || 'Recorrido'}</small><h2>{mathActivity?.currentTask.type === 'calc' ? (mathActivity.currentTask.prompt || 'Cargando tarea...') : mathActivity?.currentTask.type === 'closing' ? 'ComparÃ¡ los cuatro grÃ¡ficos.' : 'ObservÃ¡ la tabla y el grÃ¡fico completo.'}</h2>{mathActivity?.currentTask.type === 'calc' && <p className="math-task-help">EscribÃ­ solo el nÃºmero. La unidad ya estÃ¡ indicada junto al campo de respuesta.</p>}{currentMathRoute && <div className="math-params">{currentMathRoute.parameters.map((param) => <span key={param.label}><b>{param.label}</b>{param.value}</span>)}</div>}</div>{mathActivity?.currentTask.type === 'closing' && <div className="math-mini-grid closing-grid">{mathActivity.routes.map((route) => <article key={route.key}><strong>{route.title}</strong><MathGraph route={route}/></article>)}</div>}{currentMathRoute && <div className="math-workspace"><div className="math-table-wrap"><table className="math-table"><thead><tr><th>{currentMathRoute.xLabel}</th><th>{currentMathRoute.yLabel}</th></tr></thead><tbody>{currentMathRoute.rows.length === 0 ? <tr><td colSpan={2}>TodavÃ­a no hay puntos calculados.</td></tr> : currentMathRoute.rows.map((row, index) => <tr key={`${row.x}-${index}`}><td>{Number(row.x).toLocaleString('es-AR', { maximumSignificantDigits: 6 })}</td><td>{Number(row.y).toLocaleString('es-AR', { maximumSignificantDigits: 6 })}</td></tr>)}</tbody></table></div><div className="math-chart"><MathGraph route={currentMathRoute} zoom={Boolean(graphZoom[currentMathRoute.key])}/>{['coulomb', 'campo'].includes(currentMathRoute.key) && currentMathRoute.rows.length > 2 && <div className="chart-actions"><button className="pill" onClick={() => setGraphZoom((value) => ({ ...value, [currentMathRoute.key]: true }))}>Ampliar valores iniciales</button><button className="pill" onClick={() => setGraphZoom((value) => ({ ...value, [currentMathRoute.key]: false }))}>Volver a escala completa</button></div>}</div></div>}{mathActivity?.currentTask.type === 'calc' ? <div className="math-answer"><input className="answer-input" value={answer} onChange={(event) => { setAnswer(event.target.value); setFeedback(''); setFeedbackCorrect(false) }} placeholder="Resultado" inputMode="decimal"/><span>{mathActivity.currentTask.unit}</span></div> : <><div className="math-theory-card"><small>PREGUNTA</small><h2>{mathActivity?.currentTask.prompt || 'ElegÃ­ la interpretaciÃ³n correcta.'}</h2></div><div className="math-options">{mathActivity?.currentTask.options?.map((option, index) => <button className={selectedOption === index ? 'chosen' : ''} onClick={() => chooseOption(index)} key={option}>{option}</button>)}</div></>}{feedback && <div className={`feedback ${feedbackCorrect ? 'correct' : 'wrong'}`}><strong>{feedbackCorrect ? 'Bien.' : 'RevisÃ¡ tu respuesta.'}</strong><p>{feedback}</p></div>}<div className="exercise-actions"><button className="back" onClick={() => setScreen('instructions')}>Volver</button><button className="button primary" onClick={validate} disabled={loading || !mathActivity || (mathActivity.currentTask.type === 'calc' ? !answer.trim() : selectedOption === null)}>{loading ? 'Verificando...' : 'Verificar'}</button></div></>}</section></main></main>

  if (screen === 'challenge' && isLanguageActivity) return <main className="challenge-shell language-shell"><header className="challenge-top"><Brand onHome={reset}/><div className="progress-wrap"><div><span>Paso {languageActivity?.completed ? languageTotalSteps : Math.min(languageActivity?.currentStepIndex ?? 0, languageTotalSteps - 1) + 1} de {languageTotalSteps}</span><b>{Math.round(((languageActivity?.completed ? languageTotalSteps : languageActivity?.currentStepIndex ?? 0) / languageTotalSteps) * 100)}%</b></div><div className="progress"><i style={{ width: `${((languageActivity?.completed ? languageTotalSteps : languageActivity?.currentStepIndex ?? 0) / languageTotalSteps) * 100}%` }}/></div></div><div className="score">L {score}/{languageTotalSteps}</div></header><main className="language-activity"><aside className="language-side"><p className="eyebrow"><span/> {modeLabel}</p><small>ORACIÃ“N #{languageActivity?.sentenceId || '-'}</small><h1>{languageActivity?.title || activity.title}</h1><p>{languageActivity?.intro || activity.desc}</p><div className="formula">{attempt ? `Intento #${attempt.attemptId} / ${formatDuration(activeSeconds)}` : 'Guardando progreso'}</div><div className="language-steps">{languageActivity?.steps.map((item, index) => <span className={`${languageActivity.completed || index < (languageActivity.currentStepIndex || 0) ? 'done' : ''} ${item.key === languageActivity.currentStep ? 'active' : ''}`} key={item.key}>{index + 1}</span>)}</div></aside><section className="language-board">{languageActivity?.completed ? <><div className="language-complete"><small>ACTIVIDAD COMPLETADA</small><h2>Actividad completada</h2><p>Lograste reconocer las partes principales de la oraciÃ³n.</p></div><div className="analysis-sentence">{languageActivity.analysis?.words.map((word, index) => { const answerMap = languageActivity.analysis?.answer || {}; const isSubject = answerMap.sujeto?.includes(index); const isPredicate = answerMap.predicado?.includes(index); const isSubjectCore = answerMap.nucleo_sujeto?.includes(index); const isVerb = answerMap.verbo?.includes(index); return <span className={`${isSubject ? 'subject' : ''} ${isPredicate ? 'predicate' : ''} ${isSubjectCore ? 'subject-core' : ''} ${isVerb ? 'verb-core' : ''}`} key={`${word}-${index}`}>{word}</span> })}<span className="period">.</span></div><div className="legend-row"><span><i className="subject"/>Sujeto</span><span><i className="predicate"/>Predicado</span><span><i className="subject-core"/>NÃºcleo del sujeto</span><span><i className="verb-core"/>Verbo</span></div></> : <><div className="language-prompt"><small>CONSIGNA</small><h2>{currentLanguageStep?.prompt || 'Cargando paso...'}</h2><p>{currentLanguageStep ? `Intentos en este paso: ${currentLanguageStep.attempts}` : ''}</p></div><div className="word-bank" aria-label="Palabras de la oraciÃ³n">{languageActivity?.words.map((word, index) => <button type="button" className={selectedWords.includes(index) ? 'selected' : ''} onClick={() => toggleWord(index)} disabled={checked || loading} key={`${word}-${index}`}>{word}</button>)}<span className="period">.</span></div></>}{feedback && <div className={`feedback ${feedbackCorrect ? 'correct' : 'wrong'}`}><strong>{feedbackCorrect ? 'Bien.' : 'RevisÃ¡ tu selecciÃ³n.'}</strong><p>{feedback}</p></div>}<div className="exercise-actions"><button className="back" onClick={() => setScreen('instructions')}>Volver</button>{languageActivity?.completed ? <button className="button primary" onClick={next} disabled={loading}>{loading ? 'Finalizando...' : 'Finalizar'}</button> : <button className="button primary" disabled={selectedWords.length === 0 || loading || !currentLanguageStep} onClick={validate}>{loading ? 'Verificando...' : 'Verificar'}</button>}</div></section></main></main>

  if (screen === 'challenge') return <main className="challenge-shell"><header className="challenge-top"><Brand onHome={reset}/><div className="progress-wrap"><div><span>Ejercicio {step} de {questions.length}</span><b>{Math.round(step / totalSteps * 100)}%</b></div><div className="progress"><i style={{ width: `${step / totalSteps * 100}%` }}/></div></div><div className="score"><Bolt/> {score}/{questions.length}</div></header><main className="exercise"><aside className="exercise-side"><p className="eyebrow"><span/> {modeLabel}</p><small>ACTIVIDAD {step}</small><h1>{activity.title}</h1><div className="formula">{attempt ? `Intento #${attempt.attemptId} / ${formatDuration(activeSeconds)}` : 'Guardando progreso'}</div></aside><section className="question-area"><div className="prompt-card"><small>CONSIGNA</small><p>{currentQuestion?.prompt || 'Sin ejercicios cargados'}</p></div><div className={`answer-card ${checked ? 'correct' : feedback ? 'wrong' : ''}`}><small>RESULTADO</small>{numericQuestion ? <div className="answer-row"><input className="answer-input" value={answer} onChange={(event) => { setAnswer(event.target.value); setFeedback('') }} disabled={checked} placeholder="Resultado" inputMode="decimal"/><select value={unit} onChange={(event) => { setUnit(event.target.value); setFeedback('') }} disabled={checked}><option value="">Unidad</option>{unitOptions.map((item) => <option value={item} key={item}>{item}</option>)}</select></div> : <textarea className="answer-textarea" value={answer} onChange={(event) => { setAnswer(event.target.value); setFeedback('') }} disabled={checked} placeholder="Escribi tu desarrollo o respuesta..."/>}{currentQuestion?.options.length ? <div className="answers compact-answers">{currentQuestion.options.map((option) => <button className={answer === option ? 'chosen' : ''} onClick={() => setAnswer(option)} disabled={checked} key={option}>{option}</button>)}</div> : null}</div>{feedback && <div className={`feedback ${checked ? 'correct' : 'wrong'}`}><strong>{checked ? 'Respuesta guardada.' : 'Respuesta incorrecta.'}</strong><p>{feedback}</p></div>}<div className="exercise-actions"><button className="back" onClick={() => step > 1 && setStep(step - 1)} disabled={step <= 1}>Anterior</button>{!checked ? <button className="button primary" disabled={!answer.trim() || loading || !currentQuestion || (numericQuestion && !unit)} onClick={validate}>{loading ? 'Validando...' : 'Comprobar'}</button> : <button className="button primary" onClick={next} disabled={loading}>{step === questions.length ? 'Finalizar' : 'Siguiente'}</button>}</div></section></main></main>

  if (screen === 'result') return <main className="site-shell page compact">{nav}<section className="result"><div className="result-burst"><Bolt/></div><p className="eyebrow"><span/> Actividad completada</p><h1>Listo,<br/><em>{student.name.split(' ')[0] || 'alumno'}</em></h1><p className="lead">Terminaste <strong>{activity.title}</strong>. El intento quedo registrado en la base.</p><div className="reward"><small>{attempt?.pointsEnabled ? 'PUNTAJE' : 'PRACTICA'}</small><strong>{resultPoints} <span>pts</span></strong><p>{attempt?.pointsEnabled ? (pointsAlreadyAwarded ? 'ya habias sumado esta actividad' : 'sumados al historial') : 'sin sumar puntos'}</p></div><div className="result-stats"><div><b>{isMathActivity ? (mathActivity?.correctCalculations || score) : score}/{isMathActivity ? (mathActivity?.totalCalculations || 20) : isLanguageActivity ? languageTotalSteps : questions.length}</b><span>respuestas guardadas</span></div><div><b>{attempt?.attemptId || '-'}</b><span>intento</span></div><div><b>{history.length}</b><span>historial</span></div></div><div className="result-actions"><button className="button dark" onClick={() => setScreen('activities')}>Volver a actividades</button><button className="button primary" onClick={() => setScreen('history')}>Ver mis avances</button></div></section></main>

  return null
}



