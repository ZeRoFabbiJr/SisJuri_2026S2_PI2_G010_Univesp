--
-- PostgreSQL database dump
--

\restrict GRsphO6nvJGSp6wSITqzJIdfS6VbpcvdTKXPDRycfIyBV4pqDVffh0EWe9xR7Xe

-- Dumped from database version 16.15
-- Dumped by pg_dump version 16.15

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

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: juridico_prod_user
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO juridico_prod_user;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: juridico_prod_user
--

COMMENT ON SCHEMA public IS '';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: agendamentos; Type: TABLE; Schema: public; Owner: juridico_prod_user
--

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

--
-- Name: agendamentos_id_seq; Type: SEQUENCE; Schema: public; Owner: juridico_prod_user
--

CREATE SEQUENCE public.agendamentos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.agendamentos_id_seq OWNER TO juridico_prod_user;

--
-- Name: agendamentos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: juridico_prod_user
--

ALTER SEQUENCE public.agendamentos_id_seq OWNED BY public.agendamentos.id;


--
-- Name: clientes; Type: TABLE; Schema: public; Owner: juridico_prod_user
--

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

--
-- Name: clientes_id_seq; Type: SEQUENCE; Schema: public; Owner: juridico_prod_user
--

CREATE SEQUENCE public.clientes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.clientes_id_seq OWNER TO juridico_prod_user;

--
-- Name: clientes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: juridico_prod_user
--

ALTER SEQUENCE public.clientes_id_seq OWNED BY public.clientes.id;


--
-- Name: historicos_processos; Type: TABLE; Schema: public; Owner: juridico_prod_user
--

CREATE TABLE public.historicos_processos (
    id integer NOT NULL,
    processo_id integer NOT NULL,
    data_hora timestamp without time zone,
    origem character varying(30) NOT NULL,
    nome_movimento character varying(150) NOT NULL,
    descricao_detalhada text
);


ALTER TABLE public.historicos_processos OWNER TO juridico_prod_user;

--
-- Name: historicos_processos_id_seq; Type: SEQUENCE; Schema: public; Owner: juridico_prod_user
--

CREATE SEQUENCE public.historicos_processos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.historicos_processos_id_seq OWNER TO juridico_prod_user;

--
-- Name: historicos_processos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: juridico_prod_user
--

ALTER SEQUENCE public.historicos_processos_id_seq OWNED BY public.historicos_processos.id;


--
-- Name: processos; Type: TABLE; Schema: public; Owner: juridico_prod_user
--

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

--
-- Name: processos_id_seq; Type: SEQUENCE; Schema: public; Owner: juridico_prod_user
--

CREATE SEQUENCE public.processos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.processos_id_seq OWNER TO juridico_prod_user;

--
-- Name: processos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: juridico_prod_user
--

ALTER SEQUENCE public.processos_id_seq OWNED BY public.processos.id;


--
-- Name: usuarios; Type: TABLE; Schema: public; Owner: juridico_prod_user
--

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

--
-- Name: usuarios_id_seq; Type: SEQUENCE; Schema: public; Owner: juridico_prod_user
--

CREATE SEQUENCE public.usuarios_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.usuarios_id_seq OWNER TO juridico_prod_user;

--
-- Name: usuarios_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: juridico_prod_user
--

ALTER SEQUENCE public.usuarios_id_seq OWNED BY public.usuarios.id;


--
-- Name: agendamentos id; Type: DEFAULT; Schema: public; Owner: juridico_prod_user
--

ALTER TABLE ONLY public.agendamentos ALTER COLUMN id SET DEFAULT nextval('public.agendamentos_id_seq'::regclass);


--
-- Name: clientes id; Type: DEFAULT; Schema: public; Owner: juridico_prod_user
--

ALTER TABLE ONLY public.clientes ALTER COLUMN id SET DEFAULT nextval('public.clientes_id_seq'::regclass);


