--
-- PostgreSQL database dump (Com Dados Fictícios de Avaliação Universitária)
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

ALTER SCHEMA public OWNER TO juridico_prod_user;
COMMENT ON SCHEMA public IS '';

SET default_tablespace = '';
SET default_table_access_method = heap;

-- TABELAS
CREATE TABLE public.usuarios (
    id integer NOT NULL,
    nome character varying(100) NOT NULL,
    email character varying(120) NOT NULL,
    senha character varying(255) NOT NULL,
    tipo character varying(20) NOT NULL,
    ativo boolean NOT NULL,
    criado_em timestamp without time zone
);
ALTER TABLE public.usuarios OWNER TO juridico_prod_user;

CREATE SEQUENCE public.usuarios_id_seq AS integer START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
ALTER SEQUENCE public.usuarios_id_seq OWNER TO juridico_prod_user;
ALTER SEQUENCE public.usuarios_id_seq OWNED BY public.usuarios.id;

CREATE TABLE public.clientes (
    id integer NOT NULL,
    nome character varying(120) NOT NULL,
    cpf character varying(20) NOT NULL,
    telefone character varying(30) NOT NULL,
    email character varying(120) NOT NULL,
    advogado_id integer NOT NULL,
    criado_em timestamp without time zone
);
ALTER TABLE public.clientes OWNER TO juridico_prod_user;

CREATE SEQUENCE public.clientes_id_seq AS integer START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
ALTER SEQUENCE public.clientes_id_seq OWNER TO juridico_prod_user;
ALTER SEQUENCE public.clientes_id_seq OWNED BY public.clientes.id;

CREATE TABLE public.processos (
    id integer NOT NULL,
    numero_processo character varying(30) NOT NULL,
    descricao text NOT NULL,
    status character varying(50) NOT NULL,
    cliente_id integer NOT NULL,
    advogado_id integer NOT NULL,
    tribunal character varying(50),
    classe_processual character varying(100),
    orgao_julgador character varying(150),
    data_ajuizamento timestamp without time zone,
    criado_em timestamp without time zone
);
ALTER TABLE public.processos OWNER TO juridico_prod_user;

CREATE SEQUENCE public.processos_id_seq AS integer START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
ALTER SEQUENCE public.processos_id_seq OWNER TO juridico_prod_user;
ALTER SEQUENCE public.processos_id_seq OWNED BY public.processos.id;

CREATE TABLE public.historicos_processos (
    id integer NOT NULL,
    processo_id integer NOT NULL,
    data_hora timestamp without time zone,
    origem character varying(30) NOT NULL,
    nome_movimento character varying(150) NOT NULL,
    descricao_detalhada text
);
ALTER TABLE public.historicos_processos OWNER TO juridico_prod_user;

CREATE SEQUENCE public.historicos_processos_id_seq AS integer START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
ALTER SEQUENCE public.historicos_processos_id_seq OWNER TO juridico_prod_user;
ALTER SEQUENCE public.historicos_processos_id_seq OWNED BY public.historicos_processos.id;

CREATE TABLE public.agendamentos (
    id integer NOT NULL,
    titulo character varying(150) NOT NULL,
    descricao text NOT NULL,
    data_hora timestamp without time zone NOT NULL,
    advogado_id integer NOT NULL,
    cliente_id integer,
    ata_reuniao text,
    criado_em timestamp without time zone
);
ALTER TABLE public.agendamentos OWNER TO juridico_prod_user;

CREATE SEQUENCE public.agendamentos_id_seq AS integer START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
ALTER SEQUENCE public.agendamentos_id_seq OWNER TO juridico_prod_user;
ALTER SEQUENCE public.agendamentos_id_seq OWNED BY public.agendamentos.id;

-- DEFAULTS
ALTER TABLE ONLY public.agendamentos ALTER COLUMN id SET DEFAULT nextval('public.agendamentos_id_seq'::regclass);
ALTER TABLE ONLY public.clientes ALTER COLUMN id SET DEFAULT nextval('public.clientes_id_seq'::regclass);
ALTER TABLE ONLY public.historicos_processos ALTER COLUMN id SET DEFAULT nextval('public.historicos_processos_id_seq'::regclass);
ALTER TABLE ONLY public.processos ALTER COLUMN id SET DEFAULT nextval('public.processos_id_seq'::regclass);
ALTER TABLE ONLY public.usuarios ALTER COLUMN id SET DEFAULT nextval('public.usuarios_id_seq'::regclass);

-- Data for Name: usuarios
COPY public.usuarios (id, nome, email, senha, tipo, ativo, criado_em) FROM stdin;
1	João Braga	master@escritorio.com	pbkdf2:sha256:100000$d670abd226e99c023ed901840537f876$c9021d9679b6ae1735f270aaeb63e320605251ae9eae935cb8c142d7e925e276	master	t	2026-09-23 20:39:31.23597
2	João Vitor	joao@escritorio.com	pbkdf2:sha256:100000$74c2bf1f78a5d057cec2b9efc32ee5b2$071e648fd11f64609b22921814715f78a91b2fc6b78d68b64cf3ef1c5cbc5878	advogado	t	2026-09-23 20:39:31.396215
3	Rafaela Guimarães	rafaela@escritorio.com	pbkdf2:sha256:100000$1f938a09fdcddb2952c05a0a74f05c73$7459abff77f8c62feab9423d1a3de0aeb7e52c6f64efba4deb6677472a6b714b	advogado	t	2026-09-23 20:39:31.525244
4	José Roberto	jroberto@escritorio.com	pbkdf2:sha256:100000$4a6826907ba16feeaa66c9b82cb8196a$c43e14894598b724048c53d45fae60f1e5f96be32a9a110f98a13aa5bca19836	advogado	t	2026-09-23 21:45:41.000969
\.

