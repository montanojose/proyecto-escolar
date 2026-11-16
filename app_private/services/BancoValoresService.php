<?php

declare(strict_types=1);

require_once dirname(__DIR__) . '/config/database.php';

final class BancoValoresService
{
    private const MAX_COMBINACIONES_POR_EJERCICIO = 64;

    public function asignarCombinacion(int $alumnoId, int $ejercicioId, int $intentoId): ?int
    {
        $existente = $this->buscarAsignacion($intentoId, $ejercicioId);
        if ($existente !== null) {
            return $existente;
        }

        $this->generarCombinacionesEjercicio($ejercicioId);

        $pdo = db();
        $stmt = $pdo->prepare(
            'SELECT id
             FROM combinaciones_ejercicio
             WHERE ejercicio_id = ? AND activa = 1
             ORDER BY
               CASE
                 WHEN codigo_combinacion IS NOT NULL
                  AND codigo_combinacion NOT IN (
                    SELECT ce2.codigo_combinacion
                    FROM asignaciones_combinacion ac2
                    INNER JOIN combinaciones_ejercicio ce2 ON ce2.id = ac2.combinacion_ejercicio_id
                    WHERE ac2.intento_id = ? AND ce2.codigo_combinacion IS NOT NULL
                 )
                 THEN 0 ELSE 10
               END,
               CASE
                 WHEN codigo_combinacion IS NOT NULL
                  AND SUBSTRING_INDEX(codigo_combinacion, "_", 1) NOT IN (
                    SELECT SUBSTRING_INDEX(ce2.codigo_combinacion, "_", 1)
                    FROM asignaciones_combinacion ac2
                    INNER JOIN combinaciones_ejercicio ce2 ON ce2.id = ac2.combinacion_ejercicio_id
                    WHERE ac2.intento_id = ? AND ce2.codigo_combinacion IS NOT NULL
                  )
                 THEN 0 ELSE 1
               END,
               CASE
                 WHEN codigo_combinacion IS NOT NULL
                  AND SUBSTRING_INDEX(codigo_combinacion, "_", -1) NOT IN (
                    SELECT SUBSTRING_INDEX(ce2.codigo_combinacion, "_", -1)
                    FROM asignaciones_combinacion ac2
                    INNER JOIN combinaciones_ejercicio ce2 ON ce2.id = ac2.combinacion_ejercicio_id
                    WHERE ac2.intento_id = ? AND ce2.codigo_combinacion IS NOT NULL
                  )
                 THEN 0 ELSE 1
               END,
               usos ASC,
               id ASC
             LIMIT 1'
        );
        $stmt->execute([$ejercicioId, $intentoId, $intentoId, $intentoId]);
        $combinacionId = $stmt->fetchColumn();

        if (!$combinacionId) {
            return null;
        }

        $stmt = $pdo->prepare(
            'INSERT INTO asignaciones_combinacion (alumno_id, ejercicio_id, combinacion_ejercicio_id, intento_id)
             VALUES (?, ?, ?, ?)'
        );
        $stmt->execute([$alumnoId, $ejercicioId, (int) $combinacionId, $intentoId]);

        $stmt = $pdo->prepare('UPDATE combinaciones_ejercicio SET usos = usos + 1 WHERE id = ?');
        $stmt->execute([(int) $combinacionId]);

        return (int) $combinacionId;
    }

