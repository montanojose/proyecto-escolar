<?php

declare(strict_types=1);

require_once dirname(__DIR__) . '/config/database.php';

final class EjercicioService
{
    public function listarPorActividad(int $actividadId, ?int $intentoId = null): array
    {
        $stmt = db()->prepare(
            'SELECT id, consigna, explicacion, formula_respuesta, tolerancia
             FROM ejercicios
             WHERE actividad_id = ? AND activo = 1
             ORDER BY orden, id'
        );
        $stmt->execute([$actividadId]);

        $ejercicios = $stmt->fetchAll();
        $unidadesActividad = $this->opcionesUnidadActividad($ejercicios, $intentoId);

        return array_map(function (array $ejercicio) use ($intentoId, $unidadesActividad): array {
            $mapeado = $this->mapear($ejercicio, $intentoId);
            if ($unidadesActividad) {
                $mapeado['unitOptions'] = $unidadesActividad;
            }

            return $mapeado;
        }, $ejercicios);
    }

    public function obtener(int $id, ?int $intentoId = null): ?array
    {
        $stmt = db()->prepare(
            'SELECT id, consigna, explicacion, formula_respuesta, tolerancia FROM ejercicios WHERE id = ? AND activo = 1 LIMIT 1'
        );
        $stmt->execute([$id]);
        $ejercicio = $stmt->fetch();

        return $ejercicio ? $this->mapear($ejercicio, $intentoId) : null;
    }

    public function validar(int $id, string $respuesta, ?int $intentoId = null): array
    {
        $ejercicio = $this->obtener($id, $intentoId);
        if (!$ejercicio) {
            throw new InvalidArgumentException('No encontramos ese ejercicio.');
        }

        $numericResult = $this->validarNumerica($id, $respuesta, (float) ($ejercicio['tolerance'] ?? 0.01), $intentoId, (string) ($ejercicio['formula'] ?? ''));
        if ($numericResult !== null) {
            return $numericResult;
        }

        if ($ejercicio['correctAnswer'] === '') {
            return [
                'correct' => false,
                'correctAnswer' => '',
                'explanation' => 'Respuesta abierta guardada para revisión del profesor.',
                'numericValue' => $this->parseNumeroConUnidad($respuesta),
                'needsReview' => true,
            ];
        }

        $correcta = trim($respuesta) === trim($ejercicio['correctAnswer']);

        return [
            'correct' => $correcta,
            'correctAnswer' => $ejercicio['correctAnswer'],
            'explanation' => $ejercicio['explanation'],
            'numericValue' => $this->parseNumeroConUnidad($respuesta),
            'needsReview' => false,
        ];
    }

    public function parseNumeroConUnidad(string $respuesta): ?float
    {
        $cantidad = $this->parseCantidadConUnidad($respuesta);

        return $cantidad['value'] ?? null;
    }

    private function parseCantidadConUnidad(string $respuesta): array
    {
        $normalizada = trim($respuesta);
        $normalizada = str_replace(',', '.', $normalizada);
        $normalizada = str_replace(['ω', 'Ω'], 'ohm', $normalizada);
        $normalizada = preg_replace('/\s+/', ' ', $normalizada) ?? $normalizada;

        if (!preg_match('/([-+]?\d+(?:\.\d+)?)/', $normalizada, $match)) {
            return ['value' => null, 'unit' => null, 'dimension' => null];
        }

        $valor = (float) $match[1];
        $unidad = trim(str_replace($match[0], '', $normalizada));
        $unidad = str_replace([' ', '.', ';'], '', $unidad);
        $unidadOriginal = $unidad;
        $unidad = strtolower($unidad);

        if ($unidadOriginal === 'MW') {
            return ['value' => $valor * 1000000.0, 'unit' => 'MW', 'dimension' => 'power'];
        }

        $unidades = $this->unidadesValidacion();
        if (!isset($unidades[$unidad])) {
            return ['value' => $valor, 'unit' => $unidad, 'dimension' => null];
        }

        return [
            'value' => $valor * (float) $unidades[$unidad]['factor'],
            'unit' => $unidad,
            'dimension' => (string) $unidades[$unidad]['dimension'],
        ];
    }

    public function obtenerCombinacionAsignada(int $ejercicioId, ?int $intentoId = null): ?array
    {
        if ($intentoId !== null && $intentoId > 0) {
            $stmt = db()->prepare(
                'SELECT ce.id, ce.respuesta_numero, ce.respuesta_texto
                 FROM asignaciones_combinacion ac
                 INNER JOIN combinaciones_ejercicio ce ON ce.id = ac.combinacion_ejercicio_id
                 WHERE ac.intento_id = ? AND ac.ejercicio_id = ?
                 LIMIT 1'
            );
            $stmt->execute([$intentoId, $ejercicioId]);
            $combinacion = $stmt->fetch();
            if ($combinacion) {
                return $combinacion;
            }

        }

        $stmt = db()->prepare(
            'SELECT id, respuesta_numero, respuesta_texto
             FROM combinaciones_ejercicio
             WHERE ejercicio_id = ? AND activa = 1
             ORDER BY usos ASC, id ASC
             LIMIT 1'
        );
        $stmt->execute([$ejercicioId]);
        $combinacion = $stmt->fetch();

        return $combinacion ?: null;
    }

