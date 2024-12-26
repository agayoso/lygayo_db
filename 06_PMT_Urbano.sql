USE RSH
GO

IF OBJECT_ID('tempdb..#PMT_URBANO') IS NOT NULL
BEGIN
    DROP TABLE #PMT_URBANO
END
GO

SELECT formulario,
       v01b nro_dormitorios,
       v03 tipo_piso,
       v04 tipo_techo,
       v12b tipo_combustible,
       v1604 tiene_termocalefon,
       v1609 tiene_auto_camion,
       v1605 tiene_acondicionador_aire,
       v1607 tiene_horno_microondas,
       v1606 tiene_tv_cable,
       v15b tiene_internet,
       p09 edad,
       p04 relacion_parentesco,
       p05 es_miembro_hogar,
       p11 estado_civil,
       s01 tiene_seguro,
       a02 trabajo_7dias,
       a03 trabajo_1hr,
       a04 trabajo_no_realizado,
       b06 tipo_empleo,
       ed01 idioma,
       a�oest,
       totpers,
       totmiem,
       CASE
           WHEN (dpto = 0 OR dpto = 11) AND area = 1 THEN 0
           WHEN area = 6 THEN 6
           WHEN area = 1 THEN 1
       END AS dominio,
       area,
       dpto
INTO #PMT_URBANO
FROM RSH_BASE
WHERE CASE
           WHEN (dpto = 0 OR dpto = 11) AND area = 1 THEN 0
           WHEN area = 6 THEN 6
           WHEN area = 1 THEN 1
       END = 1 AND
       p05 = 1 AND
       p04 < 11
GO

-- Actualización de variables como seguro, termocalefon, auto_camion, etc.
UPDATE #PMT_URBANO
SET tiene_seguro = CASE WHEN tiene_seguro >= 1 AND tiene_seguro <= 6 THEN 1 ELSE 0 END
WHERE tiene_seguro <> 9
GO

UPDATE #PMT_URBANO
SET tiene_termocalefon = CASE WHEN tiene_termocalefon = 1 THEN 1 ELSE 0 END
WHERE tiene_termocalefon <= 6
GO

UPDATE #PMT_URBANO
SET tiene_auto_camion = CASE WHEN tiene_auto_camion = 1 THEN 1 ELSE 0 END
WHERE tiene_auto_camion <= 6
GO

UPDATE #PMT_URBANO
SET tiene_acondicionador_aire = CASE WHEN tiene_acondicionador_aire = 1 THEN 1 ELSE 0 END
WHERE tiene_acondicionador_aire <= 6
GO

UPDATE #PMT_URBANO
SET tiene_horno_microondas = CASE WHEN tiene_horno_microondas = 1 THEN 1 ELSE 0 END
WHERE tiene_horno_microondas <= 6
GO

UPDATE #PMT_URBANO
SET tiene_tv_cable = CASE WHEN tiene_tv_cable = 1 THEN 1 ELSE 0 END
WHERE tiene_tv_cable <= 6
GO

UPDATE #PMT_URBANO
SET tiene_internet = CASE WHEN tiene_internet = 1 THEN 1 ELSE 0 END
WHERE tiene_internet <= 6
GO

-- Cálculo de las variables del hogar (porcentajes, logaritmos)
ALTER TABLE #PMT_URBANO
ADD hh_lndormitorios_pc AS (LOG(nro_dormitorios * 1.0 / totpers)),
    hh_lntotpers AS (LOG(totpers)),
    hh_porc_0a14 AS ((nro_5menos + nro_6a15) * 1.0 / totpers),
    hh_porc_trabajan AS (nro_trabajo * 1.0 / totpers),
    hh_porc_seguro AS (nro_tiene_seguro * 1.0 / totpers)
GO

-- Cálculo del ingreso estimado (lninc_est)
ALTER TABLE #PMT_URBANO
ADD lninc_est AS (
    13.3317300 +
    cat_agua_proveedor_beber * 0.1007666 +
    cat_banho_desague * 0.0521674 +
    cat_basura * 0.0985621 +
    cat_combustible * 0.0961469 +
    cat_hogar_unipersonal * 0.1059598 +
    hh_lndormitorios_pc * 0.1966894 +
    hh_lntotpers * (-0.2057523) +
    hh_porc_0a14 * (-0.4550504) +
    hh_porc_seguro * 0.3278719 +
    hh_porc_trabajan * 0.5247115 +
    jefe_anios_estudio * 0.0156513 +
    jefe_cat_empleo * 0.1498015 +
    jefe_cat_idioma * 0.0797395 +
    tiene_acondicionador_aire * 0.1082751 +
    tiene_auto_camion * 0.1714332 +
    tiene_cocina_elec * 0.0424315 +
    tiene_computadora * 0.1464662 +
    tiene_horno_microondas * 0.0906720 +
    tiene_internet * 0.0718241 +
    tiene_televisor * 0.0933939 +
    tiene_termocalefon * 0.2819824 +
    tiene_tv_cable * 0.0570942
)
GO

-- Cálculo del estatus de pobreza
ALTER TABLE #PMT_URBANO
ADD status_pobreza AS (
    CASE
        WHEN lninc_est <= 13.02462 THEN 1
        WHEN lninc_est <= 13.62419 THEN 2
        ELSE 3
    END
)
GO

-- Finalización de la tabla
SELECT * FROM #PMT_URBANO
GO
