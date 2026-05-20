IF DB_ID('AirportSlotsDb') IS NULL
BEGIN
    CREATE DATABASE AirportSlotsDb;
END
GO
USE AirportSlotsDb;
GO

CREATE TABLE dbo.Airline (
    AirlineId UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
    AirlineCode NVARCHAR(10) NOT NULL UNIQUE,
    AirlineName NVARCHAR(100) NOT NULL,
    IsActive BIT NOT NULL DEFAULT 1
);
GO

CREATE TABLE dbo.AircraftCategory (
    AircraftCategoryId UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
    CategoryName NVARCHAR(30) NOT NULL UNIQUE
);
GO

CREATE TABLE dbo.Aircraft (
    AircraftId UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
    RegistrationCode NVARCHAR(20) NOT NULL UNIQUE,
    ModelName NVARCHAR(60) NOT NULL,
    AircraftCategoryId UNIQUEIDENTIFIER NOT NULL,
    OperationalStatus NVARCHAR(20) NOT NULL,
    CONSTRAINT FK_Aircraft_AircraftCategory FOREIGN KEY (AircraftCategoryId) REFERENCES dbo.AircraftCategory(AircraftCategoryId)
);
GO

CREATE TABLE dbo.Airport (
    AirportId UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
    IataCode NVARCHAR(3) NOT NULL UNIQUE,
    AirportName NVARCHAR(120) NOT NULL,
    CityName NVARCHAR(80) NOT NULL,
    CoordinationLevel TINYINT NOT NULL
);
GO

CREATE TABLE dbo.Terminal (
    TerminalId UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
    AirportId UNIQUEIDENTIFIER NOT NULL,
    TerminalCode NVARCHAR(10) NOT NULL,
    CONSTRAINT FK_Terminal_Airport FOREIGN KEY (AirportId) REFERENCES dbo.Airport(AirportId),
    CONSTRAINT UQ_Terminal UNIQUE (AirportId, TerminalCode)
);
GO

CREATE TABLE dbo.Gate (
    GateId UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
    TerminalId UNIQUEIDENTIFIER NOT NULL,
    GateCode NVARCHAR(10) NOT NULL UNIQUE,
    AllowedAircraftCategoryId UNIQUEIDENTIFIER NOT NULL,
    GateStatus NVARCHAR(20) NOT NULL,
    CONSTRAINT FK_Gate_Terminal FOREIGN KEY (TerminalId) REFERENCES dbo.Terminal(TerminalId),
    CONSTRAINT FK_Gate_AircraftCategory FOREIGN KEY (AllowedAircraftCategoryId) REFERENCES dbo.AircraftCategory(AircraftCategoryId)
);
GO

CREATE TABLE dbo.SupportTeam (
    SupportTeamId UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
    TeamCode NVARCHAR(20) NOT NULL UNIQUE,
    TeamStatus NVARCHAR(20) NOT NULL,
    BaseTerminalId UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT FK_SupportTeam_Terminal FOREIGN KEY (BaseTerminalId) REFERENCES dbo.Terminal(TerminalId)
);
GO

CREATE TABLE dbo.Season (
    SeasonId UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
    SeasonCode NVARCHAR(20) NOT NULL UNIQUE,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    CONSTRAINT CK_Season_Dates CHECK (EndDate > StartDate)
);
GO

CREATE TABLE dbo.FlightStatus (
    FlightStatusId UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
    StatusName NVARCHAR(30) NOT NULL UNIQUE
);
GO

