SELECT 
    c.id_esco_cargo,
    c.nome_cargo,
    comp.id_esco_comp,
    comp.nome_competencia,
    comp.tipo_relacao
FROM esco_cargo c
LEFT JOIN esco_competencia comp 
    ON c.id_esco_cargo = comp.id_esco_cargo
ORDER BY c.nome_cargo, comp.nome_competencia;

SELECT 
    c.nome_cargo,
    COUNT(comp.id_esco_comp) AS total_competencias
FROM esco_cargo c
LEFT JOIN esco_competencia comp 
    ON c.id_esco_cargo = comp.id_esco_cargo
GROUP BY c.nome_cargo
ORDER BY total_competencias DESC;