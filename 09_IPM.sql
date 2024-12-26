USE RSH
GO

IF OBJECT_ID('tempdb..#IPM') IS NOT NULL
BEGIN
    DROP TABLE #IPM
END
GO

SELECT formulario,
area,
dpto,
CASE
	WHEN (dpto = 0 OR dpto = 11) AND area = 1 THEN 0
	WHEN area = 6 THEN 6
	WHEN area = 1 THEN 1
END AS dominio,
p09,
peaa,
horabco,
d01,
d02,
b05,
c04,
ed01,
ed02,
ed04,
v02,
v03,
v04,
totmiem,
v01b,
v13,
s02,
s04,
s03,
s05,
v05,
v10,
v11,
v12b,
ed05,
ed03,
a�oest,
e01,
e02,
e04
INTO #IPM
FROM RSH_BASE
WHERE p05 = 1 AND p04 < 11
GO

ALTER TABLE #IPM
ADD
priv_pens_cont INT NULL,
priv_no_cont INT NULL,
priv_pension INT NULL,
adulto_65ymas INT NULL,
sin_atencion_med INT NULL,
actualmente_escuela INT NULL,
edad_escolar INT NULL,
ni_noasis INT NULL,
miembro_eleg INT NULL,
escolarizacion_retardada INT NULL,
logro INT NULL,
miembro_18a64_des INT NULL,
subocvi40 INT NULL,
miembro_sub INT NULL,
trabajo_ninho INT NULL,
aporta INT NULL,
miembro_65ymas_priv INT NULL,
hh_pared INT NULL,
hh_piso INT NULL,
hh_techo INT NULL,
hh_basura INT NULL,
hh_agua INT NULL,
hh_saneamiento INT NULL,
hh_combustible INT NULL,
hh_material_viv INT NULL
GO

UPDATE #IPM
SET priv_pens_cont = CASE WHEN (e01=6) THEN 1 ELSE 0 END
WHERE p09>=65
GO

UPDATE #IPM
SET priv_no_cont = CASE WHEN (e02=6 AND e04=6) THEN 1 ELSE 0 END
WHERE p09>=65
GO

UPDATE #IPM
SET priv_pension = CASE WHEN (priv_pens_cont=1 AND priv_no_cont=1) THEN 1 ELSE 0 END
WHERE p09>=65
GO

UPDATE #IPM
SET adulto_65ymas = CASE WHEN (p09>=65) THEN 1 ELSE 0 END
GO

UPDATE #IPM
SET sin_atencion_med = CASE WHEN ((s02=1 OR s02=2) AND (s04=2 OR s04=3 OR s04=4 OR s04=5) OR (s03=1 AND (s05=3 OR s05=6 OR s05=7 OR s05=8 OR s05=9))) THEN 1 ELSE 0 END
WHERE S02 <> 9 AND S02 IS NOT NULL
GO

UPDATE #IPM
SET actualmente_escuela = CASE WHEN (ed05<19) THEN 1 ELSE 0 END
WHERE ed05 IS NOT NULL
GO

UPDATE #IPM
SET actualmente_escuela = 0
WHERE ed03=6
GO

UPDATE #IPM
SET edad_escolar = CASE WHEN (p09>=6 AND p09<=17) THEN 1 ELSE 0 END
GO

UPDATE #IPM
SET ni_noasis = CASE WHEN (actualmente_escuela=0) THEN 1 ELSE 0 END
WHERE edad_escolar = 1
GO

UPDATE #IPM
SET miembro_eleg = CASE WHEN ((p09>=8 AND p09<=19) AND (actualmente_escuela=1 AND a�oest<=12)) THEN 1 ELSE 0 END
GO

UPDATE #IPM
SET escolarizacion_retardada = CASE WHEN ((p09-a�oest)>= 8) THEN 1 ELSE 0 END
WHERE p09 IS NOT NULL AND a�oest IS NOT NULL AND miembro_eleg=1
GO

UPDATE #IPM
SET logro = CASE WHEN (a�oest<12) THEN 1 ELSE 0 END
WHERE p09>=18 AND p09<=21 AND a�oest<>99 AND a�oest IS NOT NULL
GO

UPDATE #IPM
SET logro = CASE WHEN (a�oest<9) THEN 1 ELSE 0 END
WHERE p09>=22 AND p09<=29 AND a�oest<>99 AND a�oest IS NOT NULL
GO

