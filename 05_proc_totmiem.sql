USE RSH
GO

ALTER TABLE RSH_BASE
ADD totmiem INT NULL
GO

UPDATE RSH_BASE
SET RSH_BASE.totmiem = miembros.totmiem
FROM
(SELECT formulario, COUNT(*) totmiem
FROM RSH_BASE
WHERE (CASE WHEN p04=11 OR p04=12 THEN 1 ELSE 0 END) <> 1
GROUP BY formulario) miembros
WHERE RSH_BASE.formulario = miembros.formulario
GO



