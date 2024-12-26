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
       añoest,
       totpers,
       totmiem,
       CASE
           WHEN (dpto = 0 OR dpto = 11) AND area = 1 THEN 0
           WHEN area = 6 THEN 6
           WHEN area = 1 THEN 1
       END AS dominio,
       area,
       dpto,
       'VIVIENDA' AS categoria
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

-- Categorías de vivienda
ALTER TABLE #PMT_URBANO
ADD cat_agua_proveedor INT NULL,
    cat_banho_desague INT NULL,
    cat_basura INT NULL,
    cat_combustible INT NULL,
    cat_hogar_unipersonal INT NULL
GO

UPDATE #PMT_URBANO
SET cat_agua_proveedor = CASE WHEN tipo_agua_proveedor_beber IN (1, 5, 11) THEN 1 ELSE 0 END
GO

UPDATE #PMT_URBANO
SET cat_banho_desague = CASE WHEN tipo_banho_desague BETWEEN 1 AND 2 THEN 1 ELSE 0 END
GO

UPDATE #PMT_URBANO
SET cat_basura = CASE WHEN tipo_basura BETWEEN 2 AND 3 THEN 1 ELSE 0 END
GO

UPDATE #PMT_URBANO
SET cat_combustible = CASE WHEN tipo_combustible IN (2, 7) THEN 1 ELSE 0 END
GO

UPDATE #PMT_URBANO
SET cat_hogar_unipersonal = CASE WHEN tipohoga = 1 THEN 1 ELSE 0 END
GO

-- Tabla temporal para jefe
IF OBJECT_ID('tempdb..#jefe_tabla') IS NOT NULL
BEGIN
    DROP TABLE #jefe_tabla
END
GO

SELECT formulario, area, dpto, dominio,
       relacion_parentesco AS jefe,
       añoest AS jefe_anios_estudio,
       tipo_empleo AS jefe_tipo_empleo,
       idioma AS jefe_idioma,
       CASE WHEN tipo_empleo BETWEEN 1 AND 3 THEN 1 ELSE 0 END AS jefe_cat_empleo,
       CASE WHEN idioma BETWEEN 3 AND 4 THEN 1 ELSE 0 END AS jefe_cat_idioma,
       'JEFE' AS categoria
INTO #jefe_tabla
FROM #PMT_URBANO
WHERE relacion_parentesco = 1
GO

-- Tabla temporal para hogar
IF OBJECT_ID('tempdb..#hogar_tabla') IS NOT NULL
BEGIN
    DROP TABLE #hogar_tabla
END
GO

SELECT formulario, area, dpto, dominio,
       LOG(AVG(nro_dormitorios) / AVG(totpers)) AS hh_lndormitorios_pc,
       LOG(AVG(totpers)) AS hh_lntotpers,
       (SUM(CASE WHEN edad <= 5 THEN 1 ELSE 0 END) + SUM(CASE WHEN edad > 5 AND edad <= 14 THEN 1 ELSE 0 END)) / AVG(totpers) AS hh_porc_0a14,
       SUM(CASE WHEN edad >= 16 AND (trabajo_7dias = 1 OR trabajo_1hr = 1 OR trabajo_no_realizado = 1) THEN 1 ELSE 0 END) / AVG(totpers) AS hh_porc_trabajan,
       SUM(tiene_seguro) / AVG(totpers) AS hh_porc_seguro,
       'HOGAR' AS categoria
INTO #hogar_tabla
FROM #PMT_URBANO
GROUP BY formulario, area, dpto, dominio
GO

-- Tabla final consolidada
IF OBJECT_ID('tempdb..#tabla_final') IS NOT NULL
BEGIN
    DROP TABLE #tabla_final
END
GO

SELECT pu.formulario, pu.area, pu.dpto, pu.dominio,
       pu.cat_agua_proveedor, pu.cat_banho_desague, pu.cat_basura, pu.cat_combustible, pu.cat_hogar_unipersonal,
       ht.hh_lndormitorios_pc, ht.hh_lntotpers, ht.hh_porc_0a14, ht.hh_porc_trabajan, ht.hh_porc_seguro,
       jt.jefe_anios_estudio, jt.jefe_cat_empleo, jt.jefe_cat_idioma,
       pu.tiene_termocalefon, pu.tiene_auto_camion, pu.tiene_acondicionador_aire, pu.tiene_horno_microondas, pu.tiene_tv_cable, pu.tiene_internet
INTO #tabla_final
FROM #PMT_URBANO pu
LEFT JOIN #hogar_tabla ht ON pu.formulario = ht.formulario AND pu.area = ht.area AND pu.dpto = ht.dpto AND pu.dominio = ht.dominio
LEFT JOIN #jefe_tabla jt ON pu.formulario = jt.formulario AND pu.area = jt.area AND pu.dpto = jt.dpto AND pu.dominio = jt.dominio
GO

