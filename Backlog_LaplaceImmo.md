# 📋 Backlog Projet DataImmo — Laplace Immo

> **Contexte :** Tu es Data Engineer chez Laplace Immo, un réseau national d'agences immobilières. L'objectif est de construire une base de données des transactions immobilières en France (POC), d'analyser le marché et de répondre aux besoins de l'agence via des requêtes SQL.

---

## 🗂️ Fichiers disponibles dans `/LaplaceImmo`

| Fichier | Contenu |
|---|---|
| `dataset_quiz_p2.xlsx` | 3 feuilles : `bien_immo` (1107 lignes, 14 col.), `transaction` (1047 lignes, 3 col.), `indice_insee` (1108 lignes, 2 col.) |
| `Template_dico_données.xlsx` | Dictionnaire des données à compléter (3 feuilles vides/partielles) |

### Structure des données connues

**bien_immo** : `id_bien`, `valeur_fonciere_actuelle`, `no_voie`, `bis_ter_quater`, `type_de_voie`, `code_voie`, `voie`, `code_postal`, `commune`, `code_departement`, `code_commune`, `surface`, `type`, `nb_pieces`

**transaction** : `date_vente`, `valeur_fonciere`, `bien_immobilier` (FK vers id_bien)

**indice_insee** : `date`, `indice_prix_logement`

---

## ✅ PARTIE 1 — Comprendre les données & créer le schéma relationnel

### Story 1.1 — Explorer et comprendre les données
- [ ] Ouvrir `dataset_quiz_p2.xlsx` (Google Sheet ou Excel)
- [ ] Parcourir chaque colonne et noter le type de données réel (entier, texte, date, float…)
- [ ] Repérer les cas particuliers : codes postaux au format texte, départements "2A"/"2B" de Corse, valeurs nulles
- [ ] Identifier les colonnes RGPD-sensibles à exclure ou anonymiser
- [ ] Décider quelles colonnes conserver pour répondre aux besoins métier

**Points de vigilance :**
- `code_postal` semble stocké en Float → à traiter en Varchar
- `code_departement` peut valoir "2A" ou "2B" → Varchar, pas Integer
- `code_voie` (numéro de voie cadastral) peut être redondant avec d'autres colonnes

---

### Story 1.2 — Compléter le dictionnaire des données
Remplir les 3 feuilles du template (colonnes : CODE, SIGNIFICATION, TYPE, LONGUEUR, NATURE, RÈGLE DE GESTION, RÈGLE DE CALCUL) :

**Feuille 1 — Valeurs foncières (bien_immo + transaction)**

| CODE | SIGNIFICATION | TYPE | LONGUEUR | NATURE | RÈGLE DE GESTION | RÈGLE DE CALCUL |
|---|---|---|---|---|---|---|
| id_bien | ID du bien immobilier | Integer | NC | Élémentaire | NOT NULL, unique | Auto-incrément |
| no_voie | Numéro de rue | Integer | NC | Élémentaire | - | - |
| bis_ter_quater | Complément numéro (bis, ter…) | Varchar | 10 | Élémentaire | - | - |
| type_de_voie | Type de voie (RUE, ALL, BD…) | Varchar | 4 | Élémentaire | - | - |
| voie | Nom de la voie | Varchar | 50 | Élémentaire | - | - |
| code_postal | Code postal | Varchar | 10 | Élémentaire | - | - |
| surface | Surface en m² | Float | NC | Élémentaire | > 0 | - |
| type | Type de bien (Appartement, Maison…) | Varchar | 20 | Élémentaire | - | - |
| nb_pieces | Nombre de pièces | Integer | NC | Élémentaire | ≥ 1 | - |
| id_vente | ID de la transaction | Integer | NC | Élémentaire | NOT NULL, unique | Auto-incrément |
| date_vente | Date de la vente | Date | NC | Élémentaire | Format JJ/MM/AAAA | - |
| valeur_fonciere | Prix de vente en € | Float | NC | Élémentaire | > 0 | - |

**Feuille 2 — Référentiel géographique (commune / région)**

| CODE | SIGNIFICATION | TYPE | LONGUEUR | NATURE | RÈGLE DE GESTION | RÈGLE DE CALCUL |
|---|---|---|---|---|---|---|
| id_codedep_codecommune | Clé unique commune | Varchar | 10 | Concaténé | NOT NULL, unique | code_departement + code_commune |
| code_departement | Code du département | Varchar | 3 | Élémentaire | - | - |
| code_commune | Code INSEE de la commune | Varchar | 5 | Élémentaire | - | - |
| commune | Nom de la commune | Varchar | 50 | Élémentaire | - | - |
| id_region | ID de la région | Integer | NC | Élémentaire | FK → region | - |

**Feuille 3 — Données communes (indice_insee)**

| CODE | SIGNIFICATION | TYPE | LONGUEUR | NATURE | RÈGLE DE GESTION | RÈGLE DE CALCUL |
|---|---|---|---|---|---|---|
| id_indice | ID de l'indice | Integer | NC | Élémentaire | NOT NULL, unique | Auto-incrément |
| date | Date de l'indice | Date | NC | Élémentaire | Format JJ/MM/AAAA | - |
| indice_prix_logement | Indice INSEE des prix du logement | Float | NC | Élémentaire | > 0 | - |

---

### Story 1.3 — Créer le schéma relationnel normalisé (Draw.io)
- [ ] Créer les 5 tables suivantes en respectant la 3NF :
  - `bien_immo` (PK: id_bien, FK: id_codedep_codecommune)
  - `transaction` / `vente` (PK: id_vente, FK: id_bien)
  - `commune` (PK: id_codedep_codecommune = code_dep + code_commune, FK: id_region)
  - `region` (PK: id_region)
  - `indice_insee` (PK: id_indice)