    public function generarCombinacionesEjercicio(int $ejercicioId): int
    {
        $activas = $this->contarCombinacionesActivas($ejercicioId);
        if ($activas > 0) {
            if ($activas > self::MAX_COMBINACIONES_POR_EJERCICIO) {
                $this->limitarCombinacionesActivas($ejercicioId);
            }

            return 0;
        }

        $ejercicio = $this->obtenerEjercicio($ejercicioId);
        if (!$ejercicio || trim((string) $ejercicio['formula_respuesta']) === '') {
            return 0;
        }

        $variables = $this->variablesConBanco($ejercicioId);
        if (!$variables) {
            return 0;
        }

        foreach ($variables as $variable) {
            if (!$variable['valores']) {
                return 0;
            }
        }

        $combinaciones = $this->combinacionesLimitadas($variables);
        $generadas = 0;

        foreach ($combinaciones as $combinacion) {
            $codigo = implode('_', array_map(fn (array $item): string => (string) $item['indice'], $combinacion));
            $base = [];

            foreach ($combinacion as $item) {
                $valorBase = (float) $item['valor'] * (float) $item['factor_base'];
                $base[strtoupper((string) $item['nombre'])] = $valorBase;
                $base[$this->nombreBase((string) $item['nombre'])] = $valorBase;
            }

            $respuesta = $this->calcularRespuesta((string) $ejercicio['formula_respuesta'], $base);
            if ($respuesta === null) {
                continue;
            }

            $hash = hash('sha256', $ejercicioId . ':' . $codigo);
            $respuestaTexto = $this->formatearRespuesta($respuesta, (string) $ejercicio['formula_respuesta']);
            $combinacionId = $this->guardarCombinacion($ejercicioId, $codigo, $hash, $respuesta, $respuestaTexto);

            foreach ($combinacion as $item) {
                $valorVariableId = $this->guardarValorVariable((int) $item['variable_id'], (float) $item['valor'], (int) $item['indice']);
                $this->guardarValorCombinacion($combinacionId, (int) $item['variable_id'], $valorVariableId, (float) $item['valor']);
            }

            $generadas++;
        }

        return $generadas;
    }

    private function buscarAsignacion(int $intentoId, int $ejercicioId): ?int
    {
        $stmt = db()->prepare(
            'SELECT ac.combinacion_ejercicio_id
             FROM asignaciones_combinacion ac
             INNER JOIN combinaciones_ejercicio ce ON ce.id = ac.combinacion_ejercicio_id
             WHERE ac.intento_id = ? AND ac.ejercicio_id = ? AND ce.activa = 1
             LIMIT 1'
        );
        $stmt->execute([$intentoId, $ejercicioId]);
        $id = $stmt->fetchColumn();

        return $id ? (int) $id : null;
    }

    private function obtenerEjercicio(int $ejercicioId): ?array
    {
        $stmt = db()->prepare('SELECT id, formula_respuesta FROM ejercicios WHERE id = ? AND activo = 1 LIMIT 1');
        $stmt->execute([$ejercicioId]);
        $ejercicio = $stmt->fetch();

        return $ejercicio ?: null;
    }

    private function variablesConBanco(int $ejercicioId): array
    {
        $stmt = db()->prepare(
            'SELECT ve.id, ve.nombre, ve.banco_valores_seccion_id, u.factor_base
             FROM variables_ejercicio ve
             INNER JOIN unidades u ON u.id = ve.unidad_id
             WHERE ve.ejercicio_id = ? AND ve.banco_valores_seccion_id IS NOT NULL
             ORDER BY ve.orden, ve.id'
        );
        $stmt->execute([$ejercicioId]);
        $variables = $stmt->fetchAll();

        foreach ($variables as &$variable) {
            $variable['valores'] = $this->valoresBanco((int) $variable['banco_valores_seccion_id']);
        }

        return $variables;
    }

    private function valoresBanco(int $bancoId): array
    {
        $stmt = db()->prepare(
            'SELECT indice, valor
             FROM valores_banco_seccion
             WHERE banco_valores_seccion_id = ? AND activo = 1
             ORDER BY indice'
        );
        $stmt->execute([$bancoId]);

        return $stmt->fetchAll();
    }

    private function combinacionesLimitadas(array $variables): array
    {
        $especial = $this->combinacionesEspeciales($variables);
        if ($especial !== null) {
            return $especial;
        }

        if (count($variables) <= 2) {
            return $this->productoCartesianoLimitado($variables, self::MAX_COMBINACIONES_POR_EJERCICIO);
        }

        $primera = $variables[0];
        $segunda = $variables[1];
        $resultado = [];

        foreach ($primera['valores'] as $valorA) {
            foreach ($segunda['valores'] as $valorB) {
                $indiceB = (int) $valorB['indice'];
                $actual = [
                    $this->mapearValorCombinacion($primera, $valorA),
                    $this->mapearValorCombinacion($segunda, $valorB),
                ];

                for ($i = 2; $i < count($variables); $i++) {
                    $valorMismoIndice = $this->buscarValorPorIndice($variables[$i], $indiceB);
                    if ($valorMismoIndice === null) {
                        continue 2;
                    }

                    $actual[] = $this->mapearValorCombinacion($variables[$i], $valorMismoIndice);
                }

                $resultado[] = $actual;
                if (count($resultado) >= self::MAX_COMBINACIONES_POR_EJERCICIO) {
                    return $resultado;
                }
            }
        }

        return $resultado;
    }

