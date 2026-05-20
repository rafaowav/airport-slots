using AirportSlots.Domain;
using Microsoft.Data.SqlClient;

namespace AirportSlots.Infrastructure;

public class SeasonUsageRepository
{
    private readonly SqlConnectionFactory _factory;

    public SeasonUsageRepository(SqlConnectionFactory factory)
    {
        _factory = factory;
    }

    public IEnumerable<SeasonUsageDto> GetAll()
    {
        var result = new List<SeasonUsageDto>();
        using var connection = _factory.Create();
        connection.Open();
        using var cmd = new SqlCommand("SELECT SeasonId, AirlineId, TotalSlots, UsedSlots, UsagePercent FROM dbo.vw_SeasonUsageSummary ORDER BY UsagePercent DESC;", connection);
        using var reader = cmd.ExecuteReader();
        while (reader.Read())
        {
            result.Add(new SeasonUsageDto
            {
                SeasonId = reader.GetGuid(0),
                AirlineId = reader.GetGuid(1),
                TotalSlots = reader.GetInt32(2),
                UsedSlots = reader.GetInt32(3),
                UsagePercent = reader.IsDBNull(4) ? 0 : reader.GetDecimal(4)
            });
        }
        return result;
    }
}
