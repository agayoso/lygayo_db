USE RSH
GO

IF OBJECT_ID('tempdb..#PMT_RURAL') IS NOT NULL
BEGIN
    DROP TABLE #PMT_RURAL
END
GO

SELECT formulario,
	v01b   nro_dormitorios,
	v06    tipo_agua_proveedor_beber,
	v11    tipo_banho_desague,
	v12b   tipo_combustible,
	v1601  tiene_heladera,
	v1602  tiene_cocina_gas,
	v1603  tiene_cocina_elec,
	v1607  tiene_horno_microondas,
	v1609  tiene_auto_camion,
	v1605  tiene_acondicionador_aire,
	v15a1  tiene_computadora,
	p09    edad,
	p04    relacion_parentesco,
	p05    es_miembro_hogar,
	p11    estado_civil,
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
	dpto,
'VIVIENDA' AS categoria
INTO #PMT_RURAL
FROM RSH_BASE
WHERE CASE
	WHEN (dpto = 0 OR dpto = 11) AND area = 1 THEN 0
	WHEN area = 6 THEN 6
	WHEN area = 1 THEN 1
END = 6 AND
p05 = 1 AND
p04 < 11
GO

UPDATE #PMT_RURAL
SET tiene_seguro = CASE WHEN tiene_seguro >= 1 AND tiene_seguro <= 6 THEN 1 ELSE 0 END
WHERE tiene_seguro <> 9
GO

UPDATE #PMT_RURAL
SET tiene_seguro = CASE WHEN tiene_seguro > 6 THEN NULL ELSE tiene_seguro END
GO

UPDATE #PMT_RURAL
SET tiene_auto_camion = CASE WHEN tiene_auto_camion = 1 THEN 1 ELSE 0 END
WHERE tiene_auto_camion <= 6
GO

UPDATE #PMT_RURAL
SET tiene_auto_camion = CASE WHEN tiene_auto_camion > 6 THEN NULL ELSE tiene_auto_camion END
GO

UPDATE #PMT_RURAL
SET tiene_cocina_gas = CASE WHEN tiene_cocina_gas = 1 THEN 1 ELSE 0 END
WHERE tiene_cocina_gas <= 6
GO

UPDATE #PMT_RURAL
SET tiene_cocina_gas = CASE WHEN tiene_cocina_gas > 6 THEN NULL ELSE tiene_cocina_gas END
GO

UPDATE #PMT_RURAL
SET tiene_cocina_elec =  CASE WHEN tiene_cocina_elec = 1 THEN 1 ELSE 0 END
WHERE tiene_cocina_elec <= 6
GO

UPDATE #PMT_RURAL
SET tiene_cocina_elec = CASE WHEN tiene_cocina_elec > 6 THEN NULL ELSE tiene_cocina_elec END
GO

UPDATE #PMT_RURAL
SET tiene_horno_microondas = CASE WHEN tiene_horno_microondas = 1 THEN 1 ELSE 0 END
WHERE tiene_horno_microondas <= 6
GO

UPDATE #PMT_RURAL
SET tiene_horno_microondas = CASE WHEN tiene_horno_microondas > 6 THEN NULL ELSE tiene_horno_microondas END
GO

UPDATE #PMT_RURAL
SET tiene_acondicionador_aire = CASE WHEN tiene_acondicionador_aire = 1 THEN 1 ELSE 0 END
WHERE tiene_acondicionador_aire <= 6
GO

UPDATE #PMT_RURAL
SET tiene_acondicionador_aire = CASE WHEN tiene_acondicionador_aire > 6 THEN NULL ELSE tiene_acondicionador_aire END
GO

UPDATE #PMT_RURAL
SET tiene_heladera = CASE WHEN tiene_heladera = 1 THEN 1 ELSE 0 END
WHERE tiene_heladera <= 6
GO

UPDATE #PMT_RURAL
SET tiene_heladera =  CASE WHEN tiene_heladera > 6 THEN NULL ELSE tiene_heladera  END
GO