-- Agregar columnas para cálculo de pobreza
ALTER TABLE #tabla_final
ADD lninc_est FLOAT NULL,
    status_pobreza INT NULL,
    status_pobreza_et VARCHAR(25) NULL
GO

DECLARE @w_cat_agua_proveedor FLOAT = 0.1007666
DECLARE @w_cat_banho_desague FLOAT = 0.0521674
DECLARE @w_cat_basura FLOAT = 0.0985621
DECLARE @w_cat_combustible FLOAT = 0.0961469
DECLARE @w_cat_hogar_unipersonal FLOAT = 0.1059598
DECLARE @w_hh_lndormitorios_pc FLOAT = 0.1966894
DECLARE @w_hh_lntotpers FLOAT = -0.2057523
DECLARE @w_hh_porc_0a14 FLOAT = -0.4550504
DECLARE @w_hh_porc_trabajan FLOAT = 0.5247115
DECLARE @w_hh_porc_seguro FLOAT = 0.3278719
DECLARE @w_jefe_anios_estudio FLOAT = 0.0156513
DECLARE @w_jefe_cat_empleo FLOAT = 0.1498015
DECLARE @w_jefe_cat_idioma FLOAT = 0.0797395
DECLARE @w_tiene_acondicionador_aire FLOAT = 0.1082751
DECLARE @w_tiene_auto_camion FLOAT = 0.1714332
DECLARE @w_tiene_horno_microondas FLOAT = 0.0906720
DECLARE @w_tiene_internet FLOAT = 0.0718241
DECLARE @w_tiene_tv_cable FLOAT = 0.0570942
DECLARE @w_tiene_termocalefon FLOAT = 0.2819824
DECLARE @constante FLOAT = 13.3317300
DECLARE @lpobtot_urbano FLOAT = 13.62419
DECLARE @lpobext_urbano FLOAT = 13.02462

UPDATE #tabla_final
SET lninc_est = @constante +
    cat_agua_proveedor*@w_cat_agua_proveedor +
    cat_banho_desague*@w_cat_banho_desague +
    cat_basura*@w_cat_basura +
    cat_combustible*@w_cat_combustible +
    cat_hogar_unipersonal*@w_cat_hogar_unipersonal +
    hh_lndormitorios_pc*@w_hh_lndormitorios_pc +
    hh_lntotpers*@w_hh_lntotpers +
    hh_porc_0a14*@w_hh_porc_0a14 +
    hh_porc_trabajan*@w_hh_porc_trabajan +
    hh_porc_seguro*@w_hh_porc_seguro +
    jefe_anios_estudio*@w_jefe_anios_estudio +
    jefe_cat_empleo*@w_jefe_cat_empleo +
    jefe_cat_idioma*@w_jefe_cat_idioma +
    tiene_acondicionador_aire*@w_tiene_acondicionador_aire +
    tiene_auto_camion*@w_tiene_auto_camion +
    tiene_horno_microondas*@w_tiene_horno_microondas +
    tiene_internet*@w_tiene_internet +
    tiene_tv_cable*@w_tiene_tv_cable +
    tiene_termocalefon*@w_tiene_termocalefon
GO

UPDATE #tabla_final
SET status_pobreza = CASE
                        WHEN lninc_est <= @lpobext_urbano THEN 1
                        WHEN lninc_est > @lpobext_urbano AND lninc_est <= @lpobtot_urbano THEN 2
                        ELSE 3 END,
    status_pobreza_et = CASE
                            WHEN lninc_est <= @lpobext_urbano THEN 'pobre extremo'
                            WHEN lninc_est > @lpobext_urbano AND lninc_est <= @lpobtot_urbano THEN 'pobre no extremo'
                            ELSE 'no pobre monetario' END
GO

-- Generar tabla final
IF OBJECT_ID('PMT_URBANO') IS NOT NULL
BEGIN
    DROP TABLE PMT_URBANO
END
GO

SELECT * INTO PMT_URBANO
FROM #tabla_final
GO

-- Limpiar tablas temporales
IF OBJECT_ID('tempdb..#PMT_URBANO') IS NOT NULL
BEGIN
    DROP TABLE #PMT_URBANO
END
GO

IF OBJECT_ID('tempdb..#jefe_tabla') IS NOT NULL
BEGIN
    DROP TABLE #jefe_tabla
END
GO

IF OBJECT_ID('tempdb..#hogar_tabla') IS NOT NULL
BEGIN
    DROP TABLE #hogar_tabla
END
GO

IF OBJECT_ID('tempdb..#tabla_final') IS NOT NULL
BEGIN
    DROP TABLE #tabla_final
END
GO