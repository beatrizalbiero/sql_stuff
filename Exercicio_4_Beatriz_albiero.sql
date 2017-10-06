--4.1

CREATE TABLE PESSOA (
   nome            VARCHAR(50) NOT NULL,
   cpf                CHAR(11) not null UNIQUE,
   nusp              VARCHAR(10) NOT NULL,
   PRIMARY KEY (nusp)
);


CREATE TABLE PROFESSOR (
   sala               VARCHAR(4) NOT NULL,
   nusp_prof     VARCHAR(10) NOT NULL,
    FOREIGN KEY(nusp_prof) REFERENCES PESSOA(nusp)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    PRIMARY KEY(nusp_prof)
);


CREATE TABLE ALUNO (
    id_aluno VARCHAR(20),
    primary key (id_aluno)
    );

CREATE TABLE ALUNO_REGULAR (
    curso          VARCHAR(30) NOT NULL DEFAULT 'Bacharelado em Estatistica',
    nusp_aluno_reg VARCHAR(10),
    nusp_prof      VARCHAR(10),
    id_aluno   VARCHAR(20) NOT NULL,
    FOREIGN KEY(nusp_aluno_reg) REFERENCES PESSOA(nusp)
    ON DELETE restrict ON UPDATE CASCADE,
    FOREIGN KEY(nusp_prof) REFERENCES PROFESSOR(nusp_prof)
    ON DELETE restrict ON UPDATE CASCADE,
    FOREIGN KEY (id_aluno) REFERENCES ALUNO(id_aluno)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    PRIMARY KEY(nusp_aluno_reg)
    );

CREATE TABLE ALUNO_ESPECIAL (
    email varchar(50),
    nome  varchar(50) NOT NULL,
    id_aluno VARCHAR(20) NOT NULL,
    FOREIGN KEY(id_aluno) REFERENCES ALUNO(id_aluno)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    PRIMARY KEY (email)
    );

 CREATE TABLE DISCIPLINA(
     codigo VARCHAR(10),
     nome    VARCHAR(50) NOT NULL,
     PRIMARY KEY (codigo)
     );

CREATE TABLE PRE_REQUISITO(
    cod_disc VARCHAR(50),
    cod_disc_pre_requisito VARCHAR(50),
    FOREIGN KEY (cod_disc) REFERENCES DISCIPLINA(codigo)
    ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (cod_disc_pre_requisito) REFERENCES DISCIPLINA(codigo)
    ON DELETE CASCADE ON UPDATE CASCADE,
    PRIMARY KEY(cod_disc,cod_disc_pre_requisito)
    );

 CREATE TABLE MINISTRA (
     nusp_prof varchar(10),
     cod_disc varchar(10),
     semestre_ano varchar(10),
     FOREIGN KEY (nusp_prof) REFERENCES PROFESSOR(nusp_prof)
     ON DELETE CASCADE ON UPDATE CASCADE,
     FOREIGN KEY (cod_disc) REFERENCES DISCIPLINA(codigo)
     ON DELETE CASCADE ON UPDATE CASCADE,
     primary key(nusp_prof,cod_disc,semestre_ano)
);

CREATE TABLE MATRICULA(
    nusp_prof VARCHAR(10),
    cod_disc VARCHAR(10),
    semestre_ano VARCHAR(10),
    id_aluno VARCHAR(10),
    frequencia INT CHECK (frequencia >= 0 AND frequencia<=100),
    nota DECIMAL(4,2) CHECK(nota<=10 AND nota>=0),
    situacao VARCHAR(14) CHECK (situacao in ('reprovado','aprovado','em recuperação')),
    FOREIGN KEY (nusp_prof, cod_disc, semestre_ano) REFERENCES MINISTRA(nusp_prof, cod_disc, semestre_ano)
    ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_aluno) REFERENCES ALUNO(id_aluno)
    ON DELETE CASCADE ON UPDATE CASCADE,
    PRIMARY KEY (nusp_prof, cod_disc, semestre_ano, id_aluno),
 	CHECK ((nota > 5 AND frequencia > 75 AND situacao = 'aprovado') OR situacao = 'reprovado' OR situacao = 'em recuperação')
    );

