namespace AirportSlots.Domain;

public class SeasonUsageDto
{
    public Guid SeasonId { get; set; }
    public Guid AirlineId { get; set; }
    public int TotalSlots { get; set; }
    public int UsedSlots { get; set; }
    public decimal UsagePercent { get; set; }
}
