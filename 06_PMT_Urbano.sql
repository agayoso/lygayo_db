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

UPDATE #PMT_URBANO
SET tiene_seguro = CASE WHEN tiene_seguro >= 1 AND tiene_seguro <= 6 THEN 1 ELSE 0 END
WHERE tiene_seguro <> 9
GO

UPDATE #PMT_URBANO
SET tiene_seguro = CASE WHEN tiene_seguro > 6 THEN NULL ELSE tiene_seguro END
GO

UPDATE #PMT_URBANO
SET tiene_termocalefon = CASE WHEN tiene_termocalefon = 1 THEN 1 ELSE 0 END
WHERE tiene_termocalefon <= 6
GO

UPDATE #PMT_URBANO
SET tiene_termocalefon = CASE WHEN tiene_termocalefon > 6 THEN NULL ELSE tiene_termocalefon END
GO

UPDATE #PMT_URBANO
SET tiene_auto_camion = CASE WHEN tiene_auto_camion = 1 THEN 1 ELSE 0 END
WHERE tiene_auto_camion <= 6
GO

UPDATE #PMT_URBANO
SET tiene_auto_camion = CASE WHEN tiene_auto_camion > 6 THEN NULL ELSE tiene_auto_camion END
GO

UPDATE #PMT_URBANO
SET tiene_acondicionador_aire = CASE WHEN tiene_acondicionador_aire = 1 THEN 1 ELSE 0 END
WHERE tiene_acondicionador_aire <= 6
GO

UPDATE #PMT_URBANO
SET tiene_acondicionador_aire = CASE WHEN tiene_acondicionador_aire > 6 THEN NULL ELSE tiene_acondicionador_aire END
GO

UPDATE #PMT_URBANO
SET tiene_horno_microondas = CASE WHEN tiene_horno_microondas = 1 THEN 1 ELSE 0 END
WHERE tiene_horno_microondas <= 6
GO

UPDATE #PMT_URBANO
SET tiene_horno_microondas = CASE WHEN tiene_horno_microondas > 6 THEN NULL ELSE tiene_horno_microondas END
GO

UPDATE #PMT_URBANO
SET tiene_tv_cable = CASE WHEN tiene_tv_cable = 1 THEN 1 ELSE 0 END
WHERE tiene_tv_cable <= 6
GO

UPDATE #PMT_URBANO
SET tiene_tv_cable = CASE WHEN tiene_tv_cable > 6 THEN NULL ELSE tiene_tv_cable END
GO

UPDATE #PMT_URBANO
SET tiene_internet = CASE WHEN tiene_internet = 1 THEN 1 ELSE 0 END
WHERE tiene_internet <= 6
GO

UPDATE #PMT_URBANO
SET tiene_internet = CASE WHEN tiene_internet > 6 THEN NULL ELSE tiene_internet END
GO

--CARACTERISTICAS DEL JEFE

IF OBJECT_ID('tempdb..#jefe_tabla') IS NOT NULL
BEGIN
    DROP TABLE #jefe_tabla
END
GO

SELECT formulario, area, dpto, dominio,
relacion_parentesco as jefe,
edad as jefe_edad,
a�oest as jefe_anios_estudio,
idioma as jefe_idioma,
tipo_empleo as jefe_tipo_empleo
INTO #jefe_tabla
FROM #PMT_URBANO
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
SUM(tiene_seguro) nro_tiene_seguro,
AVG(totmiem) totmiem
INTO #demog_tabla
FROM #PMT_URBANO
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
AVG(tipo_techo) tipo_techo,
AVG(tipo_combustible) tipo_combustible,
AVG(tiene_termocalefon) tiene_termocalefon,
AVG(tiene_auto_camion) tiene_auto_camion,
AVG(tiene_acondicionador_aire) tiene_acondicionador_aire,
AVG(tiene_horno_microondas) tiene_horno_microondas,
AVG(tiene_tv_cable) tiene_tv_cable,
AVG(tiene_internet) tiene_internet
INTO #hogar_tabla
FROM #PMT_URBANO
GROUP BY formulario, area, dpto, dominio
GO