    private function validarNumerica(int $ejercicioId, string $respuesta, float $tolerancia, ?int $intentoId = null, string $formula = ''): ?array
    {
        $cantidadAlumno = $this->parseCantidadConUnidad($respuesta);
        $valorAlumno = $cantidadAlumno['value'];
        if ($valorAlumno === null) {
            return null;
        }

        $combinacion = $this->obtenerCombinacionAsignada($ejercicioId, $intentoId);

        if (!$combinacion || $combinacion['respuesta_numero'] === null) {
            return null;
        }

        $esperada = (float) $combinacion['respuesta_numero'];
        $respuestaEsperada = (string) ($combinacion['respuesta_texto'] ?? $esperada);
        $cantidadEsperada = $this->parseCantidadConUnidad($respuestaEsperada);
        $dimensionEsperada = $cantidadEsperada['dimension'];
        $dimensionAlumno = $cantidadAlumno['dimension'];

        if ($dimensionEsperada !== null && $dimensionAlumno === null) {
            return [
                'correct' => false,
                'correctAnswer' => $respuestaEsperada,
                'explanation' => 'La respuesta necesita una unidad válida.',
                'numericValue' => $valorAlumno,
                'expectedNumericValue' => $esperada,
                'needsReview' => false,
            ];
        }

        if ($dimensionEsperada !== null && $dimensionAlumno !== $dimensionEsperada) {
            return [
                'correct' => false,
                'correctAnswer' => $respuestaEsperada,
                'explanation' => 'La unidad no corresponde a la magnitud pedida.',
                'numericValue' => $valorAlumno,
                'expectedNumericValue' => $esperada,
                'needsReview' => false,
            ];
        }

        $margen = $this->margenTolerancia($esperada, $tolerancia, $formula);
        $correcta = abs($valorAlumno - $esperada) <= $margen;

        return [
            'correct' => $correcta,
            'correctAnswer' => $respuestaEsperada,
            'explanation' => $correcta
                ? 'Respuesta numérica y unidad correctas dentro de la tolerancia.'
                : 'La respuesta quedó fuera de la tolerancia esperada.',
            'numericValue' => $valorAlumno,
            'expectedNumericValue' => $esperada,
            'tolerance' => $margen,
            'needsReview' => false,
        ];
    }