--
-- Name: historicos_processos id; Type: DEFAULT; Schema: public; Owner: juridico_prod_user
--

ALTER TABLE ONLY public.historicos_processos ALTER COLUMN id SET DEFAULT nextval('public.historicos_processos_id_seq'::regclass);


--
-- Name: processos id; Type: DEFAULT; Schema: public; Owner: juridico_prod_user
--

ALTER TABLE ONLY public.processos ALTER COLUMN id SET DEFAULT nextval('public.processos_id_seq'::regclass);


--
-- Name: usuarios id; Type: DEFAULT; Schema: public; Owner: juridico_prod_user
--

ALTER TABLE ONLY public.usuarios ALTER COLUMN id SET DEFAULT nextval('public.usuarios_id_seq'::regclass);


--
-- Data for Name: agendamentos; Type: TABLE DATA; Schema: public; Owner: juridico_prod_user
--

COPY public.agendamentos (id, titulo, descricao, data_hora, advogado_id, cliente_id, ata_reuniao, criado_em) FROM stdin;
2	Reunião com cliente	Teste	2026-09-25 11:15:00	4	1	\N	2026-09-23 22:22:15.102408
1	Reunião com cliente	Teste	2026-09-25 11:00:00	4	1	Testando 1, 2	2026-09-23 22:21:26.167547
3	Reunião com cliente	Teste api	2026-09-25 11:30:00	4	2	Teste	2026-09-25 11:13:03.212037
\.


--
-- Data for Name: clientes; Type: TABLE DATA; Schema: public; Owner: juridico_prod_user
--

COPY public.clientes (id, nome, cpf, telefone, email, advogado_id, criado_em) FROM stdin;
1	Marcondes Marquez	123.456.789-09	11999999	meuemail@meuemail.com	4	2026-09-23 21:47:49.65656
2	Peter Packer	123.456.789-09	11988888888	pp@escritorio.com	4	2026-09-25 11:07:53.115587
3	Mary Jane	123.456.789-09	1199999999	meuemail@meuemail.com	4	2026-09-25 14:17:28.20772
\.


--
-- Data for Name: historicos_processos; Type: TABLE DATA; Schema: public; Owner: juridico_prod_user
--

