--CREA LA BASE DE DATOS  (activar 1 y 2 solo en el primer uso)
--1: CREATE DATABASE RSH
--2: GO

USE RSH
GO

--CREA TABLA RSH BASE
IF OBJECT_ID('RSH_BASE') IS NOT NULL
BEGIN
    DROP TABLE RSH_BASE
END
GO

CREATE TABLE RSH_BASE (
    hhid INT NULL,
    upm INT NULL,
    nvivi INT NULL,
    nhoga INT NULL,
    dpto INT NULL,
    area INT NULL,
    anio INT NULL,
    fex_2022 FLOAT NULL,
    facpob FLOAT NULL,
    dominio INT NULL,
    ipcm FLOAT NULL,
    lnipcm FLOAT NULL,
    tipo_empleo VARCHAR(50) NULL,
    tipo_vivienda VARCHAR(50) NULL,
    tipo_pared VARCHAR(50) NULL,
    tipo_piso VARCHAR(50) NULL,
    tipo_techo VARCHAR(50) NULL,
    tipo_agua_proveedor VARCHAR(50) NULL,
    tipo_agua_vivienda VARCHAR(50) NULL,
    tipo_agua_proveedor_beber VARCHAR(50) NULL,
    tipo_agua_fuente_beber VARCHAR(50) NULL,
    tipo_banho_desague VARCHAR(50) NULL,
    tipo_combustible VARCHAR(50) NULL,
    tipo_basura VARCHAR(50) NULL,
    tipo_vivienda_propiedad VARCHAR(50) NULL,
    tipo_hogar VARCHAR(50) NULL,
    tiene_agua_24hrs BIT NULL,
    tiene_luz_electrica BIT NULL,
    tiene_linea_fija BIT NULL,
    tiene_celular BIT NULL,
    tiene_banho BIT NULL,
    tiene_computadora BIT NULL,
    tiene_tableta BIT NULL,
    tiene_internet BIT NULL,
    tiene_internet_cablewifi BIT NULL,
    tiene_internet_modem BIT NULL,
    tiene_radio BIT NULL,
    tiene_televisor BIT NULL,
    tiene_heladera BIT NULL,
    tiene_cocina_gas BIT NULL,
    tiene_cocina_elec BIT NULL,
    tiene_lavarropas BIT NULL,
    tiene_videoDVD BIT NULL,
    tiene_termocalefon BIT NULL,
    tiene_acondicionador_aire BIT NULL,
    tiene_antena_parabolica BIT NULL,
    tiene_tv_cable BIT NULL,
    tiene_horno_microondas BIT NULL,
    tiene_horno_electrico BIT NULL,
    tiene_auto_camion BIT NULL,
    tiene_motocicleta BIT NULL,
    tiene_seguro BIT NULL,
    jefe VARCHAR(100) NULL,
    jefe_edad INT NULL,
    jefe_anios_estudio INT NULL,
    jefe_idioma VARCHAR(50) NULL,
    jefe_tipo_empleo VARCHAR(50) NULL,
    jefe_estado_civil VARCHAR(50) NULL,
    jefe_tiene_seguro BIT NULL,
    nro_dormitorios INT NULL,
    nro_trabajo INT NULL,
    nro_5menos INT NULL,
    nro_6a14 INT NULL,
    nro_tiene_seguro INT NULL,
    totpers INT NULL,
    linea_pobreza_total FLOAT NULL,
    linea_pobreza_extrema FLOAT NULL,
    pobrezai BIT NULL,
    pobnopoi BIT NULL,
    pob_total FLOAT NULL,
    pob_ext FLOAT NULL,
    ipcm_median FLOAT NULL
);
GO

--INSERTA DATOS (CAMBIAR DIRECTORIO)
BULK INSERT RSH_BASE
FROM 'C:/Users/lylig/Documents/Consultorias/2019/UNDP/PMT/Archivos Contrato 2/IPM_PMT_base_2022_cleaned_vars.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2
);
GO


