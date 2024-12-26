USE RSH
GO

IF OBJECT_ID('tempdb..#PMT_METROPOLITANO') IS NOT NULL
BEGIN
    DROP TABLE #PMT_METROPOLITANO
END
GO

SELECT formulario,
    v01b   nro_dormitorios,
    v03    tipo_piso,
    v11    tipo_banho_desague,
    v09    tiene_linea_fija,
    v12b   tipo_combustible,
    v15a2  tiene_tableta,
    v15b   tiene_internet,
    v1604  tiene_termocalefon,
    v1608  tiene_horno_electrico,
    v1609  tiene_auto_camion,
    p09    edad,
    p04    relacion_parentesco,
    p05    es_miembro_hogar,
    s01    tiene_seguro,
    a02    trabajo_7dias,
    a03    trabajo_1hr,
    a04    trabajo_no_realizado,
    b06    tipo_empleo,
    ed01   idioma,
    tipohoga,
    añoest,
    totpers,
    totmiem,
    CASE
        WHEN (dpto = 0 OR dpto = 11) AND area = 1 THEN 0
        WHEN area = 6 THEN 6
        WHEN area = 1 THEN 1
    END AS dominio,
    area,
    dpto
INTO #PMT_METROPOLITANO
FROM RSH_BASE
WHERE CASE
    WHEN (dpto = 0 OR dpto = 11) AND area = 1 THEN 0
    WHEN area = 6 THEN 6
    WHEN area = 1 THEN 1
END = 0 AND
p05 = 1 AND
p04 < 11
GO

UPDATE #PMT_METROPOLITANO
SET tiene_seguro = CASE WHEN tiene_seguro >= 1 AND tiene_seguro <= 6 THEN 1 ELSE 0 END
WHERE tiene_seguro <> 9
GO

UPDATE #PMT_METROPOLITANO
SET tiene_seguro = CASE WHEN tiene_seguro > 6 THEN NULL ELSE tiene_seguro END
GO

UPDATE #PMT_METROPOLITANO
SET tiene_tableta = CASE WHEN tiene_tableta = 1 THEN 1 ELSE 0 END
WHERE tiene_tableta <= 6
GO

UPDATE #PMT_METROPOLITANO
SET tiene_tableta = CASE WHEN tiene_tableta > 6 THEN NULL ELSE tiene_tableta END
GO

UPDATE #PMT_METROPOLITANO
SET tiene_internet = CASE WHEN tiene_internet = 1 THEN 1 ELSE 0 END
WHERE tiene_internet <= 6
GO

UPDATE #PMT_METROPOLITANO
SET tiene_internet = CASE WHEN tiene_internet > 6 THEN NULL ELSE tiene_internet END
GO

UPDATE #PMT_METROPOLITANO
SET tiene_termocalefon = CASE WHEN tiene_termocalefon = 1 THEN 1 ELSE 0 END
WHERE tiene_termocalefon <= 6
GO

UPDATE #PMT_METROPOLITANO
SET tiene_termocalefon = CASE WHEN tiene_termocalefon > 6 THEN NULL ELSE tiene_termocalefon END
GO

UPDATE #PMT_METROPOLITANO
SET tiene_horno_electrico = CASE WHEN tiene_horno_electrico = 1 THEN 1 ELSE 0 END
WHERE tiene_horno_electrico <= 6
GO

UPDATE #PMT_METROPOLITANO
SET tiene_horno_electrico = CASE WHEN tiene_horno_electrico > 6 THEN NULL ELSE tiene_horno_electrico END
GO

UPDATE #PMT_METROPOLITANO
SET tiene_auto_camion = CASE WHEN tiene_auto_camion = 1 THEN 1 ELSE 0 END
WHERE tiene_auto_camion <= 6
GO

UPDATE #PMT_METROPOLITANO
SET tiene_auto_camion = CASE WHEN tiene_auto_camion > 6 THEN NULL ELSE tiene_auto_camion END
GO

UPDATE #PMT_METROPOLITANO
SET tiene_linea_fija = CASE WHEN tiene_linea_fija = 1 THEN 1 ELSE 0 END
WHERE tiene_linea_fija <= 6
GO

UPDATE #PMT_METROPOLITANO
SET tiene_linea_fija = CASE WHEN tiene_linea_fija > 6 THEN NULL ELSE tiene_linea_fija END
GO

--CARACTERISTICAS DEL JEFE

IF OBJECT_ID('tempdb..#jefe_tabla') IS NOT NULL
BEGIN
    DROP TABLE #jefe_tabla
