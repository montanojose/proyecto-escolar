# Carga de bancos de valores por seccion

El sistema queda preparado para recibir valores por seccion. La tabla global conserva magnitudes y unidades, pero los valores concretos se cargan por seccion del TP.

## Formato recomendado para pasar datos

```text
TP: Trabajo Practico N 5 - Ley de Ohm
Seccion: Seccion 1 - Corriente

Banco V:
Unidad: V
Valores: 5, 9, 12, 15, 24

Banco R:
Unidad: ohm
Valores: 10, 47, 100, 220, 470

Ejercicio 1:
Consigna: Observe un circuito simple con tension {V} y resistencia {R}. Determine la corriente.
Formula: V / R
Tolerancia: 0.05
Variables:
V usa banco V
R usa banco R
```

## Como se generan combinaciones

Si el banco V tiene 3 valores y el banco R tiene 4 valores, el sistema genera:

```text
1_1, 1_2, 1_3, 1_4
2_1, 2_2, 2_3, 2_4
3_1, 3_2, 3_3, 3_4
```

Cada combinacion queda guardada con sus valores y respuesta esperada. El sistema asigna primero las combinaciones menos usadas. Cuando todas fueron usadas una vez, recien empieza una segunda vuelta.

## Reglas

- Los valores no se inventan: salen del banco de la seccion.
- Cada ejercicio define que bancos usa.
- La respuesta se calcula desde la formula del ejercicio.
- La tolerancia recomendada para ejercicios numericos es `0.05`, equivalente al 5%.
- Para respuestas abiertas o dibujos, dejar `Formula` vacia y se corrige desde el panel docente.