CREATE TABLE dbo.Flight (
    FlightId UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
    AirlineId UNIQUEIDENTIFIER NOT NULL,
    AircraftId UNIQUEIDENTIFIER NOT NULL,
    OriginAirportId UNIQUEIDENTIFIER NOT NULL,
    DestinationAirportId UNIQUEIDENTIFIER NOT NULL,
    SeasonId UNIQUEIDENTIFIER NOT NULL,
    FlightNumber NVARCHAR(20) NOT NULL UNIQUE,
    ScheduledDepartureUtc DATETIME2 NOT NULL,
    ScheduledArrivalUtc DATETIME2 NOT NULL,
    CurrentFlightStatusId UNIQUEIDENTIFIER NOT NULL,
    CurrentSlotId UNIQUEIDENTIFIER NULL,
    CurrentGateId UNIQUEIDENTIFIER NULL,
    CurrentSupportTeamId UNIQUEIDENTIFIER NULL,
    CreatedAtUtc DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_Flight_Airline FOREIGN KEY (AirlineId) REFERENCES dbo.Airline(AirlineId),
    CONSTRAINT FK_Flight_Aircraft FOREIGN KEY (AircraftId) REFERENCES dbo.Aircraft(AircraftId),
    CONSTRAINT FK_Flight_OriginAirport FOREIGN KEY (OriginAirportId) REFERENCES dbo.Airport(AirportId),
    CONSTRAINT FK_Flight_DestinationAirport FOREIGN KEY (DestinationAirportId) REFERENCES dbo.Airport(AirportId),
    CONSTRAINT FK_Flight_Season FOREIGN KEY (SeasonId) REFERENCES dbo.Season(SeasonId),
    CONSTRAINT FK_Flight_FlightStatus FOREIGN KEY (CurrentFlightStatusId) REFERENCES dbo.FlightStatus(FlightStatusId),
    CONSTRAINT CK_Flight_Schedule CHECK (ScheduledArrivalUtc > ScheduledDepartureUtc)
);
GO

CREATE TABLE dbo.Slot (
    SlotId UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
    AirportId UNIQUEIDENTIFIER NOT NULL,
    SeasonId UNIQUEIDENTIFIER NOT NULL,
    StartAtUtc DATETIME2 NOT NULL,
    EndAtUtc DATETIME2 NOT NULL,
    SlotStatus NVARCHAR(20) NOT NULL,
    CurrentFlightId UNIQUEIDENTIFIER NULL,
    IsHistoricalPriority BIT NOT NULL DEFAULT 0,
    CreatedAtUtc DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_Slot_Airport FOREIGN KEY (AirportId) REFERENCES dbo.Airport(AirportId),
    CONSTRAINT FK_Slot_Season FOREIGN KEY (SeasonId) REFERENCES dbo.Season(SeasonId),
    CONSTRAINT FK_Slot_CurrentFlight FOREIGN KEY (CurrentFlightId) REFERENCES dbo.Flight(FlightId),
    CONSTRAINT CK_Slot_Period CHECK (EndAtUtc > StartAtUtc)
);
GO

ALTER TABLE dbo.Flight ADD CONSTRAINT FK_Flight_CurrentSlot FOREIGN KEY (CurrentSlotId) REFERENCES dbo.Slot(SlotId);
ALTER TABLE dbo.Flight ADD CONSTRAINT FK_Flight_CurrentGate FOREIGN KEY (CurrentGateId) REFERENCES dbo.Gate(GateId);
ALTER TABLE dbo.Flight ADD CONSTRAINT FK_Flight_CurrentSupportTeam FOREIGN KEY (CurrentSupportTeamId) REFERENCES dbo.SupportTeam(SupportTeamId);
GO

CREATE TABLE dbo.GateAllocation (
    GateAllocationId UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
    GateId UNIQUEIDENTIFIER NOT NULL,
    FlightId UNIQUEIDENTIFIER NOT NULL,
    SupportTeamId UNIQUEIDENTIFIER NULL,
    StartAtUtc DATETIME2 NOT NULL,
    EndAtUtc DATETIME2 NOT NULL,
    AllocationStatus NVARCHAR(20) NOT NULL,
    CONSTRAINT FK_GateAllocation_Gate FOREIGN KEY (GateId) REFERENCES dbo.Gate(GateId),
    CONSTRAINT FK_GateAllocation_Flight FOREIGN KEY (FlightId) REFERENCES dbo.Flight(FlightId),
    CONSTRAINT FK_GateAllocation_SupportTeam FOREIGN KEY (SupportTeamId) REFERENCES dbo.SupportTeam(SupportTeamId),
    CONSTRAINT CK_GateAllocation_Period CHECK (EndAtUtc > StartAtUtc)
);
GO

