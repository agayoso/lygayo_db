USE RSH
GO

IF OBJECT_ID('tempdb..#ICV') IS NOT NULL
BEGIN
    DROP TABLE #ICV
END
GO

SELECT IPM.formulario, IPM.dominio, IPM.dpto, IPM.area, PMT.status_pobreza, PMT.status_pobreza_et, IPM.pobre_multid
INTO #ICV
FROM IPM
LEFT JOIN
(SELECT formulario, dominio, dpto, area, status_pobreza, status_pobreza_et FROM PMT_RURAL
UNION
SELECT formulario, dominio, dpto, area, status_pobreza, status_pobreza_et FROM PMT_URBANO
UNION
SELECT formulario, dominio, dpto, area, status_pobreza, status_pobreza_et FROM PMT_METROPOLITANO) PMT
ON PMT.formulario = IPM.formulario AND PMT.dominio = IPM.dominio
AND PMT.dpto = IPM.dpto AND PMT.area = IPM.area
GO

ALTER TABLE #ICV
ADD pobreza_cat INT NULL,
pobreza_cat_et VARCHAR(50) NULL
GO

--IDENTIFICA RANGOS DEL ICV
UPDATE #ICV
SET pobreza_cat = CASE WHEN (status_pobreza=3 AND pobre_multid=0) THEN 1
WHEN (status_pobreza=3 AND pobre_multid=1) THEN 2
WHEN (status_pobreza=2 AND pobre_multid=0) THEN 3
WHEN (status_pobreza=2 AND pobre_multid=1) THEN 4
WHEN (status_pobreza=1 AND pobre_multid=0) THEN 5
WHEN (status_pobreza=1 AND pobre_multid=1) THEN 6
ELSE NULL
END
GO

UPDATE #ICV
SET pobreza_cat_et = CASE WHEN (status_pobreza=3 AND pobre_multid=0) THEN 'no pobre multid./no pobre monetario'
WHEN (status_pobreza=3 AND pobre_multid=1) THEN 'pobre multid./no pobre mon.'
WHEN (status_pobreza=2 AND pobre_multid=0) THEN 'no pobre multid./ pobre mon.'
WHEN (status_pobreza=2 AND pobre_multid=1) THEN 'pobre multid./pobre mon.'
WHEN (status_pobreza=1 AND pobre_multid=0) THEN 'no pobre mult./pobre extr. mon.'
WHEN (status_pobreza=1 AND pobre_multid=1) THEN 'pobre multid./pobre extr. mon.'
ELSE NULL
END
GO

IF OBJECT_ID('ICV_RANGO') IS NOT NULL
BEGIN
    DROP TABLE ICV_RANGO
END
GO

SELECT *
INTO ICV_RANGO
FROM #ICV
GO

IF OBJECT_ID('tempdb..#ICV') IS NOT NULL
BEGIN
    DROP TABLE #ICV
END
GO