    private function combinacionesEspeciales(array $variables): ?array
    {
        $nombres = array_map(fn (array $variable): string => strtoupper((string) $variable['nombre']), $variables);
        if (!in_array('LARGO', $nombres, true) || !in_array('ANCHO', $nombres, true) || !in_array('CANTIDAD_CARPAS', $nombres, true)) {
            return null;
        }

        $porNombre = [];
        foreach ($variables as $variable) {
            $porNombre[strtoupper((string) $variable['nombre'])] = $variable;
        }

        foreach (['LARGO', 'ANCHO', 'CANTIDAD_CARPAS', 'LARGO_CARPA', 'ANCHO_CARPA'] as $requerida) {
            if (!isset($porNombre[$requerida])) {
                return null;
            }
        }

        $resultado = [];
        foreach ($porNombre['LARGO']['valores'] as $valorLargo) {
            $indiceA = (int) $valorLargo['indice'];
            $valorAncho = $this->buscarValorPorIndice($porNombre['ANCHO'], $indiceA);
            if ($valorAncho === null) {
                continue;
            }

            foreach ($porNombre['CANTIDAD_CARPAS']['valores'] as $valorCarpas) {
                $indiceB = (int) $valorCarpas['indice'];
                $valorLargoCarpa = $this->buscarValorPorIndice($porNombre['LARGO_CARPA'], $indiceB);
                $valorAnchoCarpa = $this->buscarValorPorIndice($porNombre['ANCHO_CARPA'], $indiceB);
                if ($valorLargoCarpa === null || $valorAnchoCarpa === null) {
                    continue;
                }

                $resultado[] = [
                    $this->mapearValorCombinacion($porNombre['LARGO'], $valorLargo),
                    $this->mapearValorCombinacion($porNombre['ANCHO'], $valorAncho),
                    $this->mapearValorCombinacion($porNombre['CANTIDAD_CARPAS'], $valorCarpas),
                    $this->mapearValorCombinacion($porNombre['LARGO_CARPA'], $valorLargoCarpa),
                    $this->mapearValorCombinacion($porNombre['ANCHO_CARPA'], $valorAnchoCarpa),
                ];

                if (count($resultado) >= self::MAX_COMBINACIONES_POR_EJERCICIO) {
                    return $resultado;
                }
            }
        }

        return $resultado;
    }

    private function productoCartesianoLimitado(array $variables, int $limite, int $posicion = 0, array $actual = []): array
    {
        if ($posicion >= count($variables)) {
            return [$actual];
        }

        $resultado = [];
        $variable = $variables[$posicion];

        foreach ($variable['valores'] as $valor) {
            $resultado = array_merge($resultado, $this->productoCartesianoLimitado($variables, $limite, $posicion + 1, [
                ...$actual,
                $this->mapearValorCombinacion($variable, $valor),
            ]));

            if (count($resultado) >= $limite) {
                return array_slice($resultado, 0, $limite);
            }
        }

        return $resultado;
    }

    private function mapearValorCombinacion(array $variable, array $valor): array
    {
        return [
            'variable_id' => (int) $variable['id'],
            'nombre' => (string) $variable['nombre'],
            'factor_base' => (float) $variable['factor_base'],
            'indice' => (int) $valor['indice'],
            'valor' => (float) $valor['valor'],
        ];
    }

    private function buscarValorPorIndice(array $variable, int $indice): ?array
    {
        foreach ($variable['valores'] as $valor) {
            if ((int) $valor['indice'] === $indice) {
                return $valor;
            }
        }

        return null;
    }

    private function contarCombinacionesActivas(int $ejercicioId): int
    {
        $stmt = db()->prepare('SELECT COUNT(*) FROM combinaciones_ejercicio WHERE ejercicio_id = ? AND activa = 1');
        $stmt->execute([$ejercicioId]);

        return (int) $stmt->fetchColumn();
    }

    private function limitarCombinacionesActivas(int $ejercicioId): void
    {
        $stmt = db()->prepare(
            'SELECT id
             FROM combinaciones_ejercicio
             WHERE ejercicio_id = ? AND activa = 1
             ORDER BY id
             LIMIT 18446744073709551615 OFFSET ' . self::MAX_COMBINACIONES_POR_EJERCICIO
        );
        $stmt->execute([$ejercicioId]);
        $ids = array_map('intval', $stmt->fetchAll(PDO::FETCH_COLUMN));

        if (!$ids) {
            return;
        }

        $placeholders = implode(',', array_fill(0, count($ids), '?'));
        $stmt = db()->prepare("UPDATE combinaciones_ejercicio SET activa = 0 WHERE id IN ({$placeholders})");
        $stmt->execute($ids);
    }

