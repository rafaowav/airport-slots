namespace AirportSlots.Domain;

public class FlightDto
{
    public Guid Id { get; set; }
    public string FlightNumber { get; set; } = string.Empty;
    public string StatusName { get; set; } = string.Empty;
    public string? GateCode { get; set; }
    public DateTime? SlotStart { get; set; }
    public DateTime? SlotEnd { get; set; }
}