UPDATE #IPM
SET logro = CASE WHEN (a�oest<6) THEN 1 ELSE 0 END
WHERE p09>=30 AND p09<=49 AND a�oest<>99 AND a�oest IS NOT NULL
GO

UPDATE #IPM
SET logro = CASE WHEN (ed02=6) THEN 1 ELSE 0 END
WHERE p09>=50 AND p09<66 AND ed02<>9 AND ed02 IS NOT NULL
GO

UPDATE #IPM
SET miembro_18a64_des = CASE WHEN (peaa=2) THEN 1 ELSE 0 END
WHERE (p09>=18 AND p09<=64)
GO

UPDATE #IPM
SET subocvi40 = CASE WHEN (horabco<40 AND ((d01=1) OR ((d01=9) AND (d02>=1 AND d02<=3)))) THEN 1 ELSE 0 END
GO

UPDATE #IPM
SET miembro_sub = CASE WHEN (subocvi40=1) THEN 1 ELSE 0 END
WHERE (p09>=18 AND p09<=64)
GO

UPDATE #IPM
SET miembro_sub = 0
WHERE (p09<18 OR p09>64)
GO

UPDATE #IPM
SET trabajo_ninho = 1
WHERE (p09>=10 AND p09<=13) AND peaa=1
GO

UPDATE #IPM
SET trabajo_ninho = 1
WHERE (p09>=14 AND p09<=15) AND (horabco>24 AND horabco IS NOT NULL)
GO

UPDATE #IPM
SET trabajo_ninho = 1
WHERE (p09>=16 AND p09<=17) AND (horabco>36 AND horabco IS NOT NULL)
GO

UPDATE #IPM
SET trabajo_ninho = 0
WHERE trabajo_ninho IS NULL
GO

UPDATE #IPM
SET aporta = CASE WHEN (b05=1 OR c04=1) THEN 1 ELSE 0 END
WHERE (p09>= 18 AND p09<=64) AND peaa=1
GO

UPDATE #IPM
SET miembro_65ymas_priv = CASE WHEN (p09>=65 AND priv_pension=1) THEN 1 ELSE 0 END
GO

UPDATE #IPM
SET hh_pared = CASE WHEN (v02=1 OR v02=2 OR v02=6 OR v02=7 OR v02=8 OR v02=9) THEN 1 ELSE 0 END
GO

UPDATE #IPM
SET hh_piso = CASE WHEN (v03=1) THEN 1 ELSE 0 END
GO

UPDATE #IPM
SET hh_techo = CASE WHEN (v04=2 OR v04=7 OR v04=8 OR v04=9) THEN 1 ELSE 0 END
GO

UPDATE #IPM
SET hh_material_viv = CASE WHEN (hh_pared=1 OR hh_piso=1 OR hh_techo=1) THEN 1 ELSE 0 END
GO

UPDATE #IPM
SET hh_material_viv = NULL
WHERE v02 IS NULL AND v03 IS NULL AND v04 IS NULL
GO

UPDATE #IPM
SET hh_basura = CASE WHEN (v13=1 OR v13=4 OR v13=5 OR v13=7 OR v13=8 OR v13=9) THEN 1 ELSE 0 END
GO

UPDATE #IPM
SET hh_basura = NULL
WHERE v13 IS NULL
GO

UPDATE #IPM
SET hh_agua = CASE WHEN (v05<>1 AND v05<>2 AND v05<>3 AND v05<>4 AND v05<>5) THEN 1 ELSE 0 END
GO

UPDATE #IPM
SET hh_agua = NULL
WHERE v05=99 OR v05 IS NULL
GO

UPDATE #IPM
SET hh_saneamiento = CASE WHEN (v10=6 OR (v11<>1 AND v11<>2 AND v11<>3)) THEN 1 ELSE 0 END
GO

UPDATE #IPM
SET hh_saneamiento = NULL
WHERE v10 IS NULL AND (v11 IS NULL OR v11=9)
GO

UPDATE #IPM
SET hh_combustible = CASE WHEN (v12b=1 OR v12b=3) THEN 1 ELSE 0 END
GO

UPDATE #IPM
SET hh_combustible = NULL
WHERE v12b=9 OR v12b IS NULL
GO