    private function calcularRespuesta(string $formula, array $valores): ?float
    {
        $formula = strtoupper((string) preg_replace('/\s+/', '', $formula));

        return match ($formula) {
            'V*I', 'I*V' => isset($valores['V'], $valores['I']) ? (float) $valores['V'] * (float) $valores['I'] : null,
            'V/R' => isset($valores['V'], $valores['R']) && (float) $valores['R'] !== 0.0 ? (float) $valores['V'] / (float) $valores['R'] : null,
            'V/I' => isset($valores['V'], $valores['I']) && (float) $valores['I'] !== 0.0 ? (float) $valores['V'] / (float) $valores['I'] : null,
            'I*R', 'R*I' => isset($valores['I'], $valores['R']) ? (float) $valores['I'] * (float) $valores['R'] : null,
            'I*I*R', 'R*I*I' => isset($valores['I'], $valores['R']) ? (float) $valores['I'] * (float) $valores['I'] * (float) $valores['R'] : null,
            'V*V/R' => isset($valores['V'], $valores['R']) && (float) $valores['R'] !== 0.0 ? ((float) $valores['V'] * (float) $valores['V']) / (float) $valores['R'] : null,
            'P/I' => isset($valores['P'], $valores['I']) && (float) $valores['I'] !== 0.0 ? (float) $valores['P'] / (float) $valores['I'] : null,
            'P/V' => isset($valores['P'], $valores['V']) && (float) $valores['V'] !== 0.0 ? (float) $valores['P'] / (float) $valores['V'] : null,
            'N*P', 'P*N' => isset($valores['N'], $valores['P']) ? (float) $valores['N'] * (float) $valores['P'] : null,
            'E/T' => isset($valores['E'], $valores['T']) && (float) $valores['T'] !== 0.0 ? (float) $valores['E'] / (float) $valores['T'] : null,
            'P*T', 'T*P' => isset($valores['P'], $valores['T']) ? (float) $valores['P'] * (float) $valores['T'] : null,
            'P*D*24*3600' => isset($valores['P'], $valores['D']) ? (float) $valores['P'] * (float) $valores['D'] * 24 * 3600 : null,
            'E/D' => isset($valores['E'], $valores['D']) && (float) $valores['D'] !== 0.0 ? (float) $valores['E'] / (float) $valores['D'] : null,
            'P*H*30*238/1000' => isset($valores['P'], $valores['H']) ? ((float) $valores['P'] / 1000) * (float) $valores['H'] * 30 * 238 : null,
            'T_INICIAL-DESCENSO_T' => isset($valores['T_INICIAL'], $valores['DESCENSO_T']) ? (float) $valores['T_INICIAL'] - (float) $valores['DESCENSO_T'] : null,
            'T_INICIAL+AUMENTO_T' => isset($valores['T_INICIAL'], $valores['AUMENTO_T']) ? (float) $valores['T_INICIAL'] + (float) $valores['AUMENTO_T'] : null,
            'T_MAX-T_MIN' => isset($valores['T_MAX'], $valores['T_MIN']) ? (float) $valores['T_MAX'] - (float) $valores['T_MIN'] : null,
            'ALTITUD_INICIAL+ASCENSO' => isset($valores['ALTITUD_INICIAL'], $valores['ASCENSO']) ? (float) $valores['ALTITUD_INICIAL'] + (float) $valores['ASCENSO'] : null,
            'ALTITUD_INICIAL-DESCENSO_ALT' => isset($valores['ALTITUD_INICIAL'], $valores['DESCENSO_ALT']) ? (float) $valores['ALTITUD_INICIAL'] - (float) $valores['DESCENSO_ALT'] : null,
            'ALTITUD_INICIAL+ASCENSO-DESCENSO_ALT' => isset($valores['ALTITUD_INICIAL'], $valores['ASCENSO'], $valores['DESCENSO_ALT']) ? (float) $valores['ALTITUD_INICIAL'] + (float) $valores['ASCENSO'] - (float) $valores['DESCENSO_ALT'] : null,
            'T_FINAL+DESCENSO_T' => isset($valores['T_FINAL'], $valores['DESCENSO_T']) ? (float) $valores['T_FINAL'] + (float) $valores['DESCENSO_T'] : null,
            'T_INICIAL-DESCENSO_T+AUMENTO_T-DESCENSO_FINAL' => isset($valores['T_INICIAL'], $valores['DESCENSO_T'], $valores['AUMENTO_T'], $valores['DESCENSO_FINAL']) ? (float) $valores['T_INICIAL'] - (float) $valores['DESCENSO_T'] + (float) $valores['AUMENTO_T'] - (float) $valores['DESCENSO_FINAL'] : null,
            'TOTAL_RACIONES*FRACCION_EXACTA' => isset($valores['TOTAL_RACIONES'], $valores['FRACCION']) ? (float) $valores['TOTAL_RACIONES'] * $this->fraccionBancoA((int) $valores['FRACCION']) : null,
            'TOTAL_RACIONES-(TOTAL_RACIONES*FRACCION_EXACTA)' => isset($valores['TOTAL_RACIONES'], $valores['FRACCION']) ? (float) $valores['TOTAL_RACIONES'] - ((float) $valores['TOTAL_RACIONES'] * $this->fraccionBancoA((int) $valores['FRACCION'])) : null,
            'TOTAL_RACIONES*NUMERADOR/DENOMINADOR' => isset($valores['TOTAL_RACIONES'], $valores['NUMERADOR'], $valores['DENOMINADOR']) && (float) $valores['DENOMINADOR'] !== 0.0 ? (float) $valores['TOTAL_RACIONES'] * (float) $valores['NUMERADOR'] / (float) $valores['DENOMINADOR'] : null,
            'TOTAL_RACIONES-(TOTAL_RACIONES*NUMERADOR/DENOMINADOR)' => isset($valores['TOTAL_RACIONES'], $valores['NUMERADOR'], $valores['DENOMINADOR']) && (float) $valores['DENOMINADOR'] !== 0.0 ? (float) $valores['TOTAL_RACIONES'] - ((float) $valores['TOTAL_RACIONES'] * (float) $valores['NUMERADOR'] / (float) $valores['DENOMINADOR']) : null,
            'TOTAL_RACIONES*FRACCION' => isset($valores['TOTAL_RACIONES'], $valores['FRACCION']) ? (float) $valores['TOTAL_RACIONES'] * (float) $valores['FRACCION'] : null,
            'TOTAL_RACIONES-(TOTAL_RACIONES*FRACCION)' => isset($valores['TOTAL_RACIONES'], $valores['FRACCION']) ? (float) $valores['TOTAL_RACIONES'] - ((float) $valores['TOTAL_RACIONES'] * (float) $valores['FRACCION']) : null,
            'KM_RECORRIDOS/KM_TOTAL' => isset($valores['KM_RECORRIDOS'], $valores['KM_TOTAL']) && (float) $valores['KM_TOTAL'] !== 0.0 ? (float) $valores['KM_RECORRIDOS'] / (float) $valores['KM_TOTAL'] : null,
            'ALIMENTO_G/PERSONAS_REPARTO' => isset($valores['ALIMENTO_G'], $valores['PERSONAS_REPARTO']) && (float) $valores['PERSONAS_REPARTO'] !== 0.0 ? (float) $valores['ALIMENTO_G'] / (float) $valores['PERSONAS_REPARTO'] : null,
            'RACION_G*PERSONAS' => isset($valores['RACION_G'], $valores['PERSONAS']) ? (float) $valores['RACION_G'] * (float) $valores['PERSONAS'] : null,
            'CEIL(ELEMENTOS/CAPACIDAD_CAJA)' => isset($valores['ELEMENTOS'], $valores['CAPACIDAD_CAJA']) && (float) $valores['CAPACIDAD_CAJA'] !== 0.0 ? ceil((float) $valores['ELEMENTOS'] / (float) $valores['CAPACIDAD_CAJA']) : null,
            '(KM_RECORRIDOS/KM_TOTAL)*100' => isset($valores['KM_RECORRIDOS'], $valores['KM_TOTAL']) && (float) $valores['KM_TOTAL'] !== 0.0 ? ((float) $valores['KM_RECORRIDOS'] / (float) $valores['KM_TOTAL']) * 100 : null,
            'TOTAL_ALIMENTO_KG*(1-FRACCION_ETAPA_1_EXACTA-FRACCION_ETAPA_2_EXACTA)' => isset($valores['TOTAL_ALIMENTO_KG'], $valores['FRACCION_ETAPA_1'], $valores['FRACCION_ETAPA_2']) ? (float) $valores['TOTAL_ALIMENTO_KG'] * (1 - $this->fraccionEtapa1((int) $valores['FRACCION_ETAPA_1']) - $this->fraccionEtapa2((int) $valores['FRACCION_ETAPA_2'])) : null,
            'TOTAL_ALIMENTO_KG*(1-NUM_ETAPA_1/DEN_ETAPA_1-NUM_ETAPA_2/DEN_ETAPA_2)' => isset($valores['TOTAL_ALIMENTO_KG'], $valores['NUM_ETAPA_1'], $valores['DEN_ETAPA_1'], $valores['NUM_ETAPA_2'], $valores['DEN_ETAPA_2']) && (float) $valores['DEN_ETAPA_1'] !== 0.0 && (float) $valores['DEN_ETAPA_2'] !== 0.0 ? (float) $valores['TOTAL_ALIMENTO_KG'] * (1 - ((float) $valores['NUM_ETAPA_1'] / (float) $valores['DEN_ETAPA_1']) - ((float) $valores['NUM_ETAPA_2'] / (float) $valores['DEN_ETAPA_2'])) : null,
            'TOTAL_ALIMENTO_KG*(1-FRACCION_ETAPA_1-FRACCION_ETAPA_2)' => isset($valores['TOTAL_ALIMENTO_KG'], $valores['FRACCION_ETAPA_1'], $valores['FRACCION_ETAPA_2']) ? (float) $valores['TOTAL_ALIMENTO_KG'] * (1 - (float) $valores['FRACCION_ETAPA_1'] - (float) $valores['FRACCION_ETAPA_2']) : null,
            'COSTO_FIJO+COSTO_PERSONA*PERSONAS' => isset($valores['COSTO_FIJO'], $valores['COSTO_PERSONA'], $valores['PERSONAS']) ? (float) $valores['COSTO_FIJO'] + (float) $valores['COSTO_PERSONA'] * (float) $valores['PERSONAS'] : null,
            'ESTACAS_CARPA*CANTIDAD_CARPAS+ESTACAS_RESERVA' => isset($valores['ESTACAS_CARPA'], $valores['CANTIDAD_CARPAS'], $valores['ESTACAS_RESERVA']) ? (float) $valores['ESTACAS_CARPA'] * (float) $valores['CANTIDAD_CARPAS'] + (float) $valores['ESTACAS_RESERVA'] : null,
            '(COSTO_TOTAL-COSTO_FIJO)/COSTO_PERSONA' => isset($valores['COSTO_FIJO'], $valores['COSTO_PERSONA'], $valores['PERSONAS']) && (float) $valores['COSTO_PERSONA'] !== 0.0 ? (float) $valores['PERSONAS'] : null,
            '2*(LARGO+ANCHO)' => isset($valores['LARGO'], $valores['ANCHO']) ? 2 * ((float) $valores['LARGO'] + (float) $valores['ANCHO']) : null,
            'LARGO*ANCHO' => isset($valores['LARGO'], $valores['ANCHO']) ? (float) $valores['LARGO'] * (float) $valores['ANCHO'] : null,
            'PERIMETRO/2-LARGO' => isset($valores['LARGO'], $valores['ANCHO']) ? (float) $valores['ANCHO'] : null,
            'HIPOTENUSA_BASE*FACTOR' => isset($valores['HIPOTENUSA_BASE'], $valores['FACTOR']) ? (float) $valores['HIPOTENUSA_BASE'] * (float) $valores['FACTOR'] : null,
            'LARGO*ANCHO-CANTIDAD_CARPAS*LARGO_CARPA*ANCHO_CARPA' => isset($valores['LARGO'], $valores['ANCHO'], $valores['CANTIDAD_CARPAS'], $valores['LARGO_CARPA'], $valores['ANCHO_CARPA']) ? (float) $valores['LARGO'] * (float) $valores['ANCHO'] - $this->cantidadCarpasSuperficie((int) $valores['CANTIDAD_CARPAS']) * $this->largoCarpa((int) $valores['LARGO_CARPA']) * $this->anchoCarpa((int) $valores['ANCHO_CARPA']) : null,
            default => null,
        };
    }