-- Data for Name: clientes
COPY public.clientes (id, nome, cpf, telefone, email, advogado_id, criado_em) FROM stdin;
1	Lucas Ferreira Gomes	101.201.301-17	(12) 98001-1001	lucas.ferreira1@gmail.com	2	2026-08-01 10:15:00
2	Roberto Ribeiro Fernandes	102.202.302-24	(13) 98002-1002	roberto.ribeiro2@gmail.com	2	2026-08-02 11:15:00
3	Rodrigo Fernandes Santos	103.203.303-31	(14) 98003-1003	rodrigo.fernandes3@gmail.com	2	2026-08-03 12:15:00
4	Thiago Mendes Gomes	104.204.304-38	(15) 98004-1004	thiago.mendes4@gmail.com	2	2026-08-04 13:15:00
5	Gustavo Ferreira Fernandes	105.205.305-45	(16) 98005-1005	gustavo.ferreira5@gmail.com	2	2026-08-05 14:15:00
6	Eduardo Ribeiro Santos	106.206.306-52	(17) 98006-1006	eduardo.ribeiro6@gmail.com	2	2026-08-06 15:15:00
7	Lucas Fernandes Gomes	107.207.307-59	(18) 98007-1007	lucas.fernandes7@gmail.com	2	2026-08-07 16:15:00
8	Carlos Soares Costa	108.208.308-66	(11) 98008-1008	carlos.soares8@gmail.com	3	2026-08-01 10:15:00
9	Fernanda Nascimento Vieira	109.209.309-73	(12) 98009-1009	fernanda.nascimento9@gmail.com	3	2026-08-02 11:15:00
10	Beatriz Rodrigues Oliveira	110.210.310-80	(13) 98010-1010	beatriz.rodrigues10@gmail.com	3	2026-08-03 12:15:00
11	Juliana Costa Costa	111.211.311-87	(14) 98011-1011	juliana.costa11@gmail.com	3	2026-08-04 13:15:00
12	Aline Soares Vieira	112.212.312-94	(15) 98012-1012	aline.soares12@gmail.com	3	2026-08-05 14:15:00
13	Claudia Nascimento Oliveira	113.213.313-11	(16) 98013-1013	claudia.nascimento13@gmail.com	3	2026-08-06 15:15:00
14	Carlos Rodrigues Costa	114.214.314-18	(17) 98014-1014	carlos.rodrigues14@gmail.com	3	2026-08-07 16:15:00
15	Bruno Souza Ribeiro	115.215.315-25	(18) 98015-1015	bruno.souza15@gmail.com	4	2026-08-01 10:15:00
16	Ana Gomes Barbosa	116.216.316-32	(11) 98016-1016	ana.gomes16@gmail.com	4	2026-08-02 11:15:00
17	Gabriel Lopes Souza	117.217.317-39	(12) 98017-1017	gabriel.lopes17@gmail.com	4	2026-08-03 12:15:00
18	Diego Dias Ribeiro	118.218.318-46	(13) 98018-1018	diego.dias18@gmail.com	4	2026-08-04 13:15:00
19	Marcelo Souza Barbosa	119.219.319-53	(14) 98019-1019	marcelo.souza19@gmail.com	4	2026-08-05 14:15:00
20	Felipe Gomes Souza	120.220.320-60	(15) 98020-1020	felipe.gomes20@gmail.com	4	2026-08-06 15:15:00
21	Bruno Lopes Ribeiro	121.221.321-67	(16) 98021-1021	bruno.lopes21@gmail.com	4	2026-08-07 16:15:00
\.

