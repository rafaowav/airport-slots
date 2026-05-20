using AirportSlots.Application;
using Microsoft.AspNetCore.Mvc;

namespace AirportSlots.Api.Controllers;

[ApiController]
[Route("api/processes")]
public class ProcessesController : ControllerBase
{
    private readonly FlightApplicationService _service;

    public ProcessesController(FlightApplicationService service)
    {
        _service = service;
    }

    [HttpGet("gates")]
    public IActionResult GetGates() => Ok(_service.GetGates());

    [HttpGet("events")]
    public IActionResult GetEvents() => Ok(_service.GetEvents());

    [HttpGet("season-usage")]
    public IActionResult GetSeasonUsage() => Ok(_service.GetSeasonUsage());
}
