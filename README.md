# ESIII-P2 - Sistema de Gestão de Slots Aeroportuários

Sistema desenvolvido para a disciplina de Engenharia de Software III com foco em Domain-Driven Design (DDD) aplicado à Gestão de Slots Aeroportuários.

## Sobre o projeto

Este projeto organiza o domínio em camadas e contextos delimitados para representar a operação de voo, a confirmação de slots, a alocação de gates e o registro de eventos operacionais. O objetivo é demonstrar a separação entre regra de negócio, aplicação, persistência e interface.

## Estrutura do repositório

```text
src/
  AirportSlots.Api/
  AirportSlots.Application/
  AirportSlots.Domain/
  AirportSlots.Infrastructure/
database/
  sqlserver/
tests/
docs/
```

### Camadas do sistema

- `AirportSlots.Domain`: tipos centrais do domínio e regras mais próximas do negócio.
- `AirportSlots.Application`: coordenação dos casos de uso.
- `AirportSlots.Infrastructure`: acesso ao SQL Server.
- `AirportSlots.Api`: endpoints HTTP, Swagger e front-end estático.

## Pré-requisitos

- .NET 8 SDK.
- SQL Server ou SQL Server Express.
- SSMS ou ferramenta equivalente para executar scripts SQL.
- Visual Studio 2022 ou VS Code.

## Banco de dados

1. Abra o SQL Server Management Studio.
2. Execute `database/sqlserver/schema.sql`.
3. Execute `database/sqlserver/seed.sql`.
4. Confirme se o banco criado é `AirportSlotsDb`.

## Connection string

Edite o arquivo:

```text
src/AirportSlots.Api/appsettings.json
```

Exemplo com autenticação SQL Server:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=AirportSlotsDb;User Id=sa;Password=SUA_SENHA;TrustServerCertificate=True;"
  }
}
```

Exemplo com SQL Server Express:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost\SQLEXPRESS;Database=AirportSlotsDb;User Id=sa;Password=SUA_SENHA;TrustServerCertificate=True;"
  }
}
```

## Como executar

### Pelo terminal

Na raiz do projeto:

```bash
dotnet restore
dotnet build
dotnet run --project src/AirportSlots.Api
```

### Pelo Visual Studio

1. Abra `AirportSlots.sln`.
2. Aguarde o restore.
3. Defina `AirportSlots.Api` como projeto de inicialização.
4. Execute com `F5` ou `Ctrl + F5`.

## Como testar

A API fica disponível em:

- `http://localhost:5000/`
- `http://localhost:5000/swagger`
- `http://localhost:5000/health`

### Teste inicial

1. Abra `http://localhost:5000/swagger`.
2. Execute `GET /api/flights`.
3. Verifique se os voos aparecem corretamente.

### Fluxo principal

1. Execute `POST /api/flights/{id}/confirm-slot`.
2. Execute `GET /api/flights` e confira `slotStart`, `slotEnd` e status.
3. Execute `POST /api/flights/{id}/assign-gate`.
4. Execute `GET /api/processes/events`.
5. Execute `POST /api/flights/{id}/cancel`.

### Body de exemplo

#### Confirmar slot

```json
{
  "start": "2026-06-10T10:00:00Z",
  "end": "2026-06-10T11:00:00Z"
}
```

#### Atribuir gate

```json
{
  "gateCode": "A-01"
}
```

## Front-end HTML

A aplicação inclui uma página HTML simples para demonstração, servida pela própria API.

Abra:

```text
http://localhost:5000/
```

Essa tela consome os endpoints da API e ajuda a visualizar os voos, gates e eventos.

## Endpoints principais

### Consultas

- `GET /api/flights`
- `GET /api/processes/gates`
- `GET /api/processes/events`
- `GET /api/processes/season-usage`

### Operações

- `POST /api/flights/{id}/confirm-slot`
- `POST /api/flights/{id}/assign-gate`
- `POST /api/flights/{id}/cancel`

## Observações de domínio

O projeto trata o voo como elemento central do domínio. A confirmação de slot e a alocação de gate foram separadas para representar melhor a lógica operacional do aeroporto.

O banco foi modelado em SQL Server para suportar os fluxos principais do sistema e facilitar a validação prática durante a apresentação.

## Testes automatizados

Para rodar os testes:

```bash
dotnet test
```

## Licença

Projeto acadêmico para fins educacionais.