    private function nombreBase(string $nombre): string
    {
        $nombre = strtoupper($nombre);

        if (str_starts_with($nombre, 'R')) {
            return 'R';
        }

        if (str_starts_with($nombre, 'I')) {
            return 'I';
        }

        if (str_starts_with($nombre, 'V')) {
            return 'V';
        }

        if ($nombre === 'N') {
            return 'N';
        }

        if (str_starts_with($nombre, 'P')) {
            return 'P';
        }

        if (str_starts_with($nombre, 'E')) {
            return 'E';
        }

        if (str_starts_with($nombre, 'T')) {
            return 'T';
        }

        if (str_starts_with($nombre, 'D')) {
            return 'D';
        }

        if (str_starts_with($nombre, 'H')) {
            return 'H';
        }

        return $nombre;
    }

    private function fraccionBancoA(int $indice): float
    {
        return match ($indice) {
            1 => 1 / 2,
            2 => 1 / 3,
            3 => 1 / 4,
            4 => 2 / 3,
            5 => 3 / 4,
            6 => 1 / 5,
            7 => 2 / 5,
            8 => 3 / 5,
            default => 0.0,
        };
    }

    private function fraccionEtapa1(int $indice): float
    {
        return match ($indice) {
            1 => 1 / 20,
            2 => 1 / 10,
            3 => 3 / 20,
            4 => 1 / 5,
            5 => 1 / 4,
            6 => 3 / 10,
            7 => 7 / 20,
            8 => 2 / 5,
            default => 0.0,
        };
    }

