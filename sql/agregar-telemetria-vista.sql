-- Agrega telemetria (tiempo por etapa + modelo usado) a la vista que lee
-- analisis.html. Es la MISMA definicion que ya tenia la vista, con una sola
-- columna nueva agregada al final del SELECT (x.telemetria) -- respeta la
-- regla del proyecto de que a una vista existente solo se le puede sumar
-- columnas al final, nunca insertarlas en el medio.
--
-- Requisito: haber corrido antes reporte_inteligente/sql/agregar-telemetria.sql
-- (el ALTER TABLE que agrega la columna telemetria a ri_respuesta).

CREATE OR REPLACE VIEW public.ri_reporte_final AS
SELECT r.run_id,
    r.entorno,
    r.iniciado_en,
    x.question_id,
    x.orden,
    x.categoria,
    x.pregunta,
    x.tipo_grafico,
    x.titulo,
        CASE
            WHEN x.comentarios IS NULL OR x.comentarios = x.mensaje THEN x.mensaje
            WHEN x.mensaje IS NULL THEN x.comentarios
            ELSE (x.mensaje || ' '::text) || x.comentarios
        END AS respuesta_texto,
    x.captura_url,
    x.duracion_ms,
    a.responde_pregunta,
    a.calidad_datos,
    a.grafico_apropiado,
    a.problemas_visuales,
    a.hallazgos,
    a.resumen AS veredicto_resumen,
    COALESCE(a.severidad, 'pendiente'::text) AS severidad,
    a.analizado_en,
    r.ruc,
    r.razon_social,
    x.captura_tabla_url,
    s.sql_generado,
    s.ejecutado_ok AS sql_ejecutado_ok,
    s.error_sql,
    x.telemetria
   FROM ri_respuesta x
     JOIN ri_run r USING (run_id)
     LEFT JOIN ri_analisis a USING (run_id, question_id)
     LEFT JOIN ri_sql_generado s ON s.message_id_app = x.message_id_app
  WHERE x.estado = 'ok'::text
  ORDER BY (
        CASE COALESCE(a.severidad, 'pendiente'::text)
            WHEN 'grave'::text THEN 0
            WHEN 'menor'::text THEN 1
            WHEN 'pendiente'::text THEN 2
            WHEN 'ok'::text THEN 3
            ELSE NULL::integer
        END), x.orden;
