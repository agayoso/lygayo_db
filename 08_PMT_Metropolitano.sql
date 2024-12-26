
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
a�oest as jefe_anios_estudio,
tipo_empleo as jefe_tipo_empleo
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
SUM(CASE WHEN edad > 5 AND edad <= 15 THEN 1 ELSE 0 END) nro_6a15,
SUM(CASE WHEN edad >= 0 AND edad <= 15 THEN 1 ELSE 0 END) nro_0a15,
SUM(tiene_seguro) nro_tiene_seguro,
AVG(totmiem) totmiem
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
AVG(tipo_piso) tipo_piso,
AVG(tipo_banho_desague) tipo_banho_desague,
AVG(tipo_combustible) tipo_combustible,
AVG(tiene_linea_fija) tiene_linea_fija,
AVG(tiene_tableta) tiene_tableta,
AVG(tiene_internet) tiene_internet,
AVG(tiene_termocalefon) tiene_termocalefon,
AVG(tiene_horno_electrico) tiene_horno_electrico,
AVG(tiene_auto_camion) tiene_auto_camion
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

SELECT ht.formulario, ht.area, ht.dpto, ht.dominio, ht.nro_dormitorios, ht.tipo_piso,
ht.tipo_combustible, ht.tipo_banho_desague, ht.tiene_linea_fija, ht.tiene_termocalefon,
ht.tiene_auto_camion, ht.tiene_horno_electrico, ht.tiene_tableta, ht.tiene_internet,
jt.jefe_tipo_empleo, jt.jefe_anios_estudio,
dt.nro_trabajo, dt.nro_5menos, dt.nro_6a15, dt.nro_0a15, dt.nro_tiene_seguro, dt.totmiem
INTO #tabla_final
FROM #hogar_tabla ht
LEFT JOIN #demog_tabla dt
ON ht.formulario = dt.formulario AND ht.area = dt.area AND ht.dpto = dt.dpto AND ht.dominio = dt.dominio
LEFT JOIN #jefe_tabla jt
ON ht.formulario = jt.formulario AND ht.area = jt.area AND ht.dpto = jt.dpto AND ht.dominio = jt.dominio
GO

ALTER TABLE #tabla_final
ADD piso_cat INT NULL,
desague_cat INT NULL,
comb_cat INT NULL,
jefe_empleo_cat INT NULL,
porc_trabajan FLOAT NULL,
porc_5menos FLOAT NULL,
porc_6a15 FLOAT NULL,
porc_0a15 FLOAT NULL,
porc_seguro FLOAT NULL,
lndormitorios_pc FLOAT NULL,
dpto_asu INT NULL
GO

UPDATE #tabla_final
SET
piso_cat = CASE WHEN (tipo_piso = 1 OR tipo_piso = 2 OR tipo_piso = 4) THEN 1 ELSE 0 END,
desague_cat = CASE WHEN (tipo_banho_desague = 1 OR tipo_banho_desague = 2 OR tipo_banho_desague = 3) THEN 1 ELSE 0 END,
comb_cat = CASE WHEN (tipo_combustible = 2 OR tipo_combustible = 4 OR tipo_combustible = 7) THEN 1 ELSE 0 END,
jefe_empleo_cat = CASE WHEN (jefe_tipo_empleo = 1 OR jefe_tipo_empleo = 2 OR jefe_tipo_empleo = 3) THEN 1 ELSE 0 END,
porc_trabajan = CAST(nro_trabajo AS FLOAT) / CAST(totmiem AS FLOAT),
porc_5menos = CAST(nro_5menos AS FLOAT) / CAST(totmiem AS FLOAT),
porc_6a15 = CAST(nro_6a15 AS FLOAT) / CAST(totmiem AS FLOAT),
porc_0a15 = CAST(nro_0a15 AS FLOAT) / CAST(totmiem AS FLOAT),
porc_seguro = CAST(nro_tiene_seguro AS FLOAT) / CAST(totmiem AS FLOAT),
lndormitorios_pc = LOG(CAST(nro_dormitorios AS FLOAT) / CAST(totmiem AS FLOAT)),
dpto_asu = CASE WHEN (dpto = 0) THEN 1 ELSE 0 END
GO