UPDATE #PMT_RURAL
SET tiene_computadora = CASE WHEN tiene_computadora = 1 THEN 1 ELSE 0 END
WHERE tiene_computadora <= 6
GO

UPDATE #PMT_RURAL
SET tiene_computadora = CASE WHEN tiene_computadora > 6 THEN NULL ELSE tiene_computadora END
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
añoest as jefe_anios_estudio,
idioma as jefe_idioma,
tipo_empleo as jefe_tipo_empleo,
estado_civil as jefe_estado_civil,
CASE WHEN tipo_empleo BETWEEN 1 AND 3 THEN 1 ELSE 0 END AS jefe_cat_empleo,
CASE WHEN idioma BETWEEN 3 AND 4 THEN 1 ELSE 0 END AS jefe_cat_idioma,
'JEFE' AS categoria
INTO #jefe_tabla
FROM #PMT_RURAL
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
SUM(tiene_seguro) nro_tiene_seguro,
AVG(totmiem) totmiem,
LOG(AVG(nro_dormitorios) / AVG(totpers)) AS hh_lndormitorios_pc,
LOG(AVG(totpers)) AS hh_lntotpers,
(SUM(CASE WHEN edad <= 5 THEN 1 ELSE 0 END) + SUM(CASE WHEN edad > 5 AND edad <= 14 THEN 1 ELSE 0 END)) / AVG(totpers) AS hh_porc_0a14,
SUM(tiene_seguro) / AVG(totpers) AS hh_porc_seguro,
SUM(CASE WHEN edad >= 16 AND (trabajo_7dias = 1 OR trabajo_1hr = 1 OR trabajo_no_realizado = 1) THEN 1 ELSE 0 END) / AVG(totpers) AS hh_porc_trabajan,
'HOGAR' AS categoria
INTO #demog_tabla
FROM #PMT_RURAL
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
CASE WHEN tipo_agua_proveedor_beber IN (1, 5, 10) THEN 1 ELSE 0 END AS cat_agua_proveedor,
CASE WHEN tipo_banho_desague BETWEEN 1 AND 2 THEN 1 ELSE 0 END AS cat_banho_desague,
CASE WHEN tipo_combustible IN (2, 7) THEN 1 ELSE 0 END AS cat_combustible,
CASE WHEN tipohoga = 1 THEN 1 ELSE 0 END AS cat_hogar_unipersonal,
AVG(tiene_heladera) tiene_heladera,
AVG(tiene_cocina_elec) tiene_cocina_elec,
AVG(tiene_cocina_gas) tiene_cocina_gas,
AVG(tiene_horno_microondas) tiene_horno_microondas,
AVG(tiene_acondicionador_aire) tiene_acondicionador_aire,
AVG(tiene_computadora) tiene_computadora,
AVG(tiene_auto_camion) tiene_auto_camion,
'VIVIENDA' AS categoria
INTO #hogar_tabla
FROM #PMT_RURAL
GROUP BY formulario, area, dpto, dominio
GO

--TABLA FINAL
IF OBJECT_ID('tempdb..#tabla_final') IS NOT NULL
BEGIN
    DROP TABLE #tabla_final
END
GO

SELECT ht.formulario, ht.area, ht.dpto, ht.dominio, ht.nro_dormitorios, ht.cat_agua_proveedor, ht.cat_banho_desague,
ht.cat_combustible, ht.cat_hogar_unipersonal, ht.tiene_heladera, ht.tiene_cocina_elec, ht.tiene_cocina_gas, ht.tiene_horno_microondas,
ht.tiene_acondicionador_aire, ht.tiene_computadora, ht.tiene_auto_camion,
jt.jefe_idioma, jt.jefe_edad, jt.jefe_anios_estudio,jt.jefe_estado_civil,
jt.jefe_tipo_empleo, jt.jefe_cat_empleo, jt.jefe_cat_idioma,
dt.nro_trabajo, dt.nro_5menos, dt.nro_6a14, dt.nro_tiene_seguro, dt.hh_lndormitorios_pc, dt.hh_lntotpers, dt.hh_porc_0a14, dt.hh_porc_seguro, dt.hh_porc_trabajan
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

