using AirportSlots.Application;
using AirportSlots.Infrastructure;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddCors(options =>
{
    options.AddPolicy("Open", policy =>
    {
        policy.AllowAnyOrigin().AllowAnyHeader().AllowAnyMethod();
    });
});

builder.Services.AddSingleton<SqlConnectionFactory>();
builder.Services.AddSingleton<FlightRepository>();
builder.Services.AddSingleton<GateRepository>();
builder.Services.AddSingleton<EventRepository>();
builder.Services.AddSingleton<SeasonUsageRepository>();
builder.Services.AddSingleton<FlightApplicationService>();
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

app.UseCors("Open");
app.UseDefaultFiles();
app.UseStaticFiles();
app.UseSwagger();
app.UseSwaggerUI();
app.MapGet("/health", () => Results.Ok(new { status = "ok", persistence = "sql-server", project = "ESIII-P2" }));
app.MapControllers();
app.Run();
