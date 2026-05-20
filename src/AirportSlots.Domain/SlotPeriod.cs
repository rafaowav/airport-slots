namespace AirportSlots.Domain;

public record SlotPeriod(DateTime Start, DateTime End)
{
    public SlotPeriod : this()
    {
        if (End <= Start)
            throw new InvalidOperationException("O fim do período deve ser maior que o início.");
    }
}