-- Data for Name: processos
COPY public.processos (id, numero_processo, descricao, status, cliente_id, advogado_id, tribunal, classe_processual, orgao_julgador, data_ajuizamento, criado_em) FROM stdin;
1	1001234-27.2025.8.26.1001	Ação de indenização por danos materiais e morais decorrentes de descumprimento contratual.	Em andamento	1	2	TRT2	Ação Trabalhista - Rito Ordinário	2ª Vara do Trabalho de São Paulo	2025-01-01 14:00:00	2025-01-01 14:30:00
2	1002468-44.2025.8.26.1002	Ação trabalhista pleiteando horas extras, adicional de insalubridade e verbas rescisórias.	Aguardando audiência	2	2	TRT2	Ação Trabalhista - Rito Sumaríssimo	5ª Vara do Trabalho de Osasco	2025-02-04 14:00:00	2025-02-04 14:30:00
3	1003702-61.2025.8.26.1003	Ação de cobrança de honorários advocatícios e prestação de serviços judiciais.	Em andamento	3	2	TRF3	Procedimento do Juizado Especial Cível	1ª Vara Gabinete do JEF de São Paulo	2025-03-07 14:00:00	2025-03-07 14:30:00
4	1004936-78.2025.8.26.1004	Ação declaratória de inexistência de débito c/c pedido de tutela de urgência.	Concluído	4	2	TJRJ	Procedimento Comum Cível	4ª Vara Cível da Comarca da Capital	2025-04-10 14:00:00	2025-04-10 14:30:00
5	1006170-95.2025.8.26.1005	Ação de execução de título extrajudicial fundada em contrato de prestação de serviços.	Em andamento	5	2	TJMG	Ação de Cobrança	2ª Vara Cível de Belo Horizonte	2025-05-13 14:00:00	2025-05-13 14:30:00
6	1007404-22.2025.8.26.1006	Ação revisional de cláusulas contratuais c/c repetição de indébito.	Em andamento	6	2	TJSP	Procedimento Comum Cível	1ª Vara Cível da Comarca de São Paulo	2025-06-16 14:00:00	2025-06-16 14:30:00
7	1008638-39.2025.8.26.1007	Ação de busca e apreensão de bem alienado fiduciariamente.	Aguardando audiência	7	2	TJSP	Ação Civil Pública	3ª Vara Cível da Comarca de Campinas	2025-07-19 14:00:00	2025-07-19 14:30:00
8	1009872-56.2025.8.26.1008	Ação de rescisão contratual com devolução de quantias pagas.	Em andamento	1	2	TRT2	Ação Trabalhista - Rito Ordinário	2ª Vara do Trabalho de São Paulo	2025-08-22 14:00:00	2025-08-22 14:30:00
9	1011106-73.2025.8.26.1009	Mandado de segurança contra ato de autoridade coatora em concurso público.	Concluído	2	2	TRT2	Ação Trabalhista - Rito Sumaríssimo	5ª Vara do Trabalho de Osasco	2025-09-25 14:00:00	2025-09-25 14:30:00
10	1012340-90.2025.8.26.1010	Ação de consignação em pagamento c/c pedido de quitação integral.	Em andamento	3	2	TRF3	Procedimento do Juizado Especial Cível	1ª Vara Gabinete do JEF de São Paulo	2025-10-28 14:00:00	2025-10-28 14:30:00
11	1013574-17.2025.8.26.1011	Ação de indenização por danos materiais e morais decorrentes de descumprimento contratual.	Em andamento	8	3	TRT2	Ação Trabalhista - Rito Sumaríssimo	5ª Vara do Trabalho de Osasco	2025-01-01 14:00:00	2025-01-01 14:30:00
12	1014808-34.2025.8.26.1012	Ação trabalhista pleiteando horas extras, adicional de insalubridade e verbas rescisórias.	Aguardando audiência	9	3	TRF3	Procedimento do Juizado Especial Cível	1ª Vara Gabinete do JEF de São Paulo	2025-02-04 14:00:00	2025-02-04 14:30:00
13	1016042-51.2025.8.26.1013	Ação de cobrança de honorários advocatícios e prestação de serviços judiciais.	Em andamento	10	3	TJRJ	Procedimento Comum Cível	4ª Vara Cível da Comarca da Capital	2025-03-07 14:00:00	2025-03-07 14:30:00
14	1017276-68.2025.8.26.1014	Ação declaratória de inexistência de débito c/c pedido de tutela de urgência.	Concluído	11	3	TJMG	Ação de Cobrança	2ª Vara Cível de Belo Horizonte	2025-04-10 14:00:00	2025-04-10 14:30:00
15	1018510-85.2025.8.26.1015	Ação de execução de título extrajudicial fundada em contrato de prestação de serviços.	Em andamento	12	3	TJSP	Procedimento Comum Cível	1ª Vara Cível da Comarca de São Paulo	2025-05-13 14:00:00	2025-05-13 14:30:00
16	1019744-12.2025.8.26.1016	Ação revisional de cláusulas contratuais c/c repetição de indébito.	Em andamento	13	3	TJSP	Ação Civil Pública	3ª Vara Cível da Comarca de Campinas	2025-06-16 14:00:00	2025-06-16 14:30:00
17	1020978-29.2025.8.26.1017	Ação de busca e apreensão de bem alienado fiduciariamente.	Aguardando audiência	14	3	TRT2	Ação Trabalhista - Rito Ordinário	2ª Vara do Trabalho de São Paulo	2025-07-19 14:00:00	2025-07-19 14:30:00
18	1022212-46.2025.8.26.1018	Ação de rescisão contratual com devolução de quantias pagas.	Em andamento	8	3	TRT2	Ação Trabalhista - Rito Sumaríssimo	5ª Vara do Trabalho de Osasco	2025-08-22 14:00:00	2025-08-22 14:30:00
19	1023446-63.2025.8.26.1019	Mandado de segurança contra ato de autoridade coatora em concurso público.	Concluído	9	3	TRF3	Procedimento do Juizado Especial Cível	1ª Vara Gabinete do JEF de São Paulo	2025-09-25 14:00:00	2025-09-25 14:30:00
20	1024680-80.2025.8.26.1020	Ação de consignação em pagamento c/c pedido de quitação integral.	Em andamento	10	3	TJRJ	Procedimento Comum Cível	4ª Vara Cível da Comarca da Capital	2025-10-28 14:00:00	2025-10-28 14:30:00
21	1025914-97.2025.8.26.1021	Ação de indenização por danos materiais e morais decorrentes de descumprimento contratual.	Em andamento	15	4	TRF3	Procedimento do Juizado Especial Cível	1ª Vara Gabinete do JEF de São Paulo	2025-01-01 14:00:00	2025-01-01 14:30:00
22	1027148-24.2025.8.26.1022	Ação trabalhista pleiteando horas extras, adicional de insalubridade e verbas rescisórias.	Aguardando audiência	16	4	TJRJ	Procedimento Comum Cível	4ª Vara Cível da Comarca da Capital	2025-02-04 14:00:00	2025-02-04 14:30:00
23	1028382-41.2025.8.26.1023	Ação de cobrança de honorários advocatícios e prestação de serviços judiciais.	Em andamento	17	4	TJMG	Ação de Cobrança	2ª Vara Cível de Belo Horizonte	2025-03-07 14:00:00	2025-03-07 14:30:00
24	1029616-58.2025.8.26.1024	Ação declaratória de inexistência de débito c/c pedido de tutela de urgência.	Concluído	18	4	TJSP	Procedimento Comum Cível	1ª Vara Cível da Comarca de São Paulo	2025-04-10 14:00:00	2025-04-10 14:30:00
25	1030850-75.2025.8.26.1025	Ação de execução de título extrajudicial fundada em contrato de prestação de serviços.	Em andamento	19	4	TJSP	Ação Civil Pública	3ª Vara Cível da Comarca de Campinas	2025-05-13 14:00:00	2025-05-13 14:30:00
26	1032084-92.2025.8.26.1026	Ação revisional de cláusulas contratuais c/c repetição de indébito.	Em andamento	20	4	TRT2	Ação Trabalhista - Rito Ordinário	2ª Vara do Trabalho de São Paulo	2025-06-16 14:00:00	2025-06-16 14:30:00
27	1033318-19.2025.8.26.1027	Ação de busca e apreensão de bem alienado fiduciariamente.	Aguardando audiência	21	4	TRT2	Ação Trabalhista - Rito Sumaríssimo	5ª Vara do Trabalho de Osasco	2025-07-19 14:00:00	2025-07-19 14:30:00
28	1034552-36.2025.8.26.1028	Ação de rescisão contratual com devolução de quantias pagas.	Em andamento	15	4	TRF3	Procedimento do Juizado Especial Cível	1ª Vara Gabinete do JEF de São Paulo	2025-08-22 14:00:00	2025-08-22 14:30:00
29	1035786-53.2025.8.26.1029	Mandado de segurança contra ato de autoridade coatora em concurso público.	Concluído	16	4	TJRJ	Procedimento Comum Cível	4ª Vara Cível da Comarca da Capital	2025-09-25 14:00:00	2025-09-25 14:30:00
30	1037020-70.2025.8.26.1030	Ação de consignação em pagamento c/c pedido de quitação integral.	Em andamento	17	4	TJMG	Ação de Cobrança	2ª Vara Cível de Belo Horizonte	2025-10-28 14:00:00	2025-10-28 14:30:00
\.

