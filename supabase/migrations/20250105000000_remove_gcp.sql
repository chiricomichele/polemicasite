-- Remove GCP from the ranking view
DROP VIEW IF EXISTS v_gcp;

CREATE VIEW v_gcp AS
SELECT
  p.id,
  p.nome,
  COUNT(*)                                          AS presenze,
  SUM(md.gol)                                       AS gol_totali,
  SUM(md.assist)                                    AS assist_totali,
  ROUND(AVG(md.voto)::numeric, 2)                   AS media_voto,
  SUM(md.differenza_reti)                            AS plus_minus
FROM match_details md
JOIN players p ON p.id = md.player_id
GROUP BY p.id, p.nome;

-- Re-grant after recreating the view
GRANT SELECT ON v_gcp TO anon;
GRANT SELECT ON v_gcp TO authenticated;