COPY public.historicos_processos (id, processo_id, data_hora, origem, nome_movimento, descricao_detalhada) FROM stdin;
1	1	2025-12-03 18:44:00	CNJ Datajud	Distribuição	Código TPU: 26
2	1	2025-12-03 18:44:01	CNJ Datajud	Inicial	Código TPU: 12747
3	1	2025-12-04 15:59:49	CNJ Datajud	Conclusão	Código TPU: 51
4	1	2025-12-04 16:00:23	CNJ Datajud	Conclusão	Código TPU: 51
5	1	2025-12-04 16:02:36	CNJ Datajud	de Instrução	Código TPU: 12749
6	1	2025-12-04 16:02:36	CNJ Datajud	Inicial	Código TPU: 12747
7	1	2025-12-05 16:10:57	CNJ Datajud	Expedição de documento	Código TPU: 60
8	1	2025-12-05 16:10:57	CNJ Datajud	Expedição de documento	Código TPU: 60
9	1	2025-12-09 12:15:56	CNJ Datajud	Publicação	Código TPU: 92
10	1	2025-12-09 12:15:56	CNJ Datajud	Disponibilização no Diário da Justiça Eletrônico	Código TPU: 1061
11	1	2025-12-18 09:26:35	CNJ Datajud	Petição	Código TPU: 85
12	1	2026-01-15 16:15:36	CNJ Datajud	Petição	Código TPU: 85
13	1	2026-01-17 18:06:47	CNJ Datajud	Petição	Código TPU: 85
14	1	2026-01-19 14:49:57	CNJ Datajud	Conclusão	Código TPU: 51
15	1	2026-01-19 18:05:28	CNJ Datajud	Expedição de documento	Código TPU: 60
16	1	2026-01-19 18:05:28	CNJ Datajud	Expedição de documento	Código TPU: 60
17	1	2026-01-20 08:04:54	CNJ Datajud	Publicação	Código TPU: 92
18	1	2026-01-20 08:04:54	CNJ Datajud	Disponibilização no Diário da Justiça Eletrônico	Código TPU: 1061
19	1	2026-01-20 08:04:54	CNJ Datajud	Publicação	Código TPU: 92
20	1	2026-01-20 08:04:54	CNJ Datajud	Disponibilização no Diário da Justiça Eletrônico	Código TPU: 1061
21	1	2026-02-10 14:29:37	CNJ Datajud	Petição	Código TPU: 85
22	1	2026-02-11 13:30:42	CNJ Datajud	Petição	Código TPU: 85
23	1	2026-03-26 16:56:07	CNJ Datajud	de Instrução	Código TPU: 12749
24	1	2026-03-26 18:55:25	CNJ Datajud	Expedição de documento	Código TPU: 60
25	1	2026-03-26 18:56:21	CNJ Datajud	de Instrução	Código TPU: 12749
26	1	2026-03-27 07:30:57	CNJ Datajud	Expedição de documento	Código TPU: 60
27	1	2026-03-27 07:30:57	CNJ Datajud	Expedição de documento	Código TPU: 60
28	1	2026-03-30 10:56:15	CNJ Datajud	Disponibilização no Diário da Justiça Eletrônico	Código TPU: 1061
29	1	2026-03-30 10:56:15	CNJ Datajud	Publicação	Código TPU: 92
30	1	2026-03-30 10:56:15	CNJ Datajud	Publicação	Código TPU: 92
31	1	2026-03-30 10:56:15	CNJ Datajud	Disponibilização no Diário da Justiça Eletrônico	Código TPU: 1061
32	1	2026-03-30 16:08:36	CNJ Datajud	Petição	Código TPU: 85
33	1	2026-03-31 20:08:43	CNJ Datajud	Petição	Código TPU: 85
34	1	2026-03-31 20:19:49	CNJ Datajud	Petição	Código TPU: 85
35	1	2026-05-28 17:01:33	CNJ Datajud	de Instrução	Código TPU: 12749
36	1	2026-05-28 17:01:33	CNJ Datajud	de Instrução	Código TPU: 12749
37	1	2026-05-28 17:01:46	CNJ Datajud	Conclusão	Código TPU: 51
38	1	2026-05-28 17:30:00	CNJ Datajud	Expedição de documento	Código TPU: 60
39	1	2026-05-28 17:30:00	CNJ Datajud	Expedição de documento	Código TPU: 60
40	1	2026-05-29 04:24:35	CNJ Datajud	Publicação	Código TPU: 92
41	1	2026-05-29 04:24:35	CNJ Datajud	Disponibilização no Diário da Justiça Eletrônico	Código TPU: 1061
42	1	2026-05-29 04:24:36	CNJ Datajud	Disponibilização no Diário da Justiça Eletrônico	Código TPU: 1061
43	1	2026-05-29 04:24:36	CNJ Datajud	Publicação	Código TPU: 92
44	1	2026-05-29 08:12:08	CNJ Datajud	de Instrução	Código TPU: 12749
45	1	2026-05-29 08:12:08	CNJ Datajud	de Instrução	Código TPU: 12749
46	1	2026-05-29 08:13:52	CNJ Datajud	de Instrução	Código TPU: 12749
47	1	2026-05-29 08:13:52	CNJ Datajud	de Instrução	Código TPU: 12749
48	1	2026-06-01 19:03:05	CNJ Datajud	Petição	Código TPU: 85
49	1	2026-06-08 20:17:27	CNJ Datajud	Petição	Código TPU: 85
50	1	2026-06-11 00:48:39	CNJ Datajud	Decurso de Prazo	Código TPU: 1051
51	1	2026-06-24 13:40:01	CNJ Datajud	Conclusão	Código TPU: 51
52	1	2026-06-24 13:41:27	CNJ Datajud	de Instrução	Código TPU: 12749
53	1	2026-06-24 13:41:27	CNJ Datajud	de Instrução	Código TPU: 12749
54	1	2026-06-24 13:42:31	CNJ Datajud	Expedição de documento	Código TPU: 60
55	1	2026-06-24 13:44:08	CNJ Datajud	de Instrução	Código TPU: 12749
56	1	2026-06-24 13:44:08	CNJ Datajud	de Instrução	Código TPU: 12749
57	1	2026-06-25 09:34:44	CNJ Datajud	Expedição de documento	Código TPU: 60
58	1	2026-06-25 09:34:44	CNJ Datajud	Expedição de documento	Código TPU: 60
59	1	2026-06-26 04:16:34	CNJ Datajud	Publicação	Código TPU: 92
60	1	2026-06-26 04:16:34	CNJ Datajud	Disponibilização no Diário da Justiça Eletrônico	Código TPU: 1061
61	1	2026-06-26 04:16:34	CNJ Datajud	Publicação	Código TPU: 92
62	1	2026-06-26 04:16:34	CNJ Datajud	Disponibilização no Diário da Justiça Eletrônico	Código TPU: 1061
63	1	2026-07-01 08:34:55	CNJ Datajud	Expedição de documento	Código TPU: 60
64	1	2026-07-01 08:34:55	CNJ Datajud	Expedição de documento	Código TPU: 60
65	1	2026-07-02 16:14:42	CNJ Datajud	Disponibilização no Diário da Justiça Eletrônico	Código TPU: 1061
66	1	2026-07-02 16:14:42	CNJ Datajud	Publicação	Código TPU: 92
67	1	2026-07-10 23:14:59	CNJ Datajud	Petição	Código TPU: 85
68	1	2026-07-21 00:20:35	CNJ Datajud	Decurso de Prazo	Código TPU: 1051
69	1	2026-07-28 14:04:44	CNJ Datajud	Conclusão	Código TPU: 51
70	1	2026-07-28 19:08:32	CNJ Datajud	de Julgamento	Código TPU: 12751
71	1	2026-07-28 19:08:32	CNJ Datajud	de Instrução	Código TPU: 12749
72	1	2026-07-29 15:11:53	CNJ Datajud	Expedição de documento	Código TPU: 60
73	1	2026-07-29 15:11:53	CNJ Datajud	Expedição de documento	Código TPU: 60
74	1	2026-07-31 16:27:41	CNJ Datajud	Publicação	Código TPU: 92
75	1	2026-07-31 16:27:41	CNJ Datajud	Disponibilização no Diário da Justiça Eletrônico	Código TPU: 1061
76	1	2026-07-31 16:27:41	CNJ Datajud	Publicação	Código TPU: 92
77	1	2026-07-31 16:27:41	CNJ Datajud	Disponibilização no Diário da Justiça Eletrônico	Código TPU: 1061
78	1	2026-08-01 21:13:19	CNJ Datajud	Conclusão	Código TPU: 51
79	1	2026-08-04 18:51:17	CNJ Datajud	Petição	Código TPU: 85
80	1	2025-12-03 18:44:01	CNJ Datajud	Inclusão no Juízo 100% Digital	Código TPU: 14736
81	1	2025-12-04 16:00:10	CNJ Datajud	Conclusão	Código TPU: 15101
82	1	2025-12-05 16:09:57	CNJ Datajud	Antecipação de tutela	Código TPU: 785
83	1	2026-01-19 18:04:28	CNJ Datajud	Mero expediente	Código TPU: 11010
84	1	2026-05-28 17:29:00	CNJ Datajud	Mero expediente	Código TPU: 11010
85	1	2026-06-25 09:33:44	CNJ Datajud	Mero expediente	Código TPU: 11010
86	1	2026-07-28 19:08:48	CNJ Datajud	Inclusão no Juízo 100% Digital	Código TPU: 14736
87	1	2026-07-29 15:10:53	CNJ Datajud	Mero expediente	Código TPU: 11010
\.


