namespace AirportSlots.Domain;

public class GateDto
{
    public Guid GateId { get; set; }
    public string GateCode { get; set; } = string.Empty;
    public string TerminalCode { get; set; } = string.Empty;
    public string AllowedAircraftCategory { get; set; } = string.Empty;
}