-- Data for Name: historicos_processos
COPY public.historicos_processos (id, processo_id, data_hora, origem, nome_movimento, descricao_detalhada) FROM stdin;
1	1	2025-01-01 14:30:00	CNJ Datajud	Distribuição	Distribuição automatizada do processo.
2	1	2025-01-15 10:00:00	CNJ Datajud	Citação	Expedição de mandado de citação da parte ré.
3	1	2026-08-20 15:30:00	CNJ Datajud	Juntada de Petição	Juntada de petição de manifestação sobre contestação.
4	2	2025-02-04 14:30:00	CNJ Datajud	Distribuição	Distribuição automatizada do processo.
5	2	2025-02-15 10:00:00	CNJ Datajud	Citação	Expedição de mandado de citação da parte ré.
6	2	2026-09-01 11:00:00	Manual	Designação de Audiência	Audiência de conciliação designada pelo juízo.
7	3	2025-03-07 14:30:00	CNJ Datajud	Distribuição	Distribuição automatizada do processo.
8	3	2025-03-15 10:00:00	CNJ Datajud	Citação	Expedição de mandado de citação da parte ré.
9	3	2026-08-20 15:30:00	CNJ Datajud	Juntada de Petição	Juntada de petição de manifestação sobre contestação.
10	4	2025-04-10 14:30:00	CNJ Datajud	Distribuição	Distribuição automatizada do processo.
11	4	2025-04-15 10:00:00	CNJ Datajud	Citação	Expedição de mandado de citação da parte ré.
12	4	2026-05-10 16:00:00	CNJ Datajud	Arquivamento	Processo julgado procedente e arquivado definitivamente.
13	5	2025-05-13 14:30:00	CNJ Datajud	Distribuição	Distribuição automatizada do processo.
14	5	2025-05-15 10:00:00	CNJ Datajud	Citação	Expedição de mandado de citação da parte ré.
15	5	2026-08-20 15:30:00	CNJ Datajud	Juntada de Petição	Juntada de petição de manifestação sobre contestação.
16	6	2025-06-16 14:30:00	CNJ Datajud	Distribuição	Distribuição automatizada do processo.
17	6	2025-06-15 10:00:00	CNJ Datajud	Citação	Expedição de mandado de citação da parte ré.
18	6	2026-08-20 15:30:00	CNJ Datajud	Juntada de Petição	Juntada de petição de manifestação sobre contestação.
19	7	2025-07-19 14:30:00	CNJ Datajud	Distribuição	Distribuição automatizada do processo.
20	7	2025-07-15 10:00:00	CNJ Datajud	Citação	Expedição de mandado de citação da parte ré.
21	7	2026-09-01 11:00:00	Manual	Designação de Audiência	Audiência de conciliação designada pelo juízo.
22	8	2025-08-22 14:30:00	CNJ Datajud	Distribuição	Distribuição automatizada do processo.
23	8	2025-08-15 10:00:00	CNJ Datajud	Citação	Expedição de mandado de citação da parte ré.
24	8	2026-08-20 15:30:00	CNJ Datajud	Juntada de Petição	Juntada de petição de manifestação sobre contestação.
25	9	2025-09-25 14:30:00	CNJ Datajud	Distribuição	Distribuição automatizada do processo.
26	9	2025-09-15 10:00:00	CNJ Datajud	Citação	Expedição de mandado de citação da parte ré.
27	9	2026-05-10 16:00:00	CNJ Datajud	Arquivamento	Processo julgado procedente e arquivado definitivamente.
28	10	2025-10-28 14:30:00	CNJ Datajud	Distribuição	Distribuição automatizada do processo.
29	10	2025-10-15 10:00:00	CNJ Datajud	Citação	Expedição de mandado de citação da parte ré.
30	10	2026-08-20 15:30:00	CNJ Datajud	Juntada de Petição	Juntada de petição de manifestação sobre contestação.
31	11	2025-01-01 14:30:00	CNJ Datajud	Distribuição	Distribuição automatizada do processo.
32	11	2025-01-15 10:00:00	CNJ Datajud	Citação	Expedição de mandado de citação da parte ré.
33	11	2026-08-20 15:30:00	CNJ Datajud	Juntada de Petição	Juntada de petição de manifestação sobre contestação.
34	12	2025-02-04 14:30:00	CNJ Datajud	Distribuição	Distribuição automatizada do processo.
35	12	2025-02-15 10:00:00	CNJ Datajud	Citação	Expedição de mandado de citação da parte ré.
36	12	2026-09-01 11:00:00	Manual	Designação de Audiência	Audiência de conciliação designada pelo juízo.
37	13	2025-03-07 14:30:00	CNJ Datajud	Distribuição	Distribuição automatizada do processo.
38	13	2025-03-15 10:00:00	CNJ Datajud	Citação	Expedição de mandado de citação da parte ré.
39	13	2026-08-20 15:30:00	CNJ Datajud	Juntada de Petição	Juntada de petição de manifestação sobre contestação.
40	14	2025-04-10 14:30:00	CNJ Datajud	Distribuição	Distribuição automatizada do processo.
41	14	2025-04-15 10:00:00	CNJ Datajud	Citação	Expedição de mandado de citação da parte ré.
42	14	2026-05-10 16:00:00	CNJ Datajud	Arquivamento	Processo julgado procedente e arquivado definitivamente.
43	15	2025-05-13 14:30:00	CNJ Datajud	Distribuição	Distribuição automatizada do processo.
44	15	2025-05-15 10:00:00	CNJ Datajud	Citação	Expedição de mandado de citação da parte ré.
45	15	2026-08-20 15:30:00	CNJ Datajud	Juntada de Petição	Juntada de petição de manifestação sobre contestação.
46	16	2025-06-16 14:30:00	CNJ Datajud	Distribuição	Distribuição automatizada do processo.
47	16	2025-06-15 10:00:00	CNJ Datajud	Citação	Expedição de mandado de citação da parte ré.
48	16	2026-08-20 15:30:00	CNJ Datajud	Juntada de Petição	Juntada de petição de manifestação sobre contestação.
49	17	2025-07-19 14:30:00	CNJ Datajud	Distribuição	Distribuição automatizada do processo.
50	17	2025-07-15 10:00:00	CNJ Datajud	Citação	Expedição de mandado de citação da parte ré.
51	17	2026-09-01 11:00:00	Manual	Designação de Audiência	Audiência de conciliação designada pelo juízo.
52	18	2025-08-22 14:30:00	CNJ Datajud	Distribuição	Distribuição automatizada do processo.
53	18	2025-08-15 10:00:00	CNJ Datajud	Citação	Expedição de mandado de citação da parte ré.
54	18	2026-08-20 15:30:00	CNJ Datajud	Juntada de Petição	Juntada de petição de manifestação sobre contestação.
55	19	2025-09-25 14:30:00	CNJ Datajud	Distribuição	Distribuição automatizada do processo.
56	19	2025-09-15 10:00:00	CNJ Datajud	Citação	Expedição de mandado de citação da parte ré.
57	19	2026-05-10 16:00:00	CNJ Datajud	Arquivamento	Processo julgado procedente e arquivado definitivamente.
58	20	2025-10-28 14:30:00	CNJ Datajud	Distribuição	Distribuição automatizada do processo.
59	20	2025-10-15 10:00:00	CNJ Datajud	Citação	Expedição de mandado de citação da parte ré.
60	20	2026-08-20 15:30:00	CNJ Datajud	Juntada de Petição	Juntada de petição de manifestação sobre contestação.
61	21	2025-01-01 14:30:00	CNJ Datajud	Distribuição	Distribuição automatizada do processo.
62	21	2025-01-15 10:00:00	CNJ Datajud	Citação	Expedição de mandado de citação da parte ré.
63	21	2026-08-20 15:30:00	CNJ Datajud	Juntada de Petição	Juntada de petição de manifestação sobre contestação.
64	22	2025-02-04 14:30:00	CNJ Datajud	Distribuição	Distribuição automatizada do processo.
65	22	2025-02-15 10:00:00	CNJ Datajud	Citação	Expedição de mandado de citação da parte ré.
66	22	2026-09-01 11:00:00	Manual	Designação de Audiência	Audiência de conciliação designada pelo juízo.
67	23	2025-03-07 14:30:00	CNJ Datajud	Distribuição	Distribuição automatizada do processo.
68	23	2025-03-15 10:00:00	CNJ Datajud	Citação	Expedição de mandado de citação da parte ré.
69	23	2026-08-20 15:30:00	CNJ Datajud	Juntada de Petição	Juntada de petição de manifestação sobre contestação.
70	24	2025-04-10 14:30:00	CNJ Datajud	Distribuição	Distribuição automatizada do processo.
71	24	2025-04-15 10:00:00	CNJ Datajud	Citação	Expedição de mandado de citação da parte ré.
72	24	2026-05-10 16:00:00	CNJ Datajud	Arquivamento	Processo julgado procedente e arquivado definitivamente.
73	25	2025-05-13 14:30:00	CNJ Datajud	Distribuição	Distribuição automatizada do processo.
74	25	2025-05-15 10:00:00	CNJ Datajud	Citação	Expedição de mandado de citação da parte ré.
75	25	2026-08-20 15:30:00	CNJ Datajud	Juntada de Petição	Juntada de petição de manifestação sobre contestação.
76	26	2025-06-16 14:30:00	CNJ Datajud	Distribuição	Distribuição automatizada do processo.
77	26	2025-06-15 10:00:00	CNJ Datajud	Citação	Expedição de mandado de citação da parte ré.
78	26	2026-08-20 15:30:00	CNJ Datajud	Juntada de Petição	Juntada de petição de manifestação sobre contestação.
79	27	2025-07-19 14:30:00	CNJ Datajud	Distribuição	Distribuição automatizada do processo.
80	27	2025-07-15 10:00:00	CNJ Datajud	Citação	Expedição de mandado de citação da parte ré.
81	27	2026-09-01 11:00:00	Manual	Designação de Audiência	Audiência de conciliação designada pelo juízo.
82	28	2025-08-22 14:30:00	CNJ Datajud	Distribuição	Distribuição automatizada do processo.
83	28	2025-08-15 10:00:00	CNJ Datajud	Citação	Expedição de mandado de citação da parte ré.
84	28	2026-08-20 15:30:00	CNJ Datajud	Juntada de Petição	Juntada de petição de manifestação sobre contestação.
85	29	2025-09-25 14:30:00	CNJ Datajud	Distribuição	Distribuição automatizada do processo.
86	29	2025-09-15 10:00:00	CNJ Datajud	Citação	Expedição de mandado de citação da parte ré.
87	29	2026-05-10 16:00:00	CNJ Datajud	Arquivamento	Processo julgado procedente e arquivado definitivamente.
88	30	2025-10-28 14:30:00	CNJ Datajud	Distribuição	Distribuição automatizada do processo.
89	30	2025-10-15 10:00:00	CNJ Datajud	Citação	Expedição de mandado de citação da parte ré.
90	30	2026-08-20 15:30:00	CNJ Datajud	Juntada de Petição	Juntada de petição de manifestação sobre contestação.
\.

