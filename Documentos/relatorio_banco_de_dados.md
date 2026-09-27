# Relatório do Banco de Dados Relacional - Sistema Jurídico

## 1. Visão Geral do Banco de Dados Relacional

O sistema utiliza um banco de dados relacional (compatível com **PostgreSQL** em ambiente de produção e **SQLite** para desenvolvimento local). A modelagem foi projetada para garantir **integridade referencial**, **consistência nas operações de escrita/leitura** e **isolamento de dados por perfil de acesso**.

A estrutura do Diagrama de Entidade-Relacionamento (DER) é composta por 5 tabelas principais:
* **`usuarios`**: Gestão de contas de acesso (Master e Advogados) e controle de status.
* **`clientes`**: Cadastro de clientes vinculados aos advogados do escritório.
* **`processos`**: Registro das ações judiciais e metadados integrados ao CNJ Datajud.
* **`historicos_processos`**: Linha do tempo evolutiva e andamentos processuais.
* **`agendamentos`**: Gestão de compromissos, reuniões e registro de Atas de Reunião.

---

## 2. Estrutura de Dados e Dicionário de Tabelas

### 📌 Tabela: `usuarios`
Armazena as credenciais de autenticação, perfis de permissão e status operacional.

| Campo | Tipo de Dado | Restrições | Descrição |
| :--- | :--- | :--- | :--- |
| **`id`** | `INTEGER` | **PK**, Auto-incremento | Identificador único do usuário. |
| **`nome`** | `VARCHAR(100)` | `NOT NULL` | Nome completo do profissional. |
| **`email`** | `VARCHAR(120)` | `UNIQUE`, `NOT NULL`, `INDEX` | E-mail de login no sistema. |
| **`senha`** | `VARCHAR(255)` | `NOT NULL` | Hash criptográfico da senha (PBKDF2 / Bcrypt). |
| **`tipo`** | `VARCHAR(20)` | `NOT NULL` (default `'advogado'`) | Perfil de acesso: `'master'` ou `'advogado'. |
| **`ativo`** | `BOOLEAN` | `NOT NULL` (default `True`) | Status da conta (Ativado/Desativado pelo Master). |
| **`criado_em`** | `TIMESTAMP` | `DEFAULT UTC` | Data e hora de criação do registro. |

---

### 📌 Tabela: `clientes`
Armazena as informações dos contratantes e seus advogados responsáveis.

| Campo | Tipo de Dado | Restrições | Descrição |
| :--- | :--- | :--- | :--- |
| **`id`** | `INTEGER` | **PK**, Auto-incremento | Identificador único do cliente. |
| **`nome`** | `VARCHAR(120)` | `NOT NULL` | Nome completo do cliente. |
| **`cpf`** | `VARCHAR(20)` | `NOT NULL` | CPF do cliente (formatado). |
| **`telefone`** | `VARCHAR(30)` | `NOT NULL` | Telefone/WhatsApp de contato. |
| **`email`** | `VARCHAR(120)` | `NOT NULL` | E-mail do cliente. |
| **`advogado_id`** | `INTEGER` | **FK** (`usuarios.id`), `NOT NULL` | Advogado responsável pelo atendimento. |
| **`criado_em`** | `TIMESTAMP` | `DEFAULT UTC` | Data de cadastro. |

---

### 📌 Tabela: `processos`
Armazena as ações judiciais, status e metadados recuperados do CNJ Datajud.

| Campo | Tipo de Dado | Restrições | Descrição |
| :--- | :--- | :--- | :--- |
| **`id`** | `INTEGER` | **PK**, Auto-incremento | Identificador interno do processo. |
| **`numero_processo`**| `VARCHAR(30)` | `UNIQUE`, `NOT NULL`, `INDEX` | Numeração Única CNJ (20 dígitos). |
| **`descricao`** | `TEXT` | `NOT NULL` | Descrição/Resumo da ação jurídica. |
| **`status`** | `VARCHAR(50)` | `NOT NULL` | Status (*Em andamento, Concluído, etc.*). |
| **`cliente_id`** | `INTEGER` | **FK** (`clientes.id`), `NOT NULL` | Cliente polo da ação. |
| **`advogado_id`** | `INTEGER` | **FK** (`usuarios.id`), `NOT NULL` | Advogado condutor do processo. |
| **`tribunal`** | `VARCHAR(50)` | `NULLABLE` | Sigla do Tribunal obtida via API CNJ. |
| **`classe_processual`**| `VARCHAR(100)`| `NULLABLE` | Classe TPU obtida via Datajud. |
| **`orgao_julgador`**| `VARCHAR(150)`| `NULLABLE` | Vara/Serventia judiciária. |
| **`data_ajuizamento`**| `TIMESTAMP` | `NULLABLE` | Data de distribuição/ajuizamento no tribunal. |
| **`criado_em`** | `TIMESTAMP` | `DEFAULT UTC` | Data do registro no sistema. |

---

### 📌 Tabela: `historicos_processos`
Armazena a linha do tempo e movimentações do processo (CNJ Datajud ou Manuais).

| Campo | Tipo de Dado | Restrições | Descrição |
| :--- | :--- | :--- | :--- |
| **`id`** | `INTEGER` | **PK**, Auto-incremento | Identificador da movimentação. |
| **`processo_id`** | `INTEGER` | **FK** (`processos.id`), `NOT NULL` | Processo associado (exclusão em cascata). |
| **`data_hora`** | `TIMESTAMP` | `NOT NULL` | Data e hora da ocorrência. |
| **`origem`** | `VARCHAR(30)` | `NOT NULL` | Origem do dado (*"CNJ Datajud"* ou *"Manual"*). |
| **`nome_movimento`**| `VARCHAR(150)`| `NOT NULL` | Nome/Título do andamento. |
| **`descricao_detalhada`**| `TEXT` | `NULLABLE` | Detalhes e complementos tabelados TPU. |

---

### 📌 Tabela: `agendamentos`
Armazena reuniões, prazos da agenda e a respectiva Ata de Reunião.

| Campo | Tipo de Dado | Restrições | Descrição |
| :--- | :--- | :--- | :--- |
| **`id`** | `INTEGER` | **PK**, Auto-incremento | Identificador do agendamento. |
| **`titulo`** | `VARCHAR(150)` | `NOT NULL` | Título do compromisso/pauta. |
| **`descricao`** | `TEXT` | `NOT NULL` | Pauta e observações. |
| **`data_hora`** | `TIMESTAMP` | `NOT NULL` | Data e hora agendadas. |
| **`advogado_id`** | `INTEGER` | **FK** (`usuarios.id`), `NOT NULL` | Advogado participante/responsável. |
| **`cliente_id`** | `INTEGER` | **FK** (`clientes.id`), `NULLABLE` | Cliente participante do agendamento. |
| **`ata_reuniao`** | `TEXT` | `NULLABLE` | Campo de texto longo para a Ata da Reunião. |
| **`criado_em`** | `TIMESTAMP` | `DEFAULT UTC` | Data de criação. |

---

## 3. Mapeamento de Relacionamentos e Cardinalidade

Os relacionamentos utilizam **Chaves Primárias (PK)** e **Chaves Estrangeiras (FK)** para interligar as entidades:

* **`usuarios` 1 : N `clientes`**:
  * **Cardinalidade**: 1 : N (Um para Muitos).
  * **Regra**: Um advogado pode atender múltiplos clientes, mas cada cliente está vinculado a exatamente 1 advogado responsável.
* **`usuarios` 1 : N `processos`**:
  * **Cardinalidade**: 1 : N (Um para Muitos).
  * **Regra**: Um advogado conduz vários processos judiciais no escritório.
* **`clientes` 1 : N `processos`**:
  * **Cardinalidade**: 1 : N (Um para Muitos).
  * **Regra**: Um cliente pode possuir diversas ações judiciais cadastas.
* **`processos` 1 : N `historicos_processos`**:
  * **Cardinalidade**: 1 : N (Um para Muitos).
  * **Regra**: Um processo possui uma linha do tempo com múltiplos andamentos e movimentações.
* **`usuarios` 1 : N `agendamentos`**:
  * **Cardinalidade**: 1 : N (Um para Muitos).
  * **Regra**: Um advogado gerencia vários compromissos na sua agenda.
* **`clientes` 1 : N `agendamentos`**:
  * **Cardinalidade**: 1 : N (Um para Muitos).
  * **Regra**: Um cliente pode ter vários agendamentos de reuniões ao longo do tempo.

---

## 4. Análise das 3 Formas Normais (1FN, 2FN e 3FN)

A modelagem do banco de dados atende rigorosamente aos critérios das três primeiras formas normais da teoria de bancos de dados relacionais [22, 38, 41]:

### 🟢 1ª Forma Normal (1FN) — Atomicidade e Ausência de Grupos Repetitivos
* **Valores Atômicos**: Todos os campos armazenam valores indivisíveis em suas células (ex.: `nome`, `email`, `cpf`, `status`).
* **Sem Grupos Repetitivos**: Os andamentos de um processo não foram modelados como colunas repetidas (`movimento_1`, `movimento_2`) na tabela `processos`; em vez disso, criou-se a tabela individual `historicos_processos`.
* **Chave Primária**: Todas as tabelas possuem uma PK explícita e única (`id`).

### 🟢 2ª Forma Normal (2FN) — Dependência Funcional Total
* **Cumprimento da 1FN**: O banco de dados está na 1FN.
* **Sem Dependências Parciais**: Todas as tabelas possuem Chave Primária simples (coluna única `id`). Como não há chaves primárias compostas, todos os atributos não-chave dependem funcionalmente da totalidade da chave primária da tabela.

### 🟢 3ª Forma Normal (3FN) — Ausência de Dependências Transitivas
* **Cumprimento da 2FN**: O banco de dados está na 2FN.
* **Eliminação de Atributos Redundantes**: Nenhum atributo não-chave depende de outro atributo não-chave.
  * *Exemplo*: Na tabela `clientes`, guarda-se apenas a chave estrangeira `advogado_id`. O nome e e-mail do advogado não são duplicados na tabela do cliente, sendo recuperados via `JOIN` relacional com a tabela `usuarios`.
  * *Exemplo*: Na tabela `processos`, o nome do cliente e do advogado não são salvos como colunas estáticas; mantém-se apenas `cliente_id` e `advogado_id`.

---

## 5. Hierarquia, Regras de Integridade e Isolamento (RBAC)

O banco de dados sustenta a lógica de **Controle de Acesso Baseado em Funções (RBAC)** e regras de integridade do sistema:

1. **Perfil Master (`tipo = 'master'`)**:
   * Possui visibilidade global no banco de dados.
   * Pode executar operações de leitura, alteração de status (`ativo = True/False`) e escrita em qualquer registro de todas as tabelas.
2. **Perfil Advogado (`tipo = 'advogado'`)**:
   * Restrito ao escopo do seu próprio `id`.
   * As consultas SQL aplicam filtros automáticos (`WHERE advogado_id = current_user.id`), garantindo que o profissional acesse exclusivamente os clientes, processos e agendamentos sob sua responsabilidade.
3. **Integridade Referencial e Deleção em Cascata**:
   * A exclusão de um registro pai (ex.: `Processo`) aciona a limpeza automática dos seus filhos (`historicos_processos`), evitando registros órfãos no banco de dados.