--DEMOGRAFIA Y CARACTERISTICAS DEL HOGAR
IF OBJECT_ID('tempdb..#demoghogar_tabla') IS NOT NULL
BEGIN
    DROP TABLE #demoghogar_tabla
END
GO

SELECT formulario, dominio, dpto, area,
SUM(miembro_18a64_des) hh_desocupacion,
SUM(miembro_sub) hh_subocupados,
SUM(trabajo_ninho) hh_trabajo_ninhos,
SUM(CASE WHEN (aporta=0) THEN 1 ELSE 0 END) hh_no_aportan,
SUM(miembro_65ymas_priv) hh_65ymas_priv,
SUM(sin_atencion_med) hh_sin_atencion_med,
MAX(edad_escolar) hh_edad_escolar,
MAX(ni_noasis) hh_d_ni_noasis,
SUM(miembro_eleg) hh_miembros_eleg,
MAX(escolarizacion_retardada) hh_escolarizacion_retardada,
MIN(logro) hh_d_logro_min,
AVG(hh_pared) hh_pared,
AVG(hh_piso) hh_piso,
AVG(hh_techo) hh_techo,
AVG(hh_material_viv) hh_material_viv,
AVG(totmiem) totmiem,
AVG(v01b) dormitorios,
AVG(hh_basura) hh_basura,
AVG(hh_agua) hh_agua,
AVG(hh_saneamiento) hh_saneamiento,
AVG(hh_combustible) hh_combustible
INTO #demoghogar_tabla
FROM #IPM
GROUP BY formulario, dominio, dpto, area

ALTER TABLE #demoghogar_tabla
ADD
ip_desocupacion INT NULL,
ip_subocupacion INT NULL,
ip_trabajo_ninhos INT NULL,
ip_seguridad_social INT NULL,
ip_jubilacion INT NULL,
ip_material_vivienda INT NULL,
ip_hacinamiento INT NULL,
ip_basura INT NULL,
ip_atencion_medica INT NULL,
ip_agua_mejorada INT NULL,
ip_saneamiento INT NULL,
ip_comb_combustible INT NULL,
ip_asistencia_escolar INT NULL,
ip_escolarizacion INT NULL,
ip_logro_educativo INT NULL
GO

UPDATE #demoghogar_tabla
SET ip_desocupacion = CASE WHEN (hh_desocupacion>0) THEN 1 ELSE 0 END
GO

UPDATE #demoghogar_tabla
SET ip_subocupacion = CASE WHEN (hh_subocupados>0) THEN 1 ELSE 0 END
GO

UPDATE #demoghogar_tabla
SET ip_trabajo_ninhos = CASE WHEN (hh_trabajo_ninhos>0) THEN 1 ELSE 0 END
GO

UPDATE #demoghogar_tabla
SET ip_seguridad_social = CASE WHEN (hh_no_aportan>0) THEN 1 ELSE 0 END
GO

UPDATE #demoghogar_tabla
SET ip_jubilacion = CASE WHEN (hh_65ymas_priv>0) THEN 1 ELSE 0 END
GO

UPDATE #demoghogar_tabla
SET ip_material_vivienda = CASE WHEN (hh_material_viv=1) THEN 1 ELSE 0 END
GO

UPDATE #demoghogar_tabla
SET ip_material_vivienda = NULL
WHERE hh_material_viv IS NULL
GO

UPDATE #demoghogar_tabla
SET ip_hacinamiento = CASE WHEN (CAST(totmiem AS FLOAT)/CAST(dormitorios AS FLOAT)>=3) THEN 1 ELSE 0 END
WHERE CAST(totmiem AS FLOAT)/CAST(dormitorios AS FLOAT) IS NOT NULL
GO

UPDATE #demoghogar_tabla
SET ip_hacinamiento = 0
WHERE CAST(totmiem AS FLOAT)/CAST(dormitorios AS FLOAT) <3
GO

UPDATE #demoghogar_tabla
SET ip_basura = CASE WHEN (hh_basura>0) THEN 1 ELSE 0 END
GO

UPDATE #demoghogar_tabla
SET ip_basura = NULL
WHERE hh_basura IS NULL
GO

