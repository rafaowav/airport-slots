# Modelagem Relacional

## Objetivo
Normalizar o banco para evitar redundância, melhorar integridade e tornar mais clara a separação entre entidades do domínio.

## Tabelas principais
- Airline
- AircraftCategory
- Aircraft
- Airport
- Terminal
- Gate
- FlightStatus
- Flight
- Slot
- GateReservation
- FlightStatusHistory
- DomainEvent

## Motivos da normalização
- status fica separado para evitar repetição textual;
- categoria de aeronave fica separada para reuso e integridade;
- terminal e aeroporto ficam separados para refletir a estrutura física real;
- slot, reserva de gate e histórico de status ficam em tabelas próprias porque representam eventos e relações de negócio com ciclo de vida próprio.
