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
a�oest as jefe_anios_estudio,
idioma as jefe_idioma,
tipo_empleo as jefe_tipo_empleo,
estado_civil as jefe_estado_civil
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
SUM(CASE WHEN edad > 5 AND edad <= 15 THEN 1 ELSE 0 END) nro_6a15,
SUM(tiene_seguro) nro_tiene_seguro,
AVG(totmiem) totmiem
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
AVG(tipo_agua_proveedor_beber) tipo_agua_proveedor_beber,
AVG(tipo_banho_desague) tipo_banho_desague,
AVG(tipo_combustible) tipo_combustible,
AVG(tipohoga) tipohoga,
AVG(tiene_heladera) tiene_heladera,
AVG(tiene_cocina_elec) tiene_cocina_elec,
AVG(tiene_cocina_gas) tiene_cocina_gas,
AVG(tiene_horno_microondas) tiene_horno_microondas,
AVG(tiene_acondicionador_aire) tiene_acondicionador_aire,
AVG(tiene_computadora) tiene_computadora,
AVG(tiene_auto_camion) tiene_auto_camion
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

SELECT ht.formulario, ht.area, ht.dpto, ht.dominio, ht.nro_dormitorios, ht.tipo_agua_proveedor_beber, ht.tipo_banho_desague,
ht.tipo_combustible, ht.tipohoga, ht.tiene_heladera, ht.tiene_cocina_elec, ht.tiene_cocina_gas, ht.tiene_horno_microondas,
ht.tiene_acondicionador_aire, ht.tiene_computadora, ht.tiene_auto_camion,
jt.jefe_idioma, jt.jefe_edad, jt.jefe_anios_estudio,jt.jefe_estado_civil,
jt.jefe_tipo_empleo, dt.nro_trabajo, dt.nro_5menos, dt.nro_6a15, dt.nro_tiene_seguro, dt.totmiem
INTO #tabla_final
FROM #hogar_tabla ht
LEFT JOIN #demog_tabla dt
ON ht.formulario = dt.formulario AND ht.area = dt.area AND ht.dpto = dt.dpto AND ht.dominio = dt.dominio
LEFT JOIN #jefe_tabla jt
ON ht.formulario = jt.formulario AND ht.area = jt.area AND ht.dpto = jt.dpto AND ht.dominio = jt.dominio
GO

ALTER TABLE #tabla_final
ADD desague_cat1 INT NULL,
desague_cat2 INT NULL,
agua_proveedor_cat1 INT NULL,
comb1 INT NULL,
comb2 INT NULL,
tipo_hogar1 INT NULL,
jefe_guarani INT NULL,
jefe_casdiv INT NULL,
jefe_emp_1 INT NULL,
jefe_emp_2 INT NULL,
jefe_emp_3 INT NULL,
jefe_emp_4 INT NULL,
jefe_emp_5 INT NULL,
jefe_emp_6 INT NULL,
jefe_emp_7 INT NULL,
porc_trabajan FLOAT NULL,
porc_5menos FLOAT NULL,
porc_6a15 FLOAT NULL,
porc_seguro FLOAT NULL,
lndormitorios_pc FLOAT NULL
GO

UPDATE #tabla_final
SET
desague_cat1 = CASE WHEN (tipo_banho_desague = 2) THEN 1 ELSE 0 END,
desague_cat2 = CASE WHEN (tipo_banho_desague = 1 OR tipo_banho_desague = 3) THEN 1 ELSE 0 END,
agua_proveedor_cat1 = CASE WHEN (tipo_agua_proveedor_beber = 5 ) THEN 1 ELSE 0 END,
comb1 = CASE WHEN (tipo_combustible = 4) THEN 1 ELSE 0 END,
comb2 = CASE WHEN (tipo_combustible = 2 OR tipo_combustible = 7) THEN 1 ELSE 0 END,
tipo_hogar1 = CASE WHEN (tipohoga = 1 ) THEN 1 ELSE 0 END,
jefe_guarani = CASE WHEN (jefe_idioma = 1) THEN 1 ELSE 0 END,
jefe_casdiv  = CASE WHEN (jefe_estado_civil = 1 OR jefe_estado_civil = 6) THEN 1 ELSE 0 END,
jefe_emp_1 = CASE WHEN (jefe_tipo_empleo = 1) THEN 1 ELSE 0 END,
jefe_emp_2 = CASE WHEN (jefe_tipo_empleo = 2) THEN 1 ELSE 0 END,
jefe_emp_3 = CASE WHEN (jefe_tipo_empleo = 3) THEN 1 ELSE 0 END,
jefe_emp_4 = CASE WHEN (jefe_tipo_empleo = 4) THEN 1 ELSE 0 END,
jefe_emp_5 = CASE WHEN (jefe_tipo_empleo = 5) THEN 1 ELSE 0 END,
jefe_emp_6 = CASE WHEN (jefe_tipo_empleo = 6) THEN 1 ELSE 0 END,
jefe_emp_7 = CASE WHEN (jefe_tipo_empleo = 7) THEN 1 ELSE 0 END,
porc_trabajan = CAST(nro_trabajo AS FLOAT) / CAST(totmiem AS FLOAT),
porc_5menos = CAST(nro_5menos AS FLOAT) / CAST(totmiem AS FLOAT),
porc_6a15 = CAST(nro_6a15 AS FLOAT) / CAST(totmiem AS FLOAT),
porc_seguro = CAST(nro_tiene_seguro AS FLOAT) / CAST(totmiem AS FLOAT),
lndormitorios_pc = LOG(CAST(nro_dormitorios AS FLOAT) / CAST(totmiem AS FLOAT))
GO

