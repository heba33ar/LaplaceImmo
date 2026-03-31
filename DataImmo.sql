-- ============================================================
-- DataImmo - Création des tables
-- Ordre obligatoire (respecter les clés étrangères) :
--   1. region
--   2. commune
--   3. bien_immo
--   4. vente
-- ============================================================

CREATE TABLE region (
    id_region  INTEGER     PRIMARY KEY NOT NULL,
    nom_region VARCHAR(50) NOT NULL
);

CREATE TABLE commune (
    id_codedep_codecommune VARCHAR(10) PRIMARY KEY NOT NULL,
    Code_departement       VARCHAR(3)  NOT NULL,
    Commune                VARCHAR(50) NOT NULL,
    id_region              INTEGER     NOT NULL,
    FOREIGN KEY (id_region) REFERENCES region(id_region)
);

CREATE TABLE bien_immo (
    Id_bien                INTEGER     PRIMARY KEY NOT NULL,
    id_codedep_codecommune VARCHAR(10) NOT NULL,
    Surface                FLOAT,
    Type_local             VARCHAR(50),
    Total_piece            INTEGER,
    FOREIGN KEY (id_codedep_codecommune) REFERENCES commune(id_codedep_codecommune)
);

CREATE TABLE vente (
    Id_vente        INTEGER PRIMARY KEY NOT NULL,
    Date_vente      DATE    NOT NULL,
    Valeur_fonciere FLOAT,
    Id_bien         INTEGER NOT NULL,
    FOREIGN KEY (Id_bien) REFERENCES bien_immo(Id_bien)
);
