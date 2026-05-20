namespace AirportSlots.Domain;

public class DomainEventDto
{
    public Guid DomainEventId { get; set; }
    public string EventType { get; set; } = string.Empty;
    public string EventData { get; set; } = string.Empty;
    public DateTime OccurredAtUtc { get; set; }
}