    private function unidadesValidacion(): array
    {
        return [
            'a' => ['factor' => 1.0, 'dimension' => 'current'],
            'ma' => ['factor' => 0.001, 'dimension' => 'current'],
            'ua' => ['factor' => 0.000001, 'dimension' => 'current'],
            'microa' => ['factor' => 0.000001, 'dimension' => 'current'],
            'ka' => ['factor' => 1000.0, 'dimension' => 'current'],
            'v' => ['factor' => 1.0, 'dimension' => 'voltage'],
            'mv' => ['factor' => 0.001, 'dimension' => 'voltage'],
            'kv' => ['factor' => 1000.0, 'dimension' => 'voltage'],
            'w' => ['factor' => 1.0, 'dimension' => 'power'],
            'kw' => ['factor' => 1000.0, 'dimension' => 'power'],
            'mw' => ['factor' => 0.001, 'dimension' => 'power'],
            'megaw' => ['factor' => 1000000.0, 'dimension' => 'power'],
            'j' => ['factor' => 1.0, 'dimension' => 'energy'],
            'kj' => ['factor' => 1000.0, 'dimension' => 'energy'],
            'kwh' => ['factor' => 3600000.0, 'dimension' => 'energy'],
            'kwh/dia' => ['factor' => 3600000.0, 'dimension' => 'energy'],
            'kwhdia' => ['factor' => 3600000.0, 'dimension' => 'energy'],
            'kwh/día' => ['factor' => 3600000.0, 'dimension' => 'energy'],
            '$' => ['factor' => 1.0, 'dimension' => 'money'],
            'pesos' => ['factor' => 1.0, 'dimension' => 'money'],
            'ohm' => ['factor' => 1.0, 'dimension' => 'resistance'],
            'r' => ['factor' => 1.0, 'dimension' => 'resistance'],
            'kohm' => ['factor' => 1000.0, 'dimension' => 'resistance'],
            'k' => ['factor' => 1000.0, 'dimension' => 'resistance'],
            'mohm' => ['factor' => 1000000.0, 'dimension' => 'resistance'],
            'megohm' => ['factor' => 1000000.0, 'dimension' => 'resistance'],
            'm' => ['factor' => 1000000.0, 'dimension' => 'resistance'],
            'c' => ['factor' => 1.0, 'dimension' => 'temperature'],
            '°c' => ['factor' => 1.0, 'dimension' => 'temperature'],
            'ºc' => ['factor' => 1.0, 'dimension' => 'temperature'],
            'msnm' => ['factor' => 1.0, 'dimension' => 'altitude'],
            'racion' => ['factor' => 1.0, 'dimension' => 'ration'],
            'raciones' => ['factor' => 1.0, 'dimension' => 'ration'],
            'estaca' => ['factor' => 1.0, 'dimension' => 'stake'],
            'estacas' => ['factor' => 1.0, 'dimension' => 'stake'],
            'persona' => ['factor' => 1.0, 'dimension' => 'person'],
            'personas' => ['factor' => 1.0, 'dimension' => 'person'],
            'g/persona' => ['factor' => 1.0, 'dimension' => 'grams_per_person'],
            'gpersona' => ['factor' => 1.0, 'dimension' => 'grams_per_person'],
            'g' => ['factor' => 1.0, 'dimension' => 'mass_g'],
            'kg' => ['factor' => 1.0, 'dimension' => 'mass_kg'],
            'm' => ['factor' => 1.0, 'dimension' => 'length'],
            'm2' => ['factor' => 1.0, 'dimension' => 'area'],
            'm²' => ['factor' => 1.0, 'dimension' => 'area'],
            'caja' => ['factor' => 1.0, 'dimension' => 'box'],
            'cajas' => ['factor' => 1.0, 'dimension' => 'box'],
            '%' => ['factor' => 1.0, 'dimension' => 'percent'],
            'porcentaje' => ['factor' => 1.0, 'dimension' => 'percent'],
            'sinunidad' => ['factor' => 1.0, 'dimension' => 'dimensionless'],
            's' => ['factor' => 1.0, 'dimension' => 'time'],
            'seg' => ['factor' => 1.0, 'dimension' => 'time'],
            'min' => ['factor' => 60.0, 'dimension' => 'time'],
            'h' => ['factor' => 3600.0, 'dimension' => 'time'],
            'dia' => ['factor' => 1.0, 'dimension' => 'count'],
            'dias' => ['factor' => 1.0, 'dimension' => 'count'],
            'u' => ['factor' => 1.0, 'dimension' => 'count'],
        ];
    }

    private function mapear(array $ejercicio, ?int $intentoId = null): array
    {
        $combinacion = $this->obtenerCombinacionAsignada((int) $ejercicio['id'], $intentoId);
        $valores = $combinacion ? $this->valoresCombinacion((int) $combinacion['id']) : [];
        $consigna = $this->reemplazarVariables((string) $ejercicio['consigna'], $valores);
        $explicacion = $this->reemplazarVariables((string) $ejercicio['explicacion'], $valores);

        $stmt = db()->prepare(
            'SELECT texto, es_correcta FROM opciones_ejercicio WHERE ejercicio_id = ? ORDER BY orden, id'
        );
        $stmt->execute([(int) $ejercicio['id']]);
        $opciones = $stmt->fetchAll();
        $correcta = '';

        foreach ($opciones as $opcion) {
            if ((int) $opcion['es_correcta'] === 1) {
                $correcta = (string) $opcion['texto'];
                break;
            }
        }

        return [
            'id' => (int) $ejercicio['id'],
            'prompt' => $consigna,
            'explanation' => $explicacion,
            'options' => array_map(fn (array $opcion): string => (string) $opcion['texto'], $opciones),
            'correctAnswer' => $correcta,
            'formula' => (string) ($ejercicio['formula_respuesta'] ?? ''),
            'tolerance' => $ejercicio['tolerancia'] !== null ? (float) $ejercicio['tolerancia'] : null,
            'unitOptions' => $combinacion ? $this->opcionesUnidadRespuesta((string) ($combinacion['respuesta_texto'] ?? '')) : [],
        ];
    }

    private function opcionesUnidadRespuesta(string $respuestaEsperada): array
    {
        $cantidad = $this->parseCantidadConUnidad($respuestaEsperada);

        return match ($cantidad['dimension'] ?? null) {
            'current' => ['A', 'mA', 'uA'],
            'voltage' => ['V', 'mV', 'kV'],
            'resistance' => ['ohm', 'kohm', 'Mohm'],
            'power' => ['W', 'kW', 'mW', 'MW'],
            'energy' => ['J', 'kJ', 'kWh'],
            'time' => ['s', 'min', 'h'],
            'money' => ['$'],
            'temperature' => ['°C'],
            'altitude' => ['m s. n. m.'],
            'ration' => ['raciones'],
            'stake' => ['estacas'],
            'person' => ['personas'],
            'grams_per_person' => ['g/persona'],
            'mass_g' => ['g'],
            'mass_kg' => ['kg'],
            'length' => ['m'],
            'area' => ['m2'],
            'box' => ['cajas'],
            'percent' => ['%'],
            'dimensionless' => ['sin unidad'],
            'count' => ['u', 'dia'],
            default => [],
        };
    }

