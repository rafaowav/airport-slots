using AirportSlots.Domain;
using Microsoft.Data.SqlClient;

namespace AirportSlots.Infrastructure;

public class EventRepository
{
    private readonly SqlConnectionFactory _factory;

    public EventRepository(SqlConnectionFactory factory)
    {
        _factory = factory;
    }

    public void Add(Guid aggregateId, string eventType, string eventData)
    {
        using var connection = _factory.Create();
        connection.Open();
        var sql = @"
INSERT INTO dbo.DomainEvent (DomainEventId, AggregateId, EventType, EventData, OccurredAtUtc)
VALUES (NEWID(), @AggregateId, @EventType, @EventData, SYSUTCDATETIME());";
        using var cmd = new SqlCommand(sql, connection);
        cmd.Parameters.AddWithValue("@AggregateId", aggregateId);
        cmd.Parameters.AddWithValue("@EventType", eventType);
        cmd.Parameters.AddWithValue("@EventData", eventData);
        cmd.ExecuteNonQuery();
    }

    public IEnumerable<DomainEventDto> GetAll()
    {
        var result = new List<DomainEventDto>();
        using var connection = _factory.Create();
        connection.Open();
        var sql = "SELECT DomainEventId, EventType, EventData, OccurredAtUtc FROM dbo.DomainEvent ORDER BY OccurredAtUtc DESC;";
        using var cmd = new SqlCommand(sql, connection);
        using var reader = cmd.ExecuteReader();
        while (reader.Read())
        {
            result.Add(new DomainEventDto
            {
                DomainEventId = reader.GetGuid(0),
                EventType = reader.GetString(1),
                EventData = reader.GetString(2),
                OccurredAtUtc = reader.GetDateTime(3)
            });
        }
        return result;
    }
}