-- Data for Name: agendamentos
COPY public.agendamentos (id, titulo, descricao, data_hora, advogado_id, cliente_id, ata_reuniao, criado_em) FROM stdin;
1	Reunião Inicial com Cliente	Alinhamento preliminar de tese defensiva e recolhimento de documentação essencial.	2026-08-01 09:00:00	2	\N	Cliente ciente da estratégia adotada. Ficou acertado o envio dos comprovantes de pagamento até a próxima sexta-feira.	2026-07-01 10:00:00
2	Audiência de Conciliação	Comparecimento virtual para tentativa de acordo entre as partes.	2026-08-03 10:00:00	2	2	Realizada tentativa de composição amigável sem acordo no momento. Processo segue para fase instrutória.	2026-07-02 10:00:00
3	Elaboração de Réplica	Análise de contestação e redação de peça réplica com jurisprudência atualizada.	2026-08-05 11:00:00	2	3	Pauta concluída com sucesso. Documentos conferidos e petição protocolo emitida com cópia ao cliente.	2026-07-03 10:00:00
4	Atendimento para Assinatura de Procuração	Reunião presencial no escritório para coleta de assinaturas e alinhamento de prazos.	2026-08-07 12:00:00	2	4	Ata registrada: minuta de acordo aprovada pelo cliente com parcelamento em 5x. Enviar para homologação.	2026-07-04 10:00:00
5	Reunião de Acompanhamento Processual	Prestação de contas sobre o andamento da ação e próximos passos judiciais.	2026-08-09 13:00:00	2	5	Reunião produtiva. Solicitada certidão atualizada do imóvel para instrução do pedido de liminar.	2026-07-05 10:00:00
6	Análise de Perícia Técnica	Avaliação de laudo pericial anexado aos autos e preparação de impugnação.	2026-08-11 14:00:00	2	\N	Cliente ciente da estratégia adotada. Ficou acertado o envio dos comprovantes de pagamento até a próxima sexta-feira.	2026-07-06 10:00:00
7	Reunião de Estratégia de Recurso	Discussão sobre interposição de Recurso Ordinário/Apelação e teses recursais.	2026-08-13 15:00:00	2	7	Realizada tentativa de composição amigável sem acordo no momento. Processo segue para fase instrutória.	2026-07-07 10:00:00
8	Alinhamento de Proposta de Acordo	Avaliando proposta enviada pelo exequente/réu e elaboração de contraproposta.	2026-09-15 16:00:00	2	1	Pauta concluída com sucesso. Documentos conferidos e petição protocolo emitida com cópia ao cliente.	2026-07-08 10:00:00
9	Preparação para Depoimento Pessoal	Simulação e orientação do cliente para audiência de instrução e julgamento.	2026-09-17 09:00:00	2	2	Ata registrada: minuta de acordo aprovada pelo cliente com parcelamento em 5x. Enviar para homologação.	2026-07-09 10:00:00
10	Consulta sobre Execução de Sentença	Análise do cálculo de liquidação e expedição de RPV/Precatório.	2026-09-19 10:00:00	2	3	Reunião produtiva. Solicitada certidão atualizada do imóvel para instrução do pedido de liminar.	2026-07-10 10:00:00
11	Reunião Inicial com Cliente	Alinhamento preliminar de tese defensiva e recolhimento de documentação essencial.	2026-09-21 11:00:00	2	\N	Cliente ciente da estratégia adotada. Ficou acertado o envio dos comprovantes de pagamento até a próxima sexta-feira.	2026-07-11 10:00:00
12	Audiência de Conciliação	Comparecimento virtual para tentativa de acordo entre as partes.	2026-09-23 12:00:00	2	5	Realizada tentativa de composição amigável sem acordo no momento. Processo segue para fase instrutória.	2026-07-12 10:00:00
13	Elaboração de Réplica	Análise de contestação e redação de peça réplica com jurisprudência atualizada.	2026-09-25 13:00:00	2	6	Pauta concluída com sucesso. Documentos conferidos e petição protocolo emitida com cópia ao cliente.	2026-07-13 10:00:00
14	Atendimento para Assinatura de Procuração	Reunião presencial no escritório para coleta de assinaturas e alinhamento de prazos.	2026-09-27 14:00:00	2	7	Ata registrada: minuta de acordo aprovada pelo cliente com parcelamento em 5x. Enviar para homologação.	2026-07-14 10:00:00
15	Reunião de Acompanhamento Processual	Prestação de contas sobre o andamento da ação e próximos passos judiciais.	2026-10-01 15:00:00	2	1	Reunião produtiva. Solicitada certidão atualizada do imóvel para instrução do pedido de liminar.	2026-07-15 10:00:00
16	Análise de Perícia Técnica	Avaliação de laudo pericial anexado aos autos e preparação de impugnação.	2026-10-03 16:00:00	2	\N	Cliente ciente da estratégia adotada. Ficou acertado o envio dos comprovantes de pagamento até a próxima sexta-feira.	2026-07-16 10:00:00
17	Reunião de Estratégia de Recurso	Discussão sobre interposição de Recurso Ordinário/Apelação e teses recursais.	2026-10-05 09:00:00	2	3	Realizada tentativa de composição amigável sem acordo no momento. Processo segue para fase instrutória.	2026-07-17 10:00:00
18	Alinhamento de Proposta de Acordo	Avaliando proposta enviada pelo exequente/réu e elaboração de contraproposta.	2026-10-07 10:00:00	2	4	Pauta concluída com sucesso. Documentos conferidos e petição protocolo emitida com cópia ao cliente.	2026-07-18 10:00:00
19	Preparação para Depoimento Pessoal	Simulação e orientação do cliente para audiência de instrução e julgamento.	2026-10-09 11:00:00	2	5	Ata registrada: minuta de acordo aprovada pelo cliente com parcelamento em 5x. Enviar para homologação.	2026-07-19 10:00:00
20	Consulta sobre Execução de Sentença	Análise do cálculo de liquidação e expedição de RPV/Precatório.	2026-10-11 12:00:00	2	6	Reunião produtiva. Solicitada certidão atualizada do imóvel para instrução do pedido de liminar.	2026-07-20 10:00:00
21	Reunião Inicial com Cliente	Alinhamento preliminar de tese defensiva e recolhimento de documentação essencial.	2026-08-01 09:00:00	3	\N	Cliente ciente da estratégia adotada. Ficou acertado o envio dos comprovantes de pagamento até a próxima sexta-feira.	2026-07-01 10:00:00
22	Audiência de Conciliação	Comparecimento virtual para tentativa de acordo entre as partes.	2026-08-03 10:00:00	3	9	Realizada tentativa de composição amigável sem acordo no momento. Processo segue para fase instrutória.	2026-07-02 10:00:00
23	Elaboração de Réplica	Análise de contestação e redação de peça réplica com jurisprudência atualizada.	2026-08-05 11:00:00	3	10	Pauta concluída com sucesso. Documentos conferidos e petição protocolo emitida com cópia ao cliente.	2026-07-03 10:00:00
24	Atendimento para Assinatura de Procuração	Reunião presencial no escritório para coleta de assinaturas e alinhamento de prazos.	2026-08-07 12:00:00	3	11	Ata registrada: minuta de acordo aprovada pelo cliente com parcelamento em 5x. Enviar para homologação.	2026-07-04 10:00:00
25	Reunião de Acompanhamento Processual	Prestação de contas sobre o andamento da ação e próximos passos judiciais.	2026-08-09 13:00:00	3	12	Reunião produtiva. Solicitada certidão atualizada do imóvel para instrução do pedido de liminar.	2026-07-05 10:00:00
26	Análise de Perícia Técnica	Avaliação de laudo pericial anexado aos autos e preparação de impugnação.	2026-08-11 14:00:00	3	\N	Cliente ciente da estratégia adotada. Ficou acertado o envio dos comprovantes de pagamento até a próxima sexta-feira.	2026-07-06 10:00:00
27	Reunião de Estratégia de Recurso	Discussão sobre interposição de Recurso Ordinário/Apelação e teses recursais.	2026-08-13 15:00:00	3	14	Realizada tentativa de composição amigável sem acordo no momento. Processo segue para fase instrutória.	2026-07-07 10:00:00
28	Alinhamento de Proposta de Acordo	Avaliando proposta enviada pelo exequente/réu e elaboração de contraproposta.	2026-09-15 16:00:00	3	8	Pauta concluída com sucesso. Documentos conferidos e petição protocolo emitida com cópia ao cliente.	2026-07-08 10:00:00
29	Preparação para Depoimento Pessoal	Simulação e orientação do cliente para audiência de instrução e julgamento.	2026-09-17 09:00:00	3	9	Ata registrada: minuta de acordo aprovada pelo cliente com parcelamento em 5x. Enviar para homologação.	2026-07-09 10:00:00
30	Consulta sobre Execução de Sentença	Análise do cálculo de liquidação e expedição de RPV/Precatório.	2026-09-19 10:00:00	3	10	Reunião produtiva. Solicitada certidão atualizada do imóvel para instrução do pedido de liminar.	2026-07-10 10:00:00
31	Reunião Inicial com Cliente	Alinhamento preliminar de tese defensiva e recolhimento de documentação essencial.	2026-09-21 11:00:00	3	\N	Cliente ciente da estratégia adotada. Ficou acertado o envio dos comprovantes de pagamento até a próxima sexta-feira.	2026-07-11 10:00:00
32	Audiência de Conciliação	Comparecimento virtual para tentativa de acordo entre as partes.	2026-09-23 12:00:00	3	12	Realizada tentativa de composição amigável sem acordo no momento. Processo segue para fase instrutória.	2026-07-12 10:00:00
33	Elaboração de Réplica	Análise de contestação e redação de peça réplica com jurisprudência atualizada.	2026-09-25 13:00:00	3	13	Pauta concluída com sucesso. Documentos conferidos e petição protocolo emitida com cópia ao cliente.	2026-07-13 10:00:00
34	Atendimento para Assinatura de Procuração	Reunião presencial no escritório para coleta de assinaturas e alinhamento de prazos.	2026-09-27 14:00:00	3	14	Ata registrada: minuta de acordo aprovada pelo cliente com parcelamento em 5x. Enviar para homologação.	2026-07-14 10:00:00
35	Reunião de Acompanhamento Processual	Prestação de contas sobre o andamento da ação e próximos passos judiciais.	2026-10-01 15:00:00	3	8	Reunião produtiva. Solicitada certidão atualizada do imóvel para instrução do pedido de liminar.	2026-07-15 10:00:00
36	Análise de Perícia Técnica	Avaliação de laudo pericial anexado aos autos e preparação de impugnação.	2026-10-03 16:00:00	3	\N	Cliente ciente da estratégia adotada. Ficou acertado o envio dos comprovantes de pagamento até a próxima sexta-feira.	2026-07-16 10:00:00
37	Reunião de Estratégia de Recurso	Discussão sobre interposição de Recurso Ordinário/Apelação e teses recursais.	2026-10-05 09:00:00	3	10	Realizada tentativa de composição amigável sem acordo no momento. Processo segue para fase instrutória.	2026-07-17 10:00:00
38	Alinhamento de Proposta de Acordo	Avaliando proposta enviada pelo exequente/réu e elaboração de contraproposta.	2026-10-07 10:00:00	3	11	Pauta concluída com sucesso. Documentos conferidos e petição protocolo emitida com cópia ao cliente.	2026-07-18 10:00:00
39	Preparação para Depoimento Pessoal	Simulação e orientação do cliente para audiência de instrução e julgamento.	2026-10-09 11:00:00	3	12	Ata registrada: minuta de acordo aprovada pelo cliente com parcelamento em 5x. Enviar para homologação.	2026-07-19 10:00:00
40	Consulta sobre Execução de Sentença	Análise do cálculo de liquidação e expedição de RPV/Precatório.	2026-10-11 12:00:00	3	13	Reunião produtiva. Solicitada certidão atualizada do imóvel para instrução do pedido de liminar.	2026-07-20 10:00:00
41	Reunião Inicial com Cliente	Alinhamento preliminar de tese defensiva e recolhimento de documentação essencial.	2026-08-01 09:00:00	4	\N	Cliente ciente da estratégia adotada. Ficou acertado o envio dos comprovantes de pagamento até a próxima sexta-feira.	2026-07-01 10:00:00
42	Audiência de Conciliação	Comparecimento virtual para tentativa de acordo entre as partes.	2026-08-03 10:00:00	4	16	Realizada tentativa de composição amigável sem acordo no momento. Processo segue para fase instrutória.	2026-07-02 10:00:00
43	Elaboração de Réplica	Análise de contestação e redação de peça réplica com jurisprudência atualizada.	2026-08-05 11:00:00	4	17	Pauta concluída com sucesso. Documentos conferidos e petição protocolo emitida com cópia ao cliente.	2026-07-03 10:00:00
44	Atendimento para Assinatura de Procuração	Reunião presencial no escritório para coleta de assinaturas e alinhamento de prazos.	2026-08-07 12:00:00	4	18	Ata registrada: minuta de acordo aprovada pelo cliente com parcelamento em 5x. Enviar para homologação.	2026-07-04 10:00:00
45	Reunião de Acompanhamento Processual	Prestação de contas sobre o andamento da ação e próximos passos judiciais.	2026-08-09 13:00:00	4	19	Reunião produtiva. Solicitada certidão atualizada do imóvel para instrução do pedido de liminar.	2026-07-05 10:00:00
46	Análise de Perícia Técnica	Avaliação de laudo pericial anexado aos autos e preparação de impugnação.	2026-08-11 14:00:00	4	\N	Cliente ciente da estratégia adotada. Ficou acertado o envio dos comprovantes de pagamento até a próxima sexta-feira.	2026-07-06 10:00:00
47	Reunião de Estratégia de Recurso	Discussão sobre interposição de Recurso Ordinário/Apelação e teses recursais.	2026-08-13 15:00:00	4	21	Realizada tentativa de composição amigável sem acordo no momento. Processo segue para fase instrutória.	2026-07-07 10:00:00
48	Alinhamento de Proposta de Acordo	Avaliando proposta enviada pelo exequente/réu e elaboração de contraproposta.	2026-09-15 16:00:00	4	15	Pauta concluída com sucesso. Documentos conferidos e petição protocolo emitida com cópia ao cliente.	2026-07-08 10:00:00
49	Preparação para Depoimento Pessoal	Simulação e orientação do cliente para audiência de instrução e julgamento.	2026-09-17 09:00:00	4	16	Ata registrada: minuta de acordo aprovada pelo cliente com parcelamento em 5x. Enviar para homologação.	2026-07-09 10:00:00
50	Consulta sobre Execução de Sentença	Análise do cálculo de liquidação e expedição de RPV/Precatório.	2026-09-19 10:00:00	4	17	Reunião produtiva. Solicitada certidão atualizada do imóvel para instrução do pedido de liminar.	2026-07-10 10:00:00
51	Reunião Inicial com Cliente	Alinhamento preliminar de tese defensiva e recolhimento de documentação essencial.	2026-09-21 11:00:00	4	\N	Cliente ciente da estratégia adotada. Ficou acertado o envio dos comprovantes de pagamento até a próxima sexta-feira.	2026-07-11 10:00:00
52	Audiência de Conciliação	Comparecimento virtual para tentativa de acordo entre as partes.	2026-09-23 12:00:00	4	19	Realizada tentativa de composição amigável sem acordo no momento. Processo segue para fase instrutória.	2026-07-12 10:00:00
53	Elaboração de Réplica	Análise de contestação e redação de peça réplica com jurisprudência atualizada.	2026-09-25 13:00:00	4	20	Pauta concluída com sucesso. Documentos conferidos e petição protocolo emitida com cópia ao cliente.	2026-07-13 10:00:00
54	Atendimento para Assinatura de Procuração	Reunião presencial no escritório para coleta de assinaturas e alinhamento de prazos.	2026-09-27 14:00:00	4	21	Ata registrada: minuta de acordo aprovada pelo cliente com parcelamento em 5x. Enviar para homologação.	2026-07-14 10:00:00
55	Reunião de Acompanhamento Processual	Prestação de contas sobre o andamento da ação e próximos passos judiciais.	2026-10-01 15:00:00	4	15	Reunião produtiva. Solicitada certidão atualizada do imóvel para instrução do pedido de liminar.	2026-07-15 10:00:00
56	Análise de Perícia Técnica	Avaliação de laudo pericial anexado aos autos e preparação de impugnação.	2026-10-03 16:00:00	4	\N	Cliente ciente da estratégia adotada. Ficou acertado o envio dos comprovantes de pagamento até a próxima sexta-feira.	2026-07-16 10:00:00
57	Reunião de Estratégia de Recurso	Discussão sobre interposição de Recurso Ordinário/Apelação e teses recursais.	2026-10-05 09:00:00	4	17	Realizada tentativa de composição amigável sem acordo no momento. Processo segue para fase instrutória.	2026-07-17 10:00:00
58	Alinhamento de Proposta de Acordo	Avaliando proposta enviada pelo exequente/réu e elaboração de contraproposta.	2026-10-07 10:00:00	4	18	Pauta concluída com sucesso. Documentos conferidos e petição protocolo emitida com cópia ao cliente.	2026-07-18 10:00:00
59	Preparação para Depoimento Pessoal	Simulação e orientação do cliente para audiência de instrução e julgamento.	2026-10-09 11:00:00	4	19	Ata registrada: minuta de acordo aprovada pelo cliente com parcelamento em 5x. Enviar para homologação.	2026-07-19 10:00:00
60	Consulta sobre Execução de Sentença	Análise do cálculo de liquidação e expedição de RPV/Precatório.	2026-10-11 12:00:00	4	20	Reunião produtiva. Solicitada certidão atualizada do imóvel para instrução do pedido de liminar.	2026-07-20 10:00:00
\.

