-- Agrega la columna de telemetria (tiempo por etapa + modelo usado por etapa)
-- a la tabla que ya guarda cada respuesta del Reporte Inteligente.
-- Es un ADD COLUMN puro: no toca datos existentes, no rompe nada que ya lea
-- esta tabla (las filas viejas simplemente quedan con telemetria = NULL).

ALTER TABLE public.ri_respuesta
  ADD COLUMN IF NOT EXISTS telemetria JSONB;

-- Forma esperada del JSON que va a llegar en esta columna (para referencia,
-- no hace falta un CHECK constraint, el JSONB acepta cualquier shape):
--
-- {
--   "duracion_intencion_consulta_ms": 1200,
--   "duracion_agente_sql_ms": 3400,
--   "duracion_clasificar_grafico_ms": 8100,
--   "duracion_armar_grafico_ms": 2100,
--   "duracion_total_medida_ms": 14800,
--   "modelo_intencion_consulta": "gpt-4.1-mini",
--   "modelo_agente_sql": "gpt-5.6-luna",
--   "modelo_clasificador_grafico": "gpt-5-nano",
--   "modelo_graficadora": "gpt-4.1-mini"
-- }

-- Indice opcional, util si mas adelante analisis.html filtra/agrupa por
-- modelo con muchos registros. Se puede agregar despues si hace falta,
-- no es necesario para que la funcionalidad ande.
-- CREATE INDEX IF NOT EXISTS idx_ri_respuesta_telemetria
--   ON public.ri_respuesta USING GIN (telemetria);