--TABLA FINAL
IF OBJECT_ID('tempdb..#tabla_final') IS NOT NULL
BEGIN
    DROP TABLE #tabla_final
END
GO

SELECT ht.formulario, ht.area, ht.dpto, ht.dominio, ht.nro_dormitorios, ht.tipo_piso, ht.tipo_techo,
ht.tipo_combustible, ht.tiene_termocalefon, ht.tiene_auto_camion, ht.tiene_horno_microondas,
ht.tiene_acondicionador_aire, ht.tiene_tv_cable, ht.tiene_internet,
jt.jefe_idioma, jt.jefe_edad, jt.jefe_anios_estudio,
jt.jefe_tipo_empleo, dt.nro_trabajo, dt.nro_5menos, dt.nro_6a15, dt.nro_tiene_seguro, dt.totmiem
INTO #tabla_final
FROM #hogar_tabla ht
LEFT JOIN #demog_tabla dt
ON ht.formulario = dt.formulario AND ht.area = dt.area AND ht.dpto = dt.dpto AND ht.dominio = dt.dominio
LEFT JOIN #jefe_tabla jt
ON ht.formulario = jt.formulario AND ht.area = jt.area AND ht.dpto = jt.dpto AND ht.dominio = jt.dominio
GO

ALTER TABLE #tabla_final
ADD piso_cat1 INT NULL,
techo_cat1 INT NULL,
comb2 INT NULL,
comb3 INT NULL,
jefe_guarani INT NULL,
jefe_bilingue INT NULL,
jefe_emp_3 INT NULL,
jefe_emp_4 INT NULL,
porc_trabajan FLOAT NULL,
porc_5menos FLOAT NULL,
porc_6a15 FLOAT NULL,
porc_seguro FLOAT NULL,
lndormitorios_pc FLOAT NULL
GO

UPDATE #tabla_final
SET
piso_cat1 = CASE WHEN (tipo_piso = 1 OR tipo_piso = 4) THEN 1 ELSE 0 END,
techo_cat1 = CASE WHEN (tipo_techo = 1) THEN 1 ELSE 0 END,
comb2 = CASE WHEN (tipo_combustible = 4) THEN 1 ELSE 0 END,
comb3 = CASE WHEN (tipo_combustible = 2 OR tipo_combustible = 7) THEN 1 ELSE 0 END,
jefe_guarani = CASE WHEN (jefe_idioma = 1) THEN 1 ELSE 0 END,
jefe_bilingue = CASE WHEN (jefe_idioma = 2) THEN 1 ELSE 0 END,
jefe_emp_3 = CASE WHEN (jefe_tipo_empleo = 3) THEN 1 ELSE 0 END,
jefe_emp_4 = CASE WHEN (jefe_tipo_empleo = 4) THEN 1 ELSE 0 END,
porc_trabajan = CAST(nro_trabajo AS FLOAT) / CAST(totmiem AS FLOAT),
porc_5menos = CAST(nro_5menos AS FLOAT) / CAST(totmiem AS FLOAT),
porc_6a15 = CAST(nro_6a15 AS FLOAT) / CAST(totmiem AS FLOAT),
porc_seguro = CAST(nro_tiene_seguro AS FLOAT) / CAST(totmiem AS FLOAT),
lndormitorios_pc = LOG(CAST(nro_dormitorios AS FLOAT) / CAST(totmiem AS FLOAT))
GO

--ESTABLECE LINEAS DE POBREZA MONETARIA
ALTER TABLE #tabla_final
ADD lpobtot_urbano FLOAT NULL,
lpobext_urbano FLOAT NULL
GO

UPDATE #tabla_final
SET lpobtot_urbano = 13.47976,
lpobext_urbano = 12.81748
GO