-- SEQUENCES SETVAL
SELECT pg_catalog.setval('public.agendamentos_id_seq', 60, true);
SELECT pg_catalog.setval('public.clientes_id_seq', 21, true);
SELECT pg_catalog.setval('public.historicos_processos_id_seq', 90, true);
SELECT pg_catalog.setval('public.processos_id_seq', 30, true);
SELECT pg_catalog.setval('public.usuarios_id_seq', 4, true);

-- PRIMARY KEYS & CONSTRAINTS
ALTER TABLE ONLY public.agendamentos ADD CONSTRAINT agendamentos_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.clientes ADD CONSTRAINT clientes_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.historicos_processos ADD CONSTRAINT historicos_processos_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.processos ADD CONSTRAINT processos_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.usuarios ADD CONSTRAINT usuarios_pkey PRIMARY KEY (id);

CREATE INDEX ix_agendamentos_id ON public.agendamentos USING btree (id);
CREATE INDEX ix_clientes_id ON public.clientes USING btree (id);
CREATE INDEX ix_historicos_processos_id ON public.historicos_processos USING btree (id);
CREATE INDEX ix_processos_id ON public.processos USING btree (id);
CREATE UNIQUE INDEX ix_processos_numero_processo ON public.processos USING btree (numero_processo);
CREATE UNIQUE INDEX ix_usuarios_email ON public.usuarios USING btree (email);
CREATE INDEX ix_usuarios_id ON public.usuarios USING btree (id);

-- FOREIGN KEYS
ALTER TABLE ONLY public.agendamentos ADD CONSTRAINT agendamentos_advogado_id_fkey FOREIGN KEY (advogado_id) REFERENCES public.usuarios(id);
ALTER TABLE ONLY public.agendamentos ADD CONSTRAINT agendamentos_cliente_id_fkey FOREIGN KEY (cliente_id) REFERENCES public.clientes(id);
ALTER TABLE ONLY public.clientes ADD CONSTRAINT clientes_advogado_id_fkey FOREIGN KEY (advogado_id) REFERENCES public.usuarios(id);
ALTER TABLE ONLY public.historicos_processos ADD CONSTRAINT historicos_processos_processo_id_fkey FOREIGN KEY (processo_id) REFERENCES public.processos(id);
ALTER TABLE ONLY public.processos ADD CONSTRAINT processos_advogado_id_fkey FOREIGN KEY (advogado_id) REFERENCES public.usuarios(id);
ALTER TABLE ONLY public.processos ADD CONSTRAINT processos_cliente_id_fkey FOREIGN KEY (cliente_id) REFERENCES public.clientes(id);

REVOKE USAGE ON SCHEMA public FROM PUBLIC;
