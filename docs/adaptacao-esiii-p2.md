# Adaptação ao ESIII-P2

## Bounded Contexts
- Operações de Voo (core)
- SoloGate (suporte)
- Notificações (genérico)
- ACL ANAC (externo traduzido)

## Aggregate Root principal
- Voo

## Eventos refletidos no código
- SlotConfirmado
- SlotLiberado
- GateAtribuido
- AutorizacaoRecebida

## Serviços de domínio previstos
- AlocadorDeSlot
- AtribuidorDeGate
- VerificadorDeConflito
- TradutorAnacAcl
- CalculadorDeConformidadeDeUso
- GestorDePrioridadeHistorica