--4.2
--a)
SELECT modelo,tipo AS modo_impressao, preco AS R$ FROM IMPRESSORA
WHERE preco > 200 AND preco < 300;

--b)
SELECT DISTINCT fabricante FROM PRODUTO
WHERE tipo = 'impressora' OR tipo = 'pc';

--c)
SELECT modelo, velocidade, hd FROM PC
WHERE (cd = '6x' OR cd = '8x') AND preco < 2000
ORDER BY velocidade DESC, hd DESC;

--d)
	SELECT * FROM PC
WHERE modelo>preco;

--e)
SELECT tipo FROM PRODUTO
WHERE fabricante LIKE '% %' AND fabricante LIKE '%HW%';

--f)
SELECT fabricante, produto.modelo, impressora.tipo FROM impressora, produto
WHERE produto.modelo = impressora.modelo AND colorida = true AND impressora.tipo <> 'ink-jet';

--g)
SELECT pc1.modelo, pc2.modelo FROM PC pc1, PC pc2
WHERE pc1.cd = pc2.cd AND ((pc1.preco - pc2.preco) < 1000 AND (pc1.preco - pc2.preco) > -1000)
AND pc1.modelo < pc2.modelo;

--h)
(SELECT fabricante, pc.modelo, preco from pc,produto
where produto.modelo = pc.modelo) UNION (SELECT fabricante, impressora.modelo, preco from impressora,produto
where produto.modelo = impressora.modelo) union (SELECT fabricante, produto.modelo, preco from laptop,produtp
where produto.modelo = laptop.modelo);

--i)
(SELECT fabricante from produto
WHERE tipo = 'pc') INTERSECT (SELECT fabricante from produto WHERE tipo = 'impressora');

--j)
(SELECT fabricante from produto, pc
WHERE (produto.modelo = pc.modelo AND pc.preco > 2000)) UNION  (SELECT fabricante from produto, laptop
WHERE (produto.modelo = laptop.modelo AND laptop.preco > 2000)) EXCEPT (SELECT fabricante from produto, impressora
WHERE EXISTS (SELECT preco from impressora WHERE preco > 300) AND (produto.modelo = impressora.modelo));

--4.3 NAVIOS

--a)

select deslocamento from navios natural join classes
where lancamento = (select max(lancamento) from navios) ;

--b)
select nome from navios, classes
where navios.classe = classes.classe AND classes.numarmas > (select numarmas from classes where classe = 'Revenge');

--c)
(select nome from navios, classes
where navios.classe = classes.classe AND numArmas = (SELECT min(numArmas) FROM classes where tipo = 'ne')

--d)
select avg(numarmas) FROM classes
where deslocamento > 40000;

--e)
select avg(numarmas) FROM classes, navios
where navios.classe = classes.classe AND deslocamento > 40000;

--f)
select classe, count(nome) from navios
where nome not in (select nome from batalhas) group by classe;

--g)
select pais from classes
where classe in (select classes.classe from navios, classes where navios.classe = classes.classe
 group by classes.classe having count(navios.nome) >=3);

--h)

select pais, avg(calibre*calibre*calibre/2) AS peso_pais from navios, classes
WHERE navios.classe = classes.classe group by pais;

--i)

 -- batalhas que afundaram mais de dois navios
 (select batalha from resultados
group by batalha having count(desfecho = 'afundado') > 2);

-- navios que participaram dessas batalhas
select navio, resultados.batalha AS bts from resultados, (select batalha from resultados
group by batalha having count(desfecho = 'afundado') > 2) bt
where resultados.batalha = bt.batalha order by resultados.batalha;

-- ano de lancamento entre os navios que participaram de cada batalha\
select nome, bts, lancamento from navios, (select navio, resultados.batalha AS bts from resultados, (select batalha from resultados
group by batalha having count(desfecho = 'afundado') > 2) bt
where resultados.batalha = bt.batalha order by resultados.batalha) sb
where navios.nome = sb.navio;

-- o menor ano de lancamento para cada batalha