END
GO

SELECT formulario, area, dpto, dominio,
relacion_parentesco as jefe,
añoest as jefe_anios_estudio,
tipo_empleo as jefe_tipo_empleo,
CASE WHEN tipo_empleo BETWEEN 1 AND 3 THEN 1 ELSE 0 END AS jefe_cat_empleo,
'JEFE' AS categoria
INTO #jefe_tabla
FROM #PMT_METROPOLITANO
WHERE relacion_parentesco = 1
GO

UPDATE #jefe_tabla
SET jefe_tipo_empleo = CASE WHEN jefe_tipo_empleo IS NULL THEN 7 ELSE jefe_tipo_empleo END
GO

--DEMOGRAFIA DEL HOGAR
IF OBJECT_ID('tempdb..#demog_tabla') IS NOT NULL
BEGIN
    DROP TABLE #demog_tabla
END
GO

SELECT formulario, area, dpto, dominio,
SUM(CASE WHEN edad >= 16 AND (trabajo_7dias = 1 OR trabajo_1hr = 1 OR trabajo_no_realizado = 1) THEN 1 ELSE 0 END) nro_trabajo,
SUM(CASE WHEN edad <= 5 THEN 1 ELSE 0 END) nro_5menos,
SUM(CASE WHEN edad > 5 AND edad <= 14 THEN 1 ELSE 0 END) nro_6a14,
SUM(CASE WHEN edad > 5 AND edad <= 15 THEN 1 ELSE 0 END) nro_0a15,
SUM(tiene_seguro) nro_tiene_seguro,
AVG(totmiem) totmiem,
LOG(AVG(nro_dormitorios) / AVG(totpers)) AS hh_lndormitorios_pc,
LOG(AVG(totpers)) AS hh_lntotpers,
(SUM(CASE WHEN edad <= 5 THEN 1 ELSE 0 END) + SUM(CASE WHEN edad > 5 AND edad <= 14 THEN 1 ELSE 0 END)) / AVG(totpers) AS hh_porc_0a14,
SUM(tiene_seguro) / AVG(totpers) AS hh_porc_seguro,
SUM(CASE WHEN edad >= 16 AND (trabajo_7dias = 1 OR trabajo_1hr = 1 OR trabajo_no_realizado = 1) THEN 1 ELSE 0 END) / AVG(totpers) AS hh_porc_trabajan,
'HOGAR' AS categoria
INTO #demog_tabla
FROM #PMT_METROPOLITANO
GROUP BY formulario, area, dpto, dominio
GO

--CARACTERISTICAS DEL HOGAR
IF OBJECT_ID('tempdb..#hogar_tabla') IS NOT NULL
BEGIN
    DROP TABLE #hogar_tabla
END
GO

SELECT formulario, area, dpto, dominio,
AVG(nro_dormitorios) nro_dormitorios,
CASE WHEN tipo_combustible IN (2, 4, 7) THEN 1 ELSE 0 END AS cat_combustible,
CASE WHEN tipo_piso IN (1, 2, 4) THEN 1 ELSE 0 END AS piso_cat,
CASE WHEN tipo_banho_desague IN (1, 2, 3) THEN 1 ELSE 0 END AS desague_cat,
AVG(tiene_linea_fija) tiene_linea_fija,
AVG(tiene_tableta) tiene_tableta,
AVG(tiene_internet) tiene_internet,
AVG(tiene_termocalefon) tiene_termocalefon,
AVG(tiene_horno_electrico) tiene_horno_electrico,
AVG(tiene_auto_camion) tiene_auto_camion,
'VIVIENDA' AS categoria
INTO #hogar_tabla
FROM #PMT_METROPOLITANO
GROUP BY formulario, area, dpto, dominio
GO

--TABLA FINAL
IF OBJECT_ID('tempdb..#tabla_final') IS NOT NULL
BEGIN
    DROP TABLE #tabla_final
END
GO