--
-- Data for Name: processos; Type: TABLE DATA; Schema: public; Owner: juridico_prod_user
--

COPY public.processos (id, numero_processo, descricao, status, cliente_id, advogado_id, tribunal, classe_processual, orgao_julgador, data_ajuizamento, criado_em) FROM stdin;
1	10020529320255020292	Teste	Em andamento	1	4	TRT2	Ação Trabalhista - Rito Ordinário	2ª Vara do Trabalho de Franco da Rocha	\N	2026-09-23 21:48:06.177466
3	10091315220248260224	Teste API	Em andamento	2	4	\N	\N	\N	\N	2026-09-25 11:10:29.78711
7	95189266520268010788	Teste api	Em andamento	2	4	\N	\N	\N	\N	2026-09-25 11:16:42.160247
\.


--
-- Data for Name: usuarios; Type: TABLE DATA; Schema: public; Owner: juridico_prod_user
--

COPY public.usuarios (id, nome, email, senha, tipo, ativo, criado_em) FROM stdin;
1	João Braga	master@escritorio.com	pbkdf2:sha256:100000$d670abd226e99c023ed901840537f876$c9021d9679b6ae1735f270aaeb63e320605251ae9eae935cb8c142d7e925e276	master	t	2026-09-23 20:39:31.23597
2	João Vitor	joao@escritorio.com	pbkdf2:sha256:100000$74c2bf1f78a5d057cec2b9efc32ee5b2$071e648fd11f64609b22921814715f78a91b2fc6b78d68b64cf3ef1c5cbc5878	advogado	t	2026-09-23 20:39:31.396215
3	Rafaela Guimarães	rafaela@escritorio.com	pbkdf2:sha256:100000$1f938a09fdcddb2952c05a0a74f05c73$7459abff77f8c62feab9423d1a3de0aeb7e52c6f64efba4deb6677472a6b714b	advogado	t	2026-09-23 20:39:31.525244
4	José Roberto	jroberto@escritorio.com	pbkdf2:sha256:100000$4a6826907ba16feeaa66c9b82cb8196a$c43e14894598b724048c53d45fae60f1e5f96be32a9a110f98a13aa5bca19836	advogado	t	2026-09-23 21:45:41.000969
\.