select bts, min(lancamento) from (select nome, bts, lancamento from navios, (select navio, resultados.batalha AS bts from resultados, (select batalha from resultados
group by batalha having count(desfecho = 'afundado') > 2) bt
where resultados.batalha = bt.batalha order by resultados.batalha) sb
where navios.nome = sb.navio) participaram
group by bts;

--j)
SELECT * from Classes LEFT OUTER JOIN Navios
ON (Classes.classe = Navios.classe);

--k)
SELECT * from (select distinct batalha from resultados) bt LEFT OUTER JOIN batalhas
ON bt.batalha = batalhas.nome;


--4.4 modificacao

--a)
insert into classes (classe,tipo,pais,calibre,deslocamento)
VALUES ('Minas Geraes','ne','Brasil',15,19200);

insert into navios (nome, classe, lancamento)
VALUES ('Minas Geraes','Minas Geraes',1910);

insert into navios (nome, classe, lancamento)
VALUES ('S\'e3o Paulo','Minas Geraes',1910);

--b)
insert into resultados(
Select nome, 'Guadalcanal','afundado' from navios where classe = 'Minas Geraes');

--c)
UPDATE classes
 SET  calibre = 0.025*calibre, deslocamento = deslocamento/1016.0469088
 WHERE pais = 'USA'OR pais = 'Gt. Britain';
--d)
DELETE from Navios n
WHERE exists
(select navio from (select navio,count(batalha) as conta from resultados group by navio) x where x.conta > 1 and x.navio = n.nome);

--4.5 views
--a)
CREATE VIEW ImpressorasColoridas AS
Select impressora.modelo, impressora.tipo, preco from impressora, produto
WHERE impressora.modelo = produto.modelo AND colorida = TRUE;

--b)
CREATE VIEW LaptopsIguaisPCs AS
Select laptop.modelo, laptop.velocidade, laptop.ram, laptop.hd, laptop.tela,laptop.preco from laptop, pc
WHERE laptop.velocidade = pc.velocidade;

--c)
CREATE VIEW InfoImpressoras AS
Select produto.fabricante, impressora.modelo, impressora.tipo, impressora.preco from impressora, produto
WHERE produto.modelo = impressora.modelo;

--d)
CREATE VIEW NaviosMaisNovos AS
select nome, lancamento from navios natural join classes
where lancamento = (select max(lancamento) from navios) ;

--e)
CREATE VIEW NaviosAfundados AS
Select navio, classe, lancamento from  resultados, navios
WHERE  resultados.navio = navios.nome AND resultados.desfecho = 'afundado';

--f)

--Primeiramente vamos criar duas visoes auxiliares para criar a visao pedida.

-- uma visao que seleciona o ultimo lancamento para cada classe
CREATE VIEW ultlancamentoview AS
Select classe, max(lancamento) AS lancamentomax from navios group by classe;

-- uma visao que conta o numero de navios para cada classe
CREATE VIEW numnavios AS
Select classe, count(nome) AS numNavios from navios
group by classe;

-- a visao pedida no enunciado

CREATE VIEW NaviosPorClasse AS
SELECT numnavios.classe, numNavios, lancamentomax AS ultLancamento from numnavios, ultlancamentoview
where numnavios.classe = ultlancamentoview.classe order by numnavios DESC;

--4.6
--a)
SELECT pais from classes, NaviosPorClasse
where classes.classe = NaviosPorClasse.classe AND numnavios > 2 AND tipo = 'ne';

--b)
select avg(numarmas) from NaviosAfundados natural join classes;

-- c)
select navio from NaviosAfundados, (select classe, max(lancamento) AS mxlc from navios group by classe) lc
WHERE naviosafundados.classe = lc.classe AND naviosafundados.lancamento = lc.mxlc;

--4.7

--a) A view NaviosMaisNovos nao eh atualizavel pois possui uma subconsulta dentro da tabela navios, portanto nao se pode realizar alteracoes de insercao, remocao e alteracao.

--4.8

--a)

CREATE TRIGGER preco_impressora
AFTER INSERT OR UPDATE OF  preco ON impressoras
REFERENCING NEW ROW AS new
FOR EACH ROW
WHEN (new.preco > 250)
SET new.preco = 250;