- [ ] Tracer les relations entre tables (1→N) avec clés étrangères
- [ ] Justifier le choix de chaque clé primaire
- [ ] Exporter une capture du schéma pour le support de présentation

**Rappel règles normales à respecter :**
- 1NF : données atomiques (ex: adresse découpée en no_voie / type_de_voie / voie / code_postal)
- 2NF : chaque attribut non-clé dépend de toute la clé primaire
- 3NF : aucune dépendance transitive (commune → département → région séparés)

---

## ✅ PARTIE 2 — Créer la BDD et charger les données

### Story 2.1 — Créer la base de données
- [ ] Choisir un SGBD : **SQLite Studio** (recommandé débutant), ou PostgreSQL / MySQL
- [ ] Créer une nouvelle base de données nommée `DataImmo`
- [ ] Créer les tables dans l'ordre suivant (respecter les FK) :
  1. `region`
  2. `commune`
  3. `bien_immo`
  4. `transaction` (ou `vente`)
  5. `indice_insee`
- [ ] Vérifier que les types de colonnes correspondent au dictionnaire des données

**Code SQL de création (exemple pour bien_immo) :**
```sql
CREATE TABLE bien_immo (
    id_bien INTEGER PRIMARY KEY,
    no_voie INTEGER,
    bis_ter_quater VARCHAR(10),
    type_de_voie VARCHAR(4),
    voie VARCHAR(50),
    code_postal VARCHAR(10),
    surface FLOAT,
    type VARCHAR(20),
    nb_pieces INTEGER,
    id_codedep_codecommune VARCHAR(10),
    FOREIGN KEY (id_codedep_codecommune) REFERENCES commune(id_codedep_codecommune)
);
```

---

### Story 2.2 — Préparer les fichiers CSV
- [ ] Créer un CSV par table (avec colonnes dans le même ordre que la BDD)
- [ ] Pour `commune` : concaténer `code_departement` + `code_commune` → `id_codedep_codecommune` (ex: "34" + "172" = "34172")
- [ ] Pour `vente` : ajouter une colonne `id_vente` auto-incrémentée
- [ ] Pour `indice_insee` : ajouter `id_indice` auto-incrémenté, supprimer la colonne vide
- [ ] Vérifier l'unicité des clés primaires dans chaque CSV (pas de doublons)
- [ ] Gérer les cas spéciaux Corse (2A, 2B) → format Varchar

---

### Story 2.3 — Charger les données et vérifier
- [ ] Importer chaque CSV dans sa table correspondante
- [ ] Vérifier : **nb lignes CSV = nb lignes BDD** (total CSV - 1 pour l'en-tête = nb lignes BDD)
- [ ] Contrôler l'intégrité référentielle (pas de FK orphelines)
- [ ] Faire une capture d'écran de la BDD avec tables et données chargées

---

## ✅ PARTIE 3 — Requêtes SQL et support de présentation

### Story 3.1 — Écrire les requêtes SQL (besoins du compte-rendu de réunion)
> ⚠️ Les besoins exacts sont dans le compte-rendu de réunion à télécharger sur OpenClassrooms.
> Voici les exemples mentionnés dans l'exercice :

- [ ] **Besoin 1** : Nombre total de transactions (à compléter selon CR)
- [ ] **Besoin 2** : Nombre de ventes d'appartement par région pour le 1er semestre
  ```sql
  -- Exemple de structure attendue
  SELECT r.nom_region, COUNT(*) AS nb_ventes
  FROM vente v
  JOIN bien_immo b ON v.id_bien = b.id_bien
  JOIN commune c ON b.id_codedep_codecommune = c.id_codedep_codecommune
  JOIN region r ON c.id_region = r.id_region
  WHERE b.type = 'Appartement'
    AND strftime('%m', v.date_vente) BETWEEN '01' AND '06'
  GROUP BY r.nom_region;
  ```
- [ ] **Autres besoins** : À compléter en lisant le compte-rendu de réunion

**Bonnes pratiques SQL :**
- Utiliser des alias pour la lisibilité (`AS`)
- Utiliser des sous-requêtes ou tables temporaires si nécessaire
- Sauvegarder chaque requête qui fonctionne + son résultat

---

### Story 3.2 — Préparer le support de présentation (GSlides / PowerPoint)
Le support doit contenir (dans l'ordre) :
- [ ] Contexte du projet (Laplace Immo, objectif POC, rôle Data Engineer)
- [ ] Transformation des données (quelles colonnes gardées/exclues et pourquoi)
- [ ] Extrait du dictionnaire des données
- [ ] Schéma relationnel normalisé (capture Draw.io)
- [ ] Capture d'écran de la BDD avec tables créées et données chargées
- [ ] Code SQL de chaque requête + résultat + commentaire analytique

---

## 📦 LIVRABLES FINAUX

| # | Livrable | Format | Nommage |
|---|---|---|---|
| 1 | Dictionnaire des données complété | Excel / Google Sheet | `Nom_Prenom_1_dictionnaire_mmaaaa` |
| 2 | Support de présentation | GSlides / PowerPoint | `Nom_Prenom_2_support_mmaaaa` |

> Zipper les deux dans un dossier : `Titre_du_projet_nom_prenom.zip`

---

## 📚 Ressources utiles
- Cours modélisation BDD : OpenClassrooms "Modélisez vos bases de données"
- Cours SQL : OpenClassrooms "Requêtez une base de données avec SQL" (Parties 2 & 3)
- Outil schéma : **Draw.io** (diagrams.net) ou SQL Power Architect
- Référence SQL : sql.sh
- Import CSV MySQL/PostgreSQL : procédure sur OpenClassrooms
