USE RSH
GO

ALTER TABLE RSH_BASE
ADD horabco FLOAT NULL
GO

UPDATE RSH_BASE
SET horabco = CASE
    WHEN b04 IS NULL AND b02a IS NULL AND b02b IS NULL AND b02c IS NULL AND b02d IS NULL AND b02e IS NULL AND b02f IS NULL
		AND b02g IS NULL AND c01 IS NULL AND c03 IS NULL THEN NULL
	WHEN c03 IS NULL AND (b04 != 0 OR b04 IS NOT NULL) THEN b04+(ISNULL(c01,0))
	WHEN c03 IS NOT NULL AND (b04 != 0 OR b04 IS NOT NULL) THEN b04+(ISNULL(c03,0))
    WHEN c03 IS NULL AND (b04 = 0 OR b04 IS NULL) THEN
		ISNULL(b02a,0)+ISNULL(b02b,0)+ISNULL(b02c,0)+ISNULL(b02d,0)+ISNULL(b02e,0)+ISNULL(b02f,0)+ISNULL(b02g,0)+(ISNULL(c01,0))
    WHEN c03 IS NOT NULL AND (b04 = 0 OR b04 IS NULL) THEN
		ISNULL(b02a,0)+ISNULL(b02b,0)+ISNULL(b02c,0)+ISNULL(b02d,0)+ISNULL(b02e,0)+ISNULL(b02f,0)+ISNULL(b02g,0)+(ISNULL(c03,0))
END
GO

UPDATE RSH_BASE
SET horabco = CASE
WHEN c08 IS NOT NULL THEN horabco + c08
WHEN c08 IS NULL AND c06 IS NOT NULL THEN horabco + c06
ELSE horabco
END
GO

UPDATE RSH_BASE
SET horabco = 999
WHERE b04 = 999 OR c01 = 999 OR c03 = 999
GO