UPDATE #demoghogar_tabla
SET ip_atencion_medica = CASE WHEN (hh_sin_atencion_med>0) THEN 1 ELSE 0 END
GO

UPDATE #demoghogar_tabla
SET ip_agua_mejorada = CASE WHEN (hh_agua>0) THEN 1 ELSE 0 END
GO

UPDATE #demoghogar_tabla
SET ip_agua_mejorada = NULL
WHERE hh_agua IS NULL
GO

UPDATE #demoghogar_tabla
SET ip_saneamiento = CASE WHEN (hh_saneamiento>0) THEN 1 ELSE 0 END
GO

UPDATE #demoghogar_tabla
SET ip_saneamiento = NULL
WHERE hh_saneamiento IS NULL
GO

UPDATE #demoghogar_tabla
SET ip_comb_combustible = CASE WHEN (hh_combustible>0) THEN 1 ELSE 0 END
GO

UPDATE #demoghogar_tabla
SET ip_comb_combustible = NULL
WHERE hh_combustible IS NULL
GO

UPDATE #demoghogar_tabla
SET ip_asistencia_escolar = CASE WHEN (hh_d_ni_noasis>0) THEN 1 ELSE 0 END
GO

UPDATE #demoghogar_tabla
SET ip_escolarizacion = CASE WHEN (hh_escolarizacion_retardada>0) THEN 1 ELSE 0 END
GO

UPDATE #demoghogar_tabla
SET ip_escolarizacion = 0
WHERE hh_miembros_eleg = 0
GO

UPDATE #demoghogar_tabla
SET hh_d_logro_min = 0
WHERE hh_d_logro_min IS NULL
GO

UPDATE #demoghogar_tabla
SET ip_logro_educativo = CASE WHEN (hh_d_logro_min>0) THEN 1 ELSE 0 END
GO

ALTER TABLE #demoghogar_tabla
ADD
pri_trab FLOAT NULL,
pri_viv FLOAT NULL,
pri_sal FLOAT NULL,
pri_edu FLOAT NULL,
privacion FLOAT NULL,
k FLOAT NULL,
pobre_multid INT NULL,
privacion_censurada FLOAT NULL
GO

UPDATE #demoghogar_tabla
SET pri_trab = (CAST(ip_desocupacion AS FLOAT)+CAST(ip_subocupacion AS FLOAT)+CAST(ip_trabajo_ninhos AS FLOAT)+CAST(ip_seguridad_social AS FLOAT)+CAST(ip_jubilacion AS FLOAT))/5
GO

UPDATE #demoghogar_tabla
SET pri_viv = (CAST(ip_material_vivienda AS FLOAT)+CAST(ip_hacinamiento AS FLOAT)+CAST(ip_basura AS FLOAT))/3
GO

UPDATE #demoghogar_tabla
SET pri_sal = (CAST(ip_atencion_medica AS FLOAT)+CAST(ip_agua_mejorada AS FLOAT)+CAST(ip_saneamiento AS FLOAT)+CAST(ip_comb_combustible AS FLOAT))/4
GO

UPDATE #demoghogar_tabla
SET pri_edu = (CAST(ip_asistencia_escolar AS FLOAT)+CAST(ip_escolarizacion AS FLOAT)+CAST(ip_logro_educativo AS FLOAT))/3
GO

UPDATE #demoghogar_tabla
SET privacion = (CAST(pri_trab AS FLOAT)+CAST(pri_viv AS FLOAT)+CAST(pri_sal AS FLOAT)+CAST(pri_edu AS FLOAT))/4
GO

UPDATE #demoghogar_tabla
SET k = 0.26
GO

UPDATE #demoghogar_tabla
SET pobre_multid = CASE WHEN (privacion>=k) THEN 1 ELSE 0 END
GO

UPDATE #demoghogar_tabla
SET pobre_multid = NULL
WHERE privacion IS NULL
GO

UPDATE #demoghogar_tabla
SET privacion_censurada = privacion*pobre_multid
GO

SELECT *
INTO IPM
FROM #demoghogar_tabla
GO

IF OBJECT_ID('tempdb..#IPM') IS NOT NULL
BEGIN
    DROP TABLE #IPM
END
GO

IF OBJECT_ID('tempdb..#demoghogar_tabla') IS NOT NULL
BEGIN
    DROP TABLE #demoghogar_tabla
END
GO