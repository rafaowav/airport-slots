using AirportSlots.Application;
using Microsoft.AspNetCore.Mvc;

namespace AirportSlots.Api.Controllers;

[ApiController]
[Route("api/flights")]
public class FlightsController : ControllerBase
{
    private readonly FlightApplicationService _service;

    public FlightsController(FlightApplicationService service)
    {
        _service = service;
    }

    [HttpGet]
    public IActionResult GetAll() => Ok(_service.GetFlights());

    [HttpPost("{id}/confirm-slot")]
    public IActionResult ConfirmSlot(Guid id, [FromBody] ConfirmSlotRequest request)
    {
        _service.ConfirmSlot(id, request.Start, request.End);
        return Ok(new { message = "Slot confirmado com sucesso." });
    }

    [HttpPost("{id}/assign-gate")]
    public IActionResult AssignGate(Guid id, [FromBody] AssignGateRequest request)
    {
        _service.AssignGate(id, request.GateCode);
        return Ok(new { message = "Gate atribuído com sucesso." });
    }

    [HttpPost("{id}/cancel")]
    public IActionResult Cancel(Guid id)
    {
        _service.CancelFlight(id);
        return Ok(new { message = "Voo cancelado com sucesso." });
    }
}

public record ConfirmSlotRequest(DateTime Start, DateTime End);
public record AssignGateRequest(string GateCode);