    private function fraccionEtapa2(int $indice): float
    {
        return match ($indice) {
            1 => 1 / 10,
            2 => 3 / 20,
            3 => 1 / 5,
            4 => 1 / 4,
            5 => 1 / 10,
            6 => 3 / 20,
            7 => 1 / 5,
            8 => 1 / 4,
            default => 0.0,
        };
    }

    private function cantidadCarpasSuperficie(int $indice): float
    {
        return match ($indice) {
            1 => 2,
            2 => 3,
            3 => 4,
            4 => 4,
            5 => 5,
            6 => 5,
            7 => 6,
            8 => 8,
            default => 0.0,
        };
    }

    private function largoCarpa(int $indice): float
    {
        return match ($indice) {
            1, 2, 3 => 2,
            4, 5, 6, 7, 8 => 3,
            default => 0.0,
        };
    }

    private function anchoCarpa(int $indice): float
    {
        return match ($indice) {
            1 => 2,
            2, 3, 4, 5 => 3,
            6, 7, 8 => 4,
            default => 0.0,
        };
    }

    private function formatearRespuesta(float $respuesta, string $formula): string
    {
        $formula = strtoupper((string) preg_replace('/\s+/', '', $formula));
        $unidad = match ($formula) {
            'V*I', 'I*V', 'I*I*R', 'R*I*I', 'V*V/R' => 'W',
            'V/R' => 'A',
            'V/I' => 'ohm',
            'I*R', 'R*I' => 'V',
            'P/I' => 'V',
            'P/V' => 'A',
            'N*P', 'P*N', 'E/T' => 'W',
            'P*T', 'T*P' => 'J',
            'P*D*24*3600' => 'J',
            'E/D' => 'J',
            'P*H*30*238/1000' => '$',
            'T_INICIAL-DESCENSO_T', 'T_INICIAL+AUMENTO_T', 'T_MAX-T_MIN', 'T_FINAL+DESCENSO_T', 'T_INICIAL-DESCENSO_T+AUMENTO_T-DESCENSO_FINAL' => '°C',
            'ALTITUD_INICIAL+ASCENSO', 'ALTITUD_INICIAL-DESCENSO_ALT', 'ALTITUD_INICIAL+ASCENSO-DESCENSO_ALT' => 'm s. n. m.',
            'TOTAL_RACIONES*FRACCION_EXACTA', 'TOTAL_RACIONES-(TOTAL_RACIONES*FRACCION_EXACTA)', 'TOTAL_RACIONES*NUMERADOR/DENOMINADOR', 'TOTAL_RACIONES-(TOTAL_RACIONES*NUMERADOR/DENOMINADOR)', 'TOTAL_RACIONES*FRACCION', 'TOTAL_RACIONES-(TOTAL_RACIONES*FRACCION)' => 'raciones',
            'KM_RECORRIDOS/KM_TOTAL' => 'sin unidad',
            'ALIMENTO_G/PERSONAS_REPARTO' => 'g/persona',
            'RACION_G*PERSONAS' => 'g',
            'CEIL(ELEMENTOS/CAPACIDAD_CAJA)' => 'cajas',
            '(KM_RECORRIDOS/KM_TOTAL)*100' => '%',
            'TOTAL_ALIMENTO_KG*(1-FRACCION_ETAPA_1_EXACTA-FRACCION_ETAPA_2_EXACTA)', 'TOTAL_ALIMENTO_KG*(1-NUM_ETAPA_1/DEN_ETAPA_1-NUM_ETAPA_2/DEN_ETAPA_2)', 'TOTAL_ALIMENTO_KG*(1-FRACCION_ETAPA_1-FRACCION_ETAPA_2)' => 'kg',
            'COSTO_FIJO+COSTO_PERSONA*PERSONAS' => '$',
            'ESTACAS_CARPA*CANTIDAD_CARPAS+ESTACAS_RESERVA' => 'estacas',
            '(COSTO_TOTAL-COSTO_FIJO)/COSTO_PERSONA' => 'personas',
            '2*(LARGO+ANCHO)', 'PERIMETRO/2-LARGO', 'HIPOTENUSA_BASE*FACTOR' => 'm',
            'LARGO*ANCHO', 'LARGO*ANCHO-CANTIDAD_CARPAS*LARGO_CARPA*ANCHO_CARPA' => 'm2',
            default => '',
        };
        $decimales = match ($formula) {
            'KM_RECORRIDOS/KM_TOTAL' => 3,
            '(KM_RECORRIDOS/KM_TOTAL)*100' => 1,
            default => 6,
        };
        $numero = rtrim(rtrim(number_format($respuesta, $decimales, '.', ''), '0'), '.');

        return trim($numero . ' ' . $unidad);
    }