SELECT ht.formulario, ht.area, ht.dpto, ht.dominio, ht.nro_dormitorios, ht.piso_cat, ht.desague_cat,
ht.cat_combustible, ht.tiene_linea_fija, ht.tiene_termocalefon, ht.tiene_auto_camion, ht.tiene_horno_electrico,
ht.tiene_tableta, ht.tiene_internet,
jt.jefe_tipo_empleo, jt.jefe_cat_empleo, jt.jefe_anios_estudio,
dt.nro_trabajo, dt.nro_5menos, dt.nro_6a14, dt.nro_0a15, dt.nro_tiene_seguro, dt.hh_lndormitorios_pc, dt.hh_lntotpers,
dt.hh_porc_0a14, dt.hh_porc_seguro, dt.hh_porc_trabajan
INTO #tabla_final
FROM #hogar_tabla ht
LEFT JOIN #demog_tabla dt
ON ht.formulario = dt.formulario AND ht.area = dt.area AND ht.dpto = dt.dpto AND ht.dominio = dt.dominio
LEFT JOIN #jefe_tabla jt
ON ht.formulario = jt.formulario AND ht.area = jt.area AND ht.dpto = jt.dpto AND ht.dominio = jt.dominio
GO

ALTER TABLE #tabla_final
ADD lninc_est FLOAT NULL,
status_pobreza INT NULL,
status_pobreza_et VARCHAR(25) NULL
GO

DECLARE @constante FLOAT = 13.673300
DECLARE @lpobtot_metro FLOAT = 13.69732
DECLARE @lpobext_metro FLOAT = 13.17981
DECLARE @w_piso FLOAT = -0.0904969
DECLARE @w_combustible FLOAT = 0.0966806
DECLARE @w_desague FLOAT = 0.1657502
DECLARE @w_trabajan FLOAT = 0.5972428
DECLARE @w_seguro FLOAT = 0.2448074
DECLARE @w_0a14 FLOAT = -0.3763890
DECLARE @w_totmiem FLOAT = -0.2250395
DECLARE @w_lndorm_pc FLOAT = 0.2744557
DECLARE @w_jefe_empleo FLOAT = 0.0516161
DECLARE @w_jefe_estudio FLOAT = 0.0193651
DECLARE @w_termocalefon FLOAT = 0.2324976
DECLARE @w_auto_camion FLOAT = 0.1827654
DECLARE @w_tableta FLOAT = 0.1762143
DECLARE @w_internet FLOAT = 0.1215253
DECLARE @w_horno_elec FLOAT = 0.0585011
DECLARE @w_linea_fija FLOAT = 0.1788722

UPDATE #tabla_final
SET lninc_est = @constante + ht.piso_cat*@w_piso + ht.cat_combustible*@w_combustible + ht.desague_cat*@w_desague +
                dt.hh_porc_trabajan*@w_trabajan + dt.hh_porc_seguro*@w_seguro + dt.hh_porc_0a14*@w_0a14 +
                dt.hh_lntotpers*@w_totmiem + dt.hh_lndormitorios_pc*@w_lndorm_pc + jt.jefe_cat_empleo*@w_jefe_empleo +
                jt.jefe_anios_estudio*@w_jefe_estudio + ht.tiene_termocalefon*@w_termocalefon + ht.tiene_auto_camion*@w_auto_camion +
                ht.tiene_tableta*@w_tableta + ht.tiene_internet*@w_internet + ht.tiene_horno_electrico*@w_horno_elec + ht.tiene_linea_fija*@w_linea_fija
GO

UPDATE #tabla_final
SET status_pobreza = CASE
                        WHEN lninc_est < @lpobext_metro THEN 1
                        WHEN lninc_est >= @lpobext_metro AND lninc_est < @lpobtot_metro THEN 2
                        ELSE 3 END,
    status_pobreza_et = CASE
                            WHEN lninc_est < @lpobext_metro THEN 'pobre extremo'
                            WHEN lninc_est >= @lpobext_metro AND lninc_est < @lpobtot_metro THEN 'pobre no extremo'
                            ELSE 'no pobre' END
GO

-- GENERAR LA TABLA FINAL PARA EL DOMINIO METROPOLITANO
IF OBJECT_ID('PMT_METROPOLITANO') IS NOT NULL
BEGIN
    DROP TABLE PMT_METROPOLITANO
END
GO

SELECT * INTO PMT_METROPOLITANO
FROM #tabla_final
GO

-- LIMPIAR TABLAS TEMPORALES
IF OBJECT_ID('tempdb..#PMT_METROPOLITANO') IS NOT NULL
BEGIN
    DROP TABLE #PMT_METROPOLITANO
END
GO

IF OBJECT_ID('tempdb..#jefe_tabla') IS NOT NULL
BEGIN
    DROP TABLE #jefe_tabla
END
GO

IF OBJECT_ID('tempdb..#demog_tabla') IS NOT NULL
BEGIN
    DROP TABLE #demog_tabla
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