--
-- Name: agendamentos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: juridico_prod_user
--

SELECT pg_catalog.setval('public.agendamentos_id_seq', 3, true);


--
-- Name: clientes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: juridico_prod_user
--

SELECT pg_catalog.setval('public.clientes_id_seq', 3, true);


--
-- Name: historicos_processos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: juridico_prod_user
--

SELECT pg_catalog.setval('public.historicos_processos_id_seq', 87, true);


--
-- Name: processos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: juridico_prod_user
--

SELECT pg_catalog.setval('public.processos_id_seq', 9, true);


--
-- Name: usuarios_id_seq; Type: SEQUENCE SET; Schema: public; Owner: juridico_prod_user
--

SELECT pg_catalog.setval('public.usuarios_id_seq', 4, true);


--
-- Name: agendamentos agendamentos_pkey; Type: CONSTRAINT; Schema: public; Owner: juridico_prod_user
--

ALTER TABLE ONLY public.agendamentos
    ADD CONSTRAINT agendamentos_pkey PRIMARY KEY (id);


--
-- Name: clientes clientes_pkey; Type: CONSTRAINT; Schema: public; Owner: juridico_prod_user
--

ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT clientes_pkey PRIMARY KEY (id);


--
-- Name: historicos_processos historicos_processos_pkey; Type: CONSTRAINT; Schema: public; Owner: juridico_prod_user
--