    private function opcionesUnidadActividad(array $ejercicios, ?int $intentoId = null): array
    {
        $opciones = [];
        foreach ($ejercicios as $ejercicio) {
            $combinacion = $this->obtenerCombinacionAsignada((int) $ejercicio['id'], $intentoId);
            if (!$combinacion) {
                continue;
            }

            foreach ($this->opcionesUnidadRespuesta((string) ($combinacion['respuesta_texto'] ?? '')) as $unidad) {
                if (!in_array($unidad, $opciones, true)) {
                    $opciones[] = $unidad;
                }
            }
        }

        return $opciones;
    }

    private function margenTolerancia(float $esperada, float $tolerancia, string $formula): float
    {
        if ($tolerancia <= 0.0) {
            return 0.000001;
        }

        $formulaNormalizada = strtoupper((string) preg_replace('/\s+/', '', $formula));
        $toleranciaAbsoluta = in_array($formulaNormalizada, [
            'KM_RECORRIDOS/KM_TOTAL',
            '(KM_RECORRIDOS/KM_TOTAL)*100',
        ], true);

        if ($toleranciaAbsoluta) {
            return max($tolerancia, 0.000001);
        }

        return max(abs($esperada) * $tolerancia, 0.000001);
    }

    private function valoresCombinacion(int $combinacionId): array
    {
        $stmt = db()->prepare(
            'SELECT ve.nombre, ve.etiqueta, u.simbolo, cv.valor, vb.etiqueta AS etiqueta_banco
             FROM combinacion_valores cv
             INNER JOIN variables_ejercicio ve ON ve.id = cv.variable_ejercicio_id
             INNER JOIN unidades u ON u.id = ve.unidad_id
             LEFT JOIN valores_variable vv ON vv.id = cv.valor_variable_id
             LEFT JOIN valores_banco_seccion vb ON vb.banco_valores_seccion_id = ve.banco_valores_seccion_id AND vb.indice = vv.orden
             WHERE cv.combinacion_ejercicio_id = ?'
        );
        $stmt->execute([$combinacionId]);

        $valores = [];
        $numericos = [];
        foreach ($stmt->fetchAll() as $row) {
            $etiquetaBanco = trim((string) ($row['etiqueta_banco'] ?? ''));
            $simbolo = (string) $row['simbolo'];
            $nombre = (string) $row['nombre'];
            $numericos[$nombre] = (float) $row['valor'];
            $usarEtiquetaBanco = $etiquetaBanco !== '' && ($simbolo === '' || in_array($nombre, ['CANTIDAD_CARPAS', 'LARGO_CARPA', 'ANCHO_CARPA'], true));
            $valores[$nombre] = $usarEtiquetaBanco
                ? $etiquetaBanco
                : $this->formatearValor((float) $row['valor'], $simbolo);
        }

        $this->agregarValoresDerivados($valores, $numericos);

        return $valores;
    }

    private function agregarValoresDerivados(array &$valores, array $numericos): void
    {
        if (isset($numericos['COSTO_FIJO'], $numericos['COSTO_PERSONA'], $numericos['PERSONAS'])) {
            $valores['COSTO_TOTAL'] = $this->formatearValor($numericos['COSTO_FIJO'] + $numericos['COSTO_PERSONA'] * $numericos['PERSONAS'], '$');
        }

        if (isset($numericos['LARGO'], $numericos['ANCHO'])) {
            $valores['PERIMETRO'] = $this->formatearValor(2 * ($numericos['LARGO'] + $numericos['ANCHO']), 'm');
        }

        if (isset($numericos['CATETO_BASE_A'], $numericos['CATETO_BASE_B'], $numericos['FACTOR'])) {
            $valores['CATETO_A'] = $this->formatearValor($numericos['CATETO_BASE_A'] * $numericos['FACTOR'], 'm');
            $valores['CATETO_B'] = $this->formatearValor($numericos['CATETO_BASE_B'] * $numericos['FACTOR'], 'm');
        }
    }

    private function reemplazarVariables(string $texto, array $valores): string
    {
        foreach ($valores as $nombre => $valor) {
            $texto = str_replace('{' . $nombre . '}', $valor, $texto);
        }

        return $texto;
    }

    private function formatearValor(float $valor, string $unidad): string
    {
        $numero = rtrim(rtrim(number_format($valor, 6, ',', ''), '0'), ',');

        return trim($numero . ' ' . $unidad);
    }
}
