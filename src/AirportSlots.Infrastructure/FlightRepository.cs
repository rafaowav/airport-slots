using AirportSlots.Domain;
using Microsoft.Data.SqlClient;

namespace AirportSlots.Infrastructure;

public class FlightRepository
{
    private readonly SqlConnectionFactory _factory;

    public FlightRepository(SqlConnectionFactory factory)
    {
        _factory = factory;
    }

    public IEnumerable<FlightDto> GetAll()
    {
        var result = new List<FlightDto>();
        using var connection = _factory.Create();
        connection.Open();

        var sql = @"
SELECT f.FlightId, f.FlightNumber, fs.StatusName, g.GateCode,
       s.StartAtUtc, s.EndAtUtc
FROM dbo.Flight f
INNER JOIN dbo.FlightStatus fs ON fs.FlightStatusId = f.CurrentFlightStatusId
LEFT JOIN dbo.Slot s ON s.SlotId = f.CurrentSlotId
LEFT JOIN dbo.Gate g ON g.GateId = f.CurrentGateId
ORDER BY f.FlightNumber;";

        using var cmd = new SqlCommand(sql, connection);
        using var reader = cmd.ExecuteReader();
        while (reader.Read())
        {
            result.Add(new FlightDto
            {
                Id = reader.GetGuid(0),
                FlightNumber = reader.GetString(1),
                StatusName = reader.GetString(2),
                GateCode = reader.IsDBNull(3) ? null : reader.GetString(3),
                SlotStart = reader.IsDBNull(4) ? null : reader.GetDateTime(4),
                SlotEnd = reader.IsDBNull(5) ? null : reader.GetDateTime(5)
            });
        }
        return result;
    }

    public void ConfirmSlot(Guid flightId, SlotPeriod period)
    {
        using var connection = _factory.Create();
        connection.Open();
        using var transaction = connection.BeginTransaction();

        var slotId = Guid.NewGuid();

        var insertSlot = new SqlCommand(@"
INSERT INTO dbo.Slot (SlotId, FlightId, StartAtUtc, EndAtUtc, IsConfirmed)
VALUES (@SlotId, @FlightId, @StartAtUtc, @EndAtUtc, 1);", connection, transaction);
        insertSlot.Parameters.AddWithValue("@SlotId", slotId);
        insertSlot.Parameters.AddWithValue("@FlightId", flightId);
        insertSlot.Parameters.AddWithValue("@StartAtUtc", period.Start);
        insertSlot.Parameters.AddWithValue("@EndAtUtc", period.End);
        insertSlot.ExecuteNonQuery();

        var updateFlight = new SqlCommand(@"
UPDATE dbo.Flight
SET CurrentSlotId = @SlotId,
    CurrentFlightStatusId = (SELECT FlightStatusId FROM dbo.FlightStatus WHERE StatusName = 'SlotConfirmed')
WHERE FlightId = @FlightId;", connection, transaction);
        updateFlight.Parameters.AddWithValue("@SlotId", slotId);
        updateFlight.Parameters.AddWithValue("@FlightId", flightId);
        updateFlight.ExecuteNonQuery();

        var history = new SqlCommand(@"
INSERT INTO dbo.FlightStatusHistory (FlightStatusHistoryId, FlightId, FlightStatusId, ChangedAtUtc)
VALUES (NEWID(), @FlightId, (SELECT FlightStatusId FROM dbo.FlightStatus WHERE StatusName = 'SlotConfirmed'), SYSUTCDATETIME());", connection, transaction);
        history.Parameters.AddWithValue("@FlightId", flightId);
        history.ExecuteNonQuery();

        transaction.Commit();
    }

    public void Cancel(Guid flightId)
    {
        using var connection = _factory.Create();
        connection.Open();
        using var transaction = connection.BeginTransaction();

        var update = new SqlCommand(@"
UPDATE dbo.Flight
SET CurrentFlightStatusId = (SELECT FlightStatusId FROM dbo.FlightStatus WHERE StatusName = 'Cancelled')
WHERE FlightId = @FlightId;", connection, transaction);
        update.Parameters.AddWithValue("@FlightId", flightId);
        update.ExecuteNonQuery();

        var history = new SqlCommand(@"
INSERT INTO dbo.FlightStatusHistory (FlightStatusHistoryId, FlightId, FlightStatusId, ChangedAtUtc)
VALUES (NEWID(), @FlightId, (SELECT FlightStatusId FROM dbo.FlightStatus WHERE StatusName = 'Cancelled'), SYSUTCDATETIME());", connection, transaction);
        history.Parameters.AddWithValue("@FlightId", flightId);
        history.ExecuteNonQuery();

        transaction.Commit();
    }
}
