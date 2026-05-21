namespace AirportSlots.Domain;

public class SlotPeriod
{
    public DateTime Start { get; }
    public DateTime End { get; }

    public SlotPeriod(DateTime start, DateTime end)
    {
        if (end <= start)
        {
            throw new ArgumentException("O fim do período deve ser maior que o início.");
        }

        Start = start;
        End = end;
    }
}