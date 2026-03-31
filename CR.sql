-- Nombre total d'appartements vendus au 1er semestre 2020
SELECT COUNT(*) AS nb_appartements_vendus
FROM vente v
JOIN bien_immo b ON v.Id_bien = b.Id_bien
WHERE b.Type_local = 'Appartement'
  AND v.Date_vente BETWEEN '2020-01-01' AND '2020-06-30';

-- Nombre de ventes d'appartements par région au 1er semestre 2020
SELECT c.id_region, COUNT(*) AS nb_ventes
FROM vente v
JOIN bien_immo b ON v.Id_bien = b.Id_bien
JOIN commune c ON c.id_codedep_codecommune = b.id_codedep_codecommune
WHERE b.Type_local = 'Appartement'
  AND v.Date_vente BETWEEN '2020-01-01' AND '2020-06-30'
GROUP BY c.id_region;

-- 3. Proportion des ventes d'appartements par le nombre de pièces
SELECT b.Total_piece AS 'nb de pieces', 
   COUNT(*) * 100.0 / (SELECT COUNT(*) FROM bien_immo WHERE Type_local = 'Appartement') AS proportion
FROM bien_immo b, vente v
WHERE b.Id_bien = v.Id_bien
AND b.Type_local = 'Appartement'
GROUP BY b.Total_piece;

-- 4. Liste des 10 départements où le prix du mètre carré est le plus élevé
SELECT c.Code_departement, ROUND(AVG(v.Valeur_fonciere / b.Surface), 2) AS prix_m2
FROM vente v
JOIN bien_immo b ON v.Id_bien = b.Id_bien
JOIN commune c ON c.id_codedep_codecommune = b.id_codedep_codecommune
WHERE b.Surface > 0
GROUP BY c.Code_departement
ORDER BY prix_m2 DESC
LIMIT 10;

-- 5. Prix moyen du mètre carré d'une maison en Île-de-France
SELECT v.Valeur_fonciere,b.Surface, avg(v.Valeur_fonciere/b.Surface)
FROM region r, commune c, vente v, bien_immo b
WHERE r.nom_region = 'Île-de-France'
AND c.id_region = r.id_region
AND c.id_codedep_codecommune = b.id_codedep_codecommune
AND v.Id_bien = b.Id_bien
AND b.Type_local = 'Maison';

-- 6. Liste des 10 appartements les plus chers avec la région et le nombre de mètres carrés
SELECT r.nom_region,b.Surface, avg(v.Valeur_fonciere) as prix_moy
FROM region r, commune c, vente v, bien_immo b
WHERE r.nom_region = 'Île-de-France'
AND c.id_region = r.id_region
AND c.id_codedep_codecommune = b.id_codedep_codecommune
AND v.Id_bien = b.Id_bien
AND b.Type_local = 'Appartement'
GROUP BY b.Id_bien
ORDER BY prix_moy DESC
LIMIT 10;

-- 7. Taux d'évolution du nombre de ventes entre le 1er et le 2ème trimestre 2020
WITH premTri AS(
SELECT COUNT(*) as total1
FROM vente v
WHERE v.Date_vente BETWEEN '2020-01-01' AND '2020-03-31'),
deuxTri AS(
SELECT COUNT(*) as total2
FROM vente v
WHERE v.Date_vente BETWEEN '2020-04-01' AND '2020-06-30')
SELECT total1, total2, (total2-total1)*100/total2
FROM premTri, deuxTri;

-- 8. Classement des régions par prix au mètre carré des appartements de plus de 4 pièces
SELECT r.nom_region, ROUND(AVG(v.Valeur_fonciere / b.Surface), 2) AS prix_m2
FROM vente v
JOIN bien_immo b ON v.Id_bien = b.Id_bien
JOIN commune c ON c.id_codedep_codecommune = b.id_codedep_codecommune
JOIN region r ON r.id_region = c.id_region
WHERE b.Type_local = 'Appartement'
AND b.Total_piece > 4
AND b.Surface > 0
GROUP BY r.id_region
ORDER BY prix_m2 DESC;

-- 9. Communes ayant eu au moins 50 ventes au 1er trimestre 2020
SELECT c.Commune, COUNT(*) AS nb_ventes
FROM vente v
JOIN bien_immo b ON v.Id_bien = b.Id_bien
JOIN commune c ON c.id_codedep_codecommune = b.id_codedep_codecommune
WHERE v.Date_vente BETWEEN '2020-01-01' AND '2020-03-31'
GROUP BY c.id_codedep_codecommune
HAVING nb_ventes >= 50;

-- 10. Différence en % du prix au mètre carré entre un appartement de 2 pièces et de 3 pièces
WITH prix_2_pieces AS (
    SELECT AVG(v.Valeur_fonciere / b.Surface) AS prix_m2_2
    FROM vente v
    JOIN bien_immo b ON v.Id_bien = b.Id_bien
    WHERE b.Type_local = 'Appartement' AND b.Total_piece = 2 AND b.Surface > 0
),prix_3_pieces AS (
    SELECT AVG(v.Valeur_fonciere / b.Surface) AS prix_m2_3
    FROM vente v
    JOIN bien_immo b ON v.Id_bien = b.Id_bien
    WHERE b.Type_local = 'Appartement' AND b.Total_piece = 3 AND b.Surface > 0
)
SELECT prix_m2_2, prix_m2_3, ((prix_m2_3 - prix_m2_2) / prix_m2_2) * 100 AS difference_pourcentage
FROM prix_2_pieces, prix_3_pieces;

-- 11. Moyennes de valeurs foncières pour le top 3 des communes des départements 6, 13, 33, 59 et 69
SELECT c.Commune, AVG(v.Valeur_fonciere) AS prix_moyen
FROM vente v
JOIN bien_immo b ON v.Id_bien = b.Id_bien
JOIN commune c ON c.id_codedep_codecommune = b.id_codedep_codecommune
WHERE c.Code_departement IN ('6', '13', '33', '59', '69')
GROUP BY c.id_codedep_codecommune
ORDER BY prix_moyen DESC
LIMIT 3;

-- 12. Les 20 communes avec le plus de transactions pour 1000 habitants (communes > 10 000 habitants) ??