--ESTABLECE LINEAS DE POBREZA MONETARIA
ALTER TABLE #tabla_final
ADD lpobtot_metropolitano FLOAT NULL,
lpobext_metropolitano FLOAT NULL
GO

UPDATE #tabla_final
SET lpobtot_metropolitano = 13.46668,
lpobext_metropolitano = 12.94958
GO

--APLICA EL PMT METROPOLITANO
ALTER TABLE #tabla_final
ADD lninc_est FLOAT NULL
GO

DECLARE @w_jefe_empl	 AS FLOAT =  0.1413020
DECLARE @w_jefe_estudio  AS FLOAT =  0.0196398
DECLARE @w_trabajan		 AS FLOAT =  0.5197380
DECLARE @w_mseguro		 AS FLOAT =  0.2188841
DECLARE @w_m0a15 		 AS FLOAT = -0.4621517
DECLARE @w_totmiem		 AS FLOAT = -0.0275831
DECLARE @w_lndorms_pc	 AS FLOAT =  0.2857137
DECLARE @w_termocalefon	 AS FLOAT =  0.1822855
DECLARE @w_auto_camion   AS FLOAT =  0.1163685
DECLARE @w_tableta		 AS FLOAT =  0.2281701
DECLARE @w_internet      AS FLOAT =  0.1215253
DECLARE @w_horno_el		 AS FLOAT =  0.0948192
DECLARE @w_linea_fija	 AS FLOAT =  0.1788722
DECLARE @w_comb			 AS FLOAT =  0.1287907
DECLARE @w_piso			 AS FLOAT = -0.0904969
DECLARE @w_desague		 AS FLOAT =  0.1657502
DECLARE @w_asu			 AS FLOAT =  0.1901746
DECLARE @constante       AS FLOAT = 13.446070
UPDATE #tabla_final
SET lninc_est = @constante + jefe_empleo_cat*@w_jefe_empl + jefe_anios_estudio*@w_jefe_estudio + porc_trabajan*@w_trabajan +
                porc_seguro*@w_mseguro + porc_0a15*@w_m0a15 + totmiem*@w_totmiem + lndormitorios_pc*@w_lndorms_pc +
				tiene_termocalefon*@w_termocalefon + tiene_auto_camion*@w_auto_camion + tiene_tableta*@w_tableta +
				tiene_internet*@w_internet + tiene_horno_electrico*@w_horno_el + tiene_linea_fija*@w_linea_fija +
				comb_cat*@w_comb + piso_cat*@w_piso + desague_cat*@w_desague + dpto_asu*@w_asu
GO

ALTER TABLE #tabla_final
ADD status_pobreza INT NULL,
status_pobreza_et VARCHAR(25) NULL
GO

UPDATE #tabla_final
SET status_pobreza = CASE
WHEN lninc_est <= lpobext_metropolitano THEN 1
WHEN lninc_est > lpobext_metropolitano AND lninc_est <= lpobtot_metropolitano THEN 2
WHEN lninc_est > lpobtot_metropolitano THEN 3 END,
status_pobreza_et = CASE
WHEN lninc_est <= lpobext_metropolitano THEN 'pobre extremo'
WHEN lninc_est > lpobext_metropolitano  AND lninc_est <= lpobtot_metropolitano THEN 'pobre no extremo'
WHEN lninc_est > lpobtot_metropolitano THEN 'no pobre monetario' END
GO

--GENERA TABLA FINAL PARA DOMINIO METROPOLITANO
IF OBJECT_ID('PMT_METROPOLITANO') IS NOT NULL
BEGIN
    DROP TABLE PMT_METROPOLITANO
END
GO

SELECT * INTO PMT_METROPOLITANO
FROM #tabla_final
GO

--ELIMINA TABLAS TEMPORALES
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

IF OBJECT_ID('tempdb..#demog_tabla') IS NOT NULL
BEGIN
    DROP TABLE #demog_tabla
END
GO

IF OBJECT_ID('tempdb..#tabla_final') IS NOT NULL
BEGIN
    DROP TABLE #tabla_final
END
GO
