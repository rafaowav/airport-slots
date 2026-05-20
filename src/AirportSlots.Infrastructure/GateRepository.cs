using AirportSlots.Domain;
using Microsoft.Data.SqlClient;

namespace AirportSlots.Infrastructure;

public class GateRepository
{
    private readonly SqlConnectionFactory _factory;

    public GateRepository(SqlConnectionFactory factory)
    {
        _factory = factory;
    }

    public IEnumerable<GateDto> GetAll()
    {
        var result = new List<GateDto>();
        using var connection = _factory.Create();
        connection.Open();

        var sql = @"
SELECT g.GateId, g.GateCode, t.TerminalCode, ac.CategoryName
FROM dbo.Gate g
INNER JOIN dbo.Terminal t ON t.TerminalId = g.TerminalId
INNER JOIN dbo.AircraftCategory ac ON ac.AircraftCategoryId = g.AllowedAircraftCategoryId
ORDER BY t.TerminalCode, g.GateCode;";

        using var cmd = new SqlCommand(sql, connection);
        using var reader = cmd.ExecuteReader();
        while (reader.Read())
        {
            result.Add(new GateDto
            {
                GateId = reader.GetGuid(0),
                GateCode = reader.GetString(1),
                TerminalCode = reader.GetString(2),
                AllowedAircraftCategory = reader.GetString(3)
            });
        }
        return result;
    }

    public void AssignGateToFlight(Guid flightId, string gateCode)
    {
        using var connection = _factory.Create();
        connection.Open();
        using var transaction = connection.BeginTransaction();

        var gateIdCommand = new SqlCommand("SELECT GateId FROM dbo.Gate WHERE GateCode = @GateCode;", connection, transaction);
        gateIdCommand.Parameters.AddWithValue("@GateCode", gateCode);
        var gateId = (Guid?)gateIdCommand.ExecuteScalar() ?? throw new InvalidOperationException("Gate não encontrado.");

        var updateFlight = new SqlCommand(@"
UPDATE dbo.Flight
SET CurrentGateId = @GateId,
    CurrentFlightStatusId = (SELECT FlightStatusId FROM dbo.FlightStatus WHERE StatusName = 'GateAssigned')
WHERE FlightId = @FlightId;", connection, transaction);
        updateFlight.Parameters.AddWithValue("@GateId", gateId);
        updateFlight.Parameters.AddWithValue("@FlightId", flightId);
        updateFlight.ExecuteNonQuery();

        var insertReservation = new SqlCommand(@"
INSERT INTO dbo.GateReservation (GateReservationId, GateId, FlightId, ReservedAtUtc)
VALUES (NEWID(), @GateId, @FlightId, SYSUTCDATETIME());", connection, transaction);
        insertReservation.Parameters.AddWithValue("@GateId", gateId);
        insertReservation.Parameters.AddWithValue("@FlightId", flightId);
        insertReservation.ExecuteNonQuery();

        var history = new SqlCommand(@"
INSERT INTO dbo.FlightStatusHistory (FlightStatusHistoryId, FlightId, FlightStatusId, ChangedAtUtc)
VALUES (NEWID(), @FlightId, (SELECT FlightStatusId FROM dbo.FlightStatus WHERE StatusName = 'GateAssigned'), SYSUTCDATETIME());", connection, transaction);
        history.Parameters.AddWithValue("@FlightId", flightId);
        history.ExecuteNonQuery();

        transaction.Commit();
    }
}