--APLICA EL PMT URBANO
ALTER TABLE #tabla_final
ADD lninc_est FLOAT NULL
GO

DECLARE @w_jefe_guarani AS FLOAT = -0.118013
DECLARE @w_jefe_bilingue AS FLOAT = -0.0814166
DECLARE @w_jefe_edad AS FLOAT = 0.0040398
DECLARE @w_jefe_estudios AS FLOAT = 0.0218068
DECLARE @w_jefe_emp3 AS FLOAT = 0.212966
DECLARE @w_jefe_emp4 AS FLOAT = -0.1547752
DECLARE @w_m5menos AS FLOAT = -0.4086914
DECLARE @w_m6a15 AS FLOAT = -0.3264735
DECLARE @w_trabajan AS FLOAT = 0.6315658
DECLARE @w_mseguro AS FLOAT = 0.2140596
DECLARE @w_totmiem AS FLOAT = -0.0516614
DECLARE @w_lndorms_pc AS FLOAT = 0.2022584
DECLARE @w_termocalefon AS FLOAT = 0.2389016
DECLARE @w_auto_camion AS FLOAT = 0.2217927
DECLARE @w_microondas AS FLOAT = 0.1072313
DECLARE @w_aire_acon AS FLOAT = 0.1486044
DECLARE @w_tv_cable AS FLOAT = 0.0771921
DECLARE @w_internet AS FLOAT = 0.2197028
DECLARE @w_piso_cat1 AS FLOAT = -0.0570148
DECLARE @w_techo_cat1 AS FLOAT = -0.0730014
DECLARE @w_comb2 AS FLOAT = 0.192622
DECLARE @w_comb3 AS FLOAT = 0.1913003
DECLARE @constante AS FLOAT = 13.33173
UPDATE #tabla_final
SET lninc_est = @constante + jefe_guarani*@w_jefe_guarani + jefe_bilingue*@w_jefe_bilingue + jefe_edad*@w_jefe_edad +
                jefe_anios_estudio*@w_jefe_estudios + jefe_emp_3*@w_jefe_emp3 + jefe_emp_4*@w_jefe_emp4 + porc_5menos*@w_m5menos +
				porc_6a15*@w_m6a15 + porc_trabajan*@w_trabajan + porc_seguro*@w_mseguro + totmiem*@w_totmiem + lndormitorios_pc*@w_lndorms_pc +
				tiene_termocalefon*@w_termocalefon + tiene_auto_camion*@w_auto_camion + tiene_horno_microondas*@w_microondas +
				@w_aire_acon*tiene_acondicionador_aire + tiene_tv_cable*@w_tv_cable + tiene_internet*@w_internet +
				piso_cat1*@w_piso_cat1 + techo_cat1*@w_techo_cat1 + comb2*@w_comb2 + comb3*@w_comb3
GO

ALTER TABLE #tabla_final
ADD status_pobreza INT NULL,
status_pobreza_et VARCHAR(25) NUlL
GO

UPDATE #tabla_final
SET status_pobreza = CASE
WHEN lninc_est <= lpobext_urbano THEN 1
WHEN lninc_est > lpobext_urbano AND lninc_est <= lpobtot_urbano THEN 2
WHEN lninc_est > lpobtot_urbano THEN 3 END,
status_pobreza_et = CASE
WHEN lninc_est <= lpobext_urbano THEN 'pobre extremo'
WHEN lninc_est > lpobext_urbano AND lninc_est <= lpobtot_urbano THEN 'pobre no extremo'
WHEN lninc_est > lpobtot_urbano THEN 'no pobre monetario' END
GO

--GENERA TABLA FINAL PARA DOMINIO URBANO
IF OBJECT_ID('PMT_URBANO') IS NOT NULL
BEGIN
    DROP TABLE PMT_URBANO
END
GO

SELECT * INTO PMT_URBANO
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
