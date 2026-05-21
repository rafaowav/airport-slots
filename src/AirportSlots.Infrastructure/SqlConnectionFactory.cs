using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;

namespace AirportSlots.Infrastructure;

public class SqlConnectionFactory
{
    private readonly string _connectionString;

    public SqlConnectionFactory(IConfiguration configuration)
    {
        _connectionString = configuration.GetConnectionString("DefaultConnection")
            ?? throw new InvalidOperationException("Connection string 'DefaultConnection' não encontrada.");
    }

    public SqlConnection Create()
    {
        return new SqlConnection(_connectionString);
    }
}