CREATE TABLE dbo.FlightStatusHistory (
    FlightStatusHistoryId UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
    FlightId UNIQUEIDENTIFIER NOT NULL,
    FlightStatusId UNIQUEIDENTIFIER NOT NULL,
    ChangedAtUtc DATETIME2 NOT NULL,
    CONSTRAINT FK_FlightStatusHistory_Flight FOREIGN KEY (FlightId) REFERENCES dbo.Flight(FlightId),
    CONSTRAINT FK_FlightStatusHistory_FlightStatus FOREIGN KEY (FlightStatusId) REFERENCES dbo.FlightStatus(FlightStatusId)
);
GO

CREATE TABLE dbo.AnacAuthorization (
    AnacAuthorizationId UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
    AirlineId UNIQUEIDENTIFIER NOT NULL,
    AirportId UNIQUEIDENTIFIER NOT NULL,
    SeasonId UNIQUEIDENTIFIER NOT NULL,
    ExternalReference NVARCHAR(50) NOT NULL,
    AuthorizationType NVARCHAR(30) NOT NULL,
    AuthorizedStartUtc DATETIME2 NOT NULL,
    AuthorizedEndUtc DATETIME2 NOT NULL,
    ImportedAtUtc DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_AnacAuthorization_Airline FOREIGN KEY (AirlineId) REFERENCES dbo.Airline(AirlineId),
    CONSTRAINT FK_AnacAuthorization_Airport FOREIGN KEY (AirportId) REFERENCES dbo.Airport(AirportId),
    CONSTRAINT FK_AnacAuthorization_Season FOREIGN KEY (SeasonId) REFERENCES dbo.Season(SeasonId)
);
GO

CREATE TABLE dbo.SlotUsage (
    SlotUsageId UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
    FlightId UNIQUEIDENTIFIER NOT NULL,
    SlotId UNIQUEIDENTIFIER NOT NULL,
    SeasonId UNIQUEIDENTIFIER NOT NULL,
    AirlineId UNIQUEIDENTIFIER NOT NULL,
    WasUsed BIT NOT NULL,
    RecordedAtUtc DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_SlotUsage_Flight FOREIGN KEY (FlightId) REFERENCES dbo.Flight(FlightId),
    CONSTRAINT FK_SlotUsage_Slot FOREIGN KEY (SlotId) REFERENCES dbo.Slot(SlotId),
    CONSTRAINT FK_SlotUsage_Season FOREIGN KEY (SeasonId) REFERENCES dbo.Season(SeasonId),
    CONSTRAINT FK_SlotUsage_Airline FOREIGN KEY (AirlineId) REFERENCES dbo.Airline(AirlineId)
);
GO

CREATE TABLE dbo.DomainEvent (
    DomainEventId UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
    AggregateId UNIQUEIDENTIFIER NOT NULL,
    EventType NVARCHAR(100) NOT NULL,
    EventData NVARCHAR(MAX) NOT NULL,
    OccurredAtUtc DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

CREATE VIEW dbo.vw_SeasonUsageSummary AS
SELECT su.SeasonId, su.AirlineId,
       COUNT(*) AS TotalSlots,
       SUM(CASE WHEN su.WasUsed = 1 THEN 1 ELSE 0 END) AS UsedSlots,
       CAST((100.0 * SUM(CASE WHEN su.WasUsed = 1 THEN 1 ELSE 0 END)) / NULLIF(COUNT(*), 0) AS DECIMAL(5,2)) AS UsagePercent
FROM dbo.SlotUsage su
GROUP BY su.SeasonId, su.AirlineId;
GO

CREATE INDEX IX_Flight_CurrentFlightStatusId ON dbo.Flight(CurrentFlightStatusId);
CREATE INDEX IX_Flight_SeasonId ON dbo.Flight(SeasonId);
CREATE INDEX IX_Slot_CurrentFlightId ON dbo.Slot(CurrentFlightId);
CREATE INDEX IX_GateAllocation_GateId ON dbo.GateAllocation(GateId);
CREATE INDEX IX_GateAllocation_FlightId ON dbo.GateAllocation(FlightId);
CREATE INDEX IX_SlotUsage_SeasonId ON dbo.SlotUsage(SeasonId);
CREATE INDEX IX_DomainEvent_AggregateId ON dbo.DomainEvent(AggregateId);
GO
