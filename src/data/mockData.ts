export type Activity = { id: number; title: string; desc: string; level: string; points: number; exercises: number; combinations?: number; state: string; icon: string; topic?: string; visible?: boolean; accessEnabled?: boolean; pointsEnabled?: boolean; activityType?: string; classActivityId?: number | null; classId?: number | null; className?: string | null; classCode?: string | null }
export type Question = { id: number; prompt: string; explanation: string; options: string[]; correctAnswer: string; formula?: string; tolerance?: number | null; unitOptions?: string[] }

/** Datos de demostración: reemplazables por las respuestas de /api/*.php */
export const mockActivities: Activity[] = [
  { id: 1, title: 'Circuitos en serie', desc: 'Tensión, corriente y resistencia en acción.', level: 'Inicial', points: 10, exercises: 10, state: 'Disponible', icon: '⌁' },
  { id: 2, title: 'Ley de Ohm', desc: 'Resolvé cálculos para encender el tablero.', level: 'Intermedio', points: 10, exercises: 12, state: 'Disponible', icon: 'Ω' },
  { id: 3, title: 'Mediciones reales', desc: 'Lecturas de multímetro y diagnóstico.', level: 'Avanzado', points: 15, exercises: 8, state: 'Próximamente', icon: '⌁' },
]

export const mockQuestions: Question[] = Array.from({ length: 10 }, (_, index) => ({
  id: index + 1,
  prompt: '¿Cuál es la resistencia equivalente del circuito?',
  explanation: 'En serie, la corriente atraviesa una resistencia y después la otra: 6 Ω + 6 Ω = 12 Ω.',
  options: ['6 Ω', '12 Ω', '18 Ω', '36 Ω'],
  correctAnswer: '12 Ω',
}))

export const mockAdminOverview = { activeActivities: 4, participants: 86, awardedPoints: 420, rows: [['Circuitos en serie', 'Activa', '32', '78%'], ['Ley de Ohm', 'Activa', '28', '71%'], ['Mediciones reales', 'Programada', '0', '—']] }
