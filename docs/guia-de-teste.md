# Guia de Teste

## Teste 1 - Subir a API
- executar o schema
- executar o seed
- iniciar a API
- abrir `/swagger`

## Teste 2 - Listar voos
- GET `/api/flights`
- deve retornar os voos sem erro

## Teste 3 - Confirmar slot
- escolher um `flightId`
- POST `/api/flights/{id}/confirm-slot`
- corpo:
```json
{
  "start": "2026-06-10T10:00:00Z",
  "end": "2026-06-10T11:00:00Z"
}
```

## Teste 4 - Atribuir gate
- POST `/api/flights/{id}/assign-gate`
- corpo:
```json
{
  "gateCode": "A-01"
}
```

## Teste 5 - Cancelar voo
- POST `/api/flights/{id}/cancel`

## Teste 6 - Eventos
- GET `/api/processes/events`

## Teste 7 - Regra de temporada
- GET `/api/processes/season-usage`
