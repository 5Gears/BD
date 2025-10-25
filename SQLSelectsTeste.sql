SELECT 
    c.id_cargo,
    c.nome AS nome_cargo,
    comp.id_competencia,
    comp.nome AS nome_competencia,
    cc.tipo_relacao
FROM cargo c
LEFT JOIN cargo_competencia cc 
    ON c.id_cargo = cc.id_cargo
LEFT JOIN competencia comp 
    ON cc.id_competencia = comp.id_competencia
ORDER BY c.nome, comp.nome;

SELECT 
    c.nome AS nome_cargo,
    COUNT(cc.id_competencia) AS total_competencias
FROM cargo c
LEFT JOIN cargo_competencia cc 
    ON c.id_cargo = cc.id_cargo
GROUP BY c.id_cargo, c.nome
ORDER BY total_competencias DESC;