    private function guardarCombinacion(int $ejercicioId, string $codigo, string $hash, float $respuesta, string $respuestaTexto): int
    {
        $pdo = db();
        $stmt = $pdo->prepare(
            'INSERT INTO combinaciones_ejercicio (ejercicio_id, codigo_hash, codigo_combinacion, respuesta_numero, respuesta_texto, usos, activa)
             VALUES (?, ?, ?, ?, ?, 0, 1)
             ON DUPLICATE KEY UPDATE codigo_combinacion = VALUES(codigo_combinacion),
                                     respuesta_numero = VALUES(respuesta_numero),
                                     respuesta_texto = VALUES(respuesta_texto),
                                     activa = VALUES(activa)'
        );
        $stmt->execute([$ejercicioId, $hash, $codigo, $respuesta, $respuestaTexto]);

        $stmt = $pdo->prepare('SELECT id FROM combinaciones_ejercicio WHERE ejercicio_id = ? AND codigo_hash = ? LIMIT 1');
        $stmt->execute([$ejercicioId, $hash]);

        return (int) $stmt->fetchColumn();
    }

    private function guardarValorVariable(int $variableId, float $valor, int $orden): int
    {
        $pdo = db();
        $stmt = $pdo->prepare(
            'INSERT INTO valores_variable (variable_ejercicio_id, valor, activo, orden)
             VALUES (?, ?, 1, ?)
             ON DUPLICATE KEY UPDATE activo = VALUES(activo), orden = VALUES(orden)'
        );
        $stmt->execute([$variableId, $valor, $orden]);

        $stmt = $pdo->prepare('SELECT id FROM valores_variable WHERE variable_ejercicio_id = ? AND valor = ? LIMIT 1');
        $stmt->execute([$variableId, $valor]);

        return (int) $stmt->fetchColumn();
    }

    private function guardarValorCombinacion(int $combinacionId, int $variableId, int $valorVariableId, float $valor): void
    {
        $stmt = db()->prepare(
            'INSERT INTO combinacion_valores (combinacion_ejercicio_id, variable_ejercicio_id, valor_variable_id, valor)
             VALUES (?, ?, ?, ?)
             ON DUPLICATE KEY UPDATE valor_variable_id = VALUES(valor_variable_id), valor = VALUES(valor)'
        );
        $stmt->execute([$combinacionId, $variableId, $valorVariableId, $valor]);
    }
}