DECLARE @w_cat_agua_proveedor FLOAT = 0.2590669
DECLARE @w_cat_banho_desague FLOAT = 0.0579613
DECLARE @w_cat_combustible FLOAT = 0.0855281
DECLARE @w_cat_hogar_unipersonal FLOAT = 0.1605284
DECLARE @w_hh_lndormitorios_pc FLOAT = 0.1021776
DECLARE @w_hh_lntotpers FLOAT = -0.2513625
DECLARE @w_hh_porc_0a14 FLOAT = -0.4980037
DECLARE @w_hh_porc_seguro FLOAT = 0.3465624
DECLARE @w_hh_porc_trabajan FLOAT = 0.4619435
DECLARE @w_jefe_anios_estudio FLOAT = 0.0147913
DECLARE @w_jefe_cat_empleo FLOAT = 0.3076897
DECLARE @w_jefe_cat_idioma FLOAT = 0.1811722
DECLARE @w_tiene_acondicionador_aire FLOAT = 0.1002157
DECLARE @w_tiene_auto_camion FLOAT = 0.1735345
DECLARE @w_tiene_cocina_elec FLOAT = 0.0957579
DECLARE @w_tiene_cocina_gas FLOAT = 0.1409634
DECLARE @w_tiene_computadora FLOAT = 0.1306783
DECLARE @w_tiene_horno_microondas FLOAT = 0.1380380
DECLARE @constante FLOAT = 13.2046600
DECLARE @lpobtot_rural FLOAT = 13.2944100
DECLARE @lpobext_rural FLOAT = 12.9224800

UPDATE #tabla_final
SET lninc_est = @constante + ht.cat_agua_proveedor*@w_cat_agua_proveedor + ht.cat_banho_desague*@w_cat_banho_desague +
                ht.cat_combustible*@w_cat_combustible + ht.cat_hogar_unipersonal*@w_cat_hogar_unipersonal + dt.hh_lndormitorios_pc*@w_hh_lndormitorios_pc +
                dt.hh_lntotpers*@w_hh_lntotpers + dt.hh_porc_0a14*@w_hh_porc_0a14 + dt.hh_porc_seguro*@w_hh_porc_seguro + dt.hh_porc_trabajan*@w_hh_porc_trabajan +
                jt.jefe_anios_estudio*@w_jefe_anios_estudio + jt.jefe_cat_empleo*@w_jefe_cat_empleo + jt.jefe_cat_idioma*@w_jefe_cat_idioma +
                ht.tiene_acondicionador_aire*@w_tiene_acondicionador_aire + ht.tiene_auto_camion*@w_tiene_auto_camion + ht.tiene_cocina_elec*@w_tiene_cocina_elec +
                ht.tiene_cocina_gas*@w_tiene_cocina_gas + ht.tiene_computadora*@w_tiene_computadora + ht.tiene_horno_microondas*@w_tiene_horno_microondas
GO

UPDATE #tabla_final
SET status_pobreza = CASE
                        WHEN lninc_est <= @lpobext_rural THEN 1
                        WHEN lninc_est > @lpobext_rural AND lninc_est <= @lpobtot_rural THEN 2
                        ELSE 3 END,
    status_pobreza_et = CASE
                            WHEN lninc_est <= @lpobext_rural THEN 'pobre extremo'
                            WHEN lninc_est > @lpobext_rural AND lninc_est <= @lpobtot_rural THEN 'pobre no extremo'
                            ELSE 'no pobre' END
GO

-- GENERAR LA TABLA FINAL
IF OBJECT_ID('PMT_RURAL') IS NOT NULL
BEGIN
    DROP TABLE PMT_RURAL
END
GO

SELECT * INTO PMT_RURAL
FROM #tabla_final
GO

-- LIMPIAR TABLAS TEMPORALES
IF OBJECT_ID('tempdb..#PMT_RURAL') IS NOT NULL
BEGIN
    DROP TABLE #PMT_RURAL
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