ALTER TABLE ONLY public.historicos_processos
    ADD CONSTRAINT historicos_processos_pkey PRIMARY KEY (id);


--
-- Name: processos processos_pkey; Type: CONSTRAINT; Schema: public; Owner: juridico_prod_user
--

ALTER TABLE ONLY public.processos
    ADD CONSTRAINT processos_pkey PRIMARY KEY (id);


--
-- Name: usuarios usuarios_pkey; Type: CONSTRAINT; Schema: public; Owner: juridico_prod_user
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_pkey PRIMARY KEY (id);


--
-- Name: ix_agendamentos_id; Type: INDEX; Schema: public; Owner: juridico_prod_user
--

CREATE INDEX ix_agendamentos_id ON public.agendamentos USING btree (id);


--
-- Name: ix_clientes_id; Type: INDEX; Schema: public; Owner: juridico_prod_user
--

CREATE INDEX ix_clientes_id ON public.clientes USING btree (id);


--
-- Name: ix_historicos_processos_id; Type: INDEX; Schema: public; Owner: juridico_prod_user
--

CREATE INDEX ix_historicos_processos_id ON public.historicos_processos USING btree (id);


--
-- Name: ix_processos_id; Type: INDEX; Schema: public; Owner: juridico_prod_user
--

CREATE INDEX ix_processos_id ON public.processos USING btree (id);


--
-- Name: ix_processos_numero_processo; Type: INDEX; Schema: public; Owner: juridico_prod_user
--

CREATE UNIQUE INDEX ix_processos_numero_processo ON public.processos USING btree (numero_processo);


--
-- Name: ix_usuarios_email; Type: INDEX; Schema: public; Owner: juridico_prod_user
--

CREATE UNIQUE INDEX ix_usuarios_email ON public.usuarios USING btree (email);


--
-- Name: ix_usuarios_id; Type: INDEX; Schema: public; Owner: juridico_prod_user
--

CREATE INDEX ix_usuarios_id ON public.usuarios USING btree (id);


--
-- Name: agendamentos agendamentos_advogado_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: juridico_prod_user
--

ALTER TABLE ONLY public.agendamentos
    ADD CONSTRAINT agendamentos_advogado_id_fkey FOREIGN KEY (advogado_id) REFERENCES public.usuarios(id);


--
-- Name: agendamentos agendamentos_cliente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: juridico_prod_user
--

ALTER TABLE ONLY public.agendamentos
    ADD CONSTRAINT agendamentos_cliente_id_fkey FOREIGN KEY (cliente_id) REFERENCES public.clientes(id);


--
-- Name: clientes clientes_advogado_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: juridico_prod_user
--

ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT clientes_advogado_id_fkey FOREIGN KEY (advogado_id) REFERENCES public.usuarios(id);


--
-- Name: historicos_processos historicos_processos_processo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: juridico_prod_user
--

ALTER TABLE ONLY public.historicos_processos
    ADD CONSTRAINT historicos_processos_processo_id_fkey FOREIGN KEY (processo_id) REFERENCES public.processos(id);


--
-- Name: processos processos_advogado_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: juridico_prod_user
--

ALTER TABLE ONLY public.processos
    ADD CONSTRAINT processos_advogado_id_fkey FOREIGN KEY (advogado_id) REFERENCES public.usuarios(id);


--
-- Name: processos processos_cliente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: juridico_prod_user
--

ALTER TABLE ONLY public.processos
    ADD CONSTRAINT processos_cliente_id_fkey FOREIGN KEY (cliente_id) REFERENCES public.clientes(id);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: juridico_prod_user
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


--
-- PostgreSQL database dump complete
--

\unrestrict GRsphO6nvJGSp6wSITqzJIdfS6VbpcvdTKXPDRycfIyBV4pqDVffh0EWe9xR7Xe