--ESTABLECE LINEAS DE POBREZA MONETARIA
ALTER TABLE #tabla_final
ADD lpobtot_rural FLOAT NULL,
lpobext_rural FLOAT NULL
GO

UPDATE #tabla_final
SET lpobtot_rural = 13.09099,
lpobext_rural = 12.67169
GO

--APLICA EL PMT RURAL
ALTER TABLE #tabla_final
ADD lninc_est FLOAT NULL
GO

DECLARE @w_jefe_guarani  AS FLOAT = -0.1176130
DECLARE @w_jefe_estudios AS FLOAT = 0.0105849
DECLARE @w_jefe_casdiv   AS FLOAT = -0.0596137
DECLARE @w_jefe_emp1     AS FLOAT = -0.2298794
DECLARE @w_jefe_emp2	 AS FLOAT = -0.2118749
DECLARE @w_jefe_emp4     AS FLOAT = -0.4626754
DECLARE @w_jefe_emp5  	 AS FLOAT = -0.5527262
DECLARE @w_jefe_emp6  	 AS FLOAT = -0.3388328
DECLARE @w_jefe_emp7  	 AS FLOAT = -0.2823733
DECLARE @w_m5menos		 AS FLOAT = -0.4020733
DECLARE @w_m6a15 		 AS FLOAT = -0.2563933
DECLARE @w_trabajan		 AS FLOAT =  0.7385175
DECLARE @w_mseguro		 AS FLOAT =  0.3207612
DECLARE @w_totmiem		 AS FLOAT = -0.0304550
DECLARE @w_lndorms_pc	 AS FLOAT =  0.0895221
DECLARE @w_tipohogar	 AS FLOAT =  0.2337155
DECLARE @w_auto_camion   AS FLOAT =  0.2058292
DECLARE @w_cocina_gas	 AS FLOAT =  0.0867773
DECLARE @w_cocina_el	 AS FLOAT =  0.0958024
DECLARE @w_heladera		 AS FLOAT =  0.1025391
DECLARE @w_microondas    AS FLOAT =  0.1849850
DECLARE @w_aire_acon     AS FLOAT =  0.2227899
DECLARE @w_computadora	 AS FLOAT =  0.1360068
DECLARE @w_comb1		 AS FLOAT =  0.1791524
DECLARE @w_comb2		 AS FLOAT =  0.1384622
DECLARE @w_desague1		 AS FLOAT =  0.1093759
DECLARE @w_desague2		 AS FLOAT =  0.1208758
DECLARE @w_aguaprov1	 AS FLOAT =  0.2307234
DECLARE @constante       AS FLOAT = 13.3115000
UPDATE #tabla_final
SET lninc_est = @constante + jefe_guarani*@w_jefe_guarani + jefe_anios_estudio*@w_jefe_estudios + jefe_casdiv*@w_jefe_casdiv +
                jefe_emp_1*@w_jefe_emp1 + jefe_emp_2*@w_jefe_emp2 + jefe_emp_4*@w_jefe_emp4 + jefe_emp_5*@w_jefe_emp5 +
				jefe_emp_6*@w_jefe_emp6 + jefe_emp_7*@w_jefe_emp7 + porc_5menos*@w_m5menos + porc_6a15*@w_m6a15 + porc_trabajan*@w_trabajan +
				porc_seguro*@w_mseguro  + totmiem*@w_totmiem + lndormitorios_pc*@w_lndorms_pc + tipo_hogar1*@w_tipohogar +
				tiene_auto_camion*@w_auto_camion + tiene_cocina_gas*@w_cocina_gas + tiene_cocina_elec*@w_cocina_el +
		        tiene_heladera*@w_heladera + tiene_horno_microondas*@w_microondas + tiene_acondicionador_aire*@w_aire_acon +
				tiene_computadora*@w_computadora + comb1*@w_comb1 + comb2*@w_comb2 + @w_desague1*desague_cat1 + @w_desague2*desague_cat2 +
				agua_proveedor_cat1*@w_aguaprov1
GO

ALTER TABLE #tabla_final
ADD status_pobreza INT NULL,
status_pobreza_et VARCHAR(25) NULL
GO

UPDATE #tabla_final
SET status_pobreza = CASE
WHEN lninc_est <= lpobext_rural THEN 1
WHEN lninc_est > lpobext_rural AND lninc_est <= lpobtot_rural THEN 2
WHEN lninc_est > lpobtot_rural THEN 3 END,
status_pobreza_et = CASE
WHEN lninc_est <= lpobext_rural THEN 'pobre extremo'
WHEN lninc_est > lpobext_rural  AND lninc_est <= lpobtot_rural THEN 'pobre no extremo'
WHEN lninc_est > lpobtot_rural THEN 'no pobre monetario' END
GO

--GENERA TABLA FINAL PARA DOMINIO RURAL
IF OBJECT_ID('PMT_RURAL') IS NOT NULL
BEGIN
    DROP TABLE PMT_RURAL
END
GO

SELECT * INTO PMT_RURAL
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
