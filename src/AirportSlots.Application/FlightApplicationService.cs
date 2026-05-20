using AirportSlots.Domain;
using AirportSlots.Infrastructure;

namespace AirportSlots.Application;

public class FlightApplicationService
{
    private readonly FlightRepository _flightRepository;
    private readonly GateRepository _gateRepository;
    private readonly EventRepository _eventRepository;
    private readonly SeasonUsageRepository _seasonUsageRepository;

    public FlightApplicationService(FlightRepository flightRepository, GateRepository gateRepository, EventRepository eventRepository, SeasonUsageRepository seasonUsageRepository)
    {
        _flightRepository = flightRepository;
        _gateRepository = gateRepository;
        _eventRepository = eventRepository;
        _seasonUsageRepository = seasonUsageRepository;
    }

    public IEnumerable<FlightDto> GetFlights() => _flightRepository.GetAll();
    public IEnumerable<GateDto> GetGates() => _gateRepository.GetAll();
    public IEnumerable<DomainEventDto> GetEvents() => _eventRepository.GetAll();
    public IEnumerable<SeasonUsageDto> GetSeasonUsage() => _seasonUsageRepository.GetAll();

    public void ConfirmSlot(Guid flightId, DateTime start, DateTime end)
    {
        var period = new SlotPeriod(start, end);
        _flightRepository.ConfirmSlot(flightId, period);
        _eventRepository.Add(flightId, "SlotConfirmado", $"{{ "inicio": "{start:O}", "fim": "{end:O}" }}");
    }

    public void AssignGate(Guid flightId, string gateCode)
    {
        _gateRepository.AssignGateToFlight(flightId, gateCode);
        _eventRepository.Add(flightId, "GateAtribuido", $"{{ "gateCode": "{gateCode}" }}");
    }

    public void CancelFlight(Guid flightId)
    {
        _flightRepository.Cancel(flightId);
        _eventRepository.Add(flightId, "SlotLiberado", $"{{ "flightId": "{flightId}" }}");
    }
}
