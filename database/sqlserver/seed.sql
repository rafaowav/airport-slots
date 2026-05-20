USE AirportSlotsDb;
GO
DECLARE @Azul UNIQUEIDENTIFIER = NEWID(), @Gol UNIQUEIDENTIFIER = NEWID();
DECLARE @Medium UNIQUEIDENTIFIER = NEWID(), @Large UNIQUEIDENTIFIER = NEWID();
DECLARE @A1 UNIQUEIDENTIFIER = NEWID(), @A2 UNIQUEIDENTIFIER = NEWID();
DECLARE @Gru UNIQUEIDENTIFIER = NEWID(), @Bsb UNIQUEIDENTIFIER = NEWID(), @Gig UNIQUEIDENTIFIER = NEWID();
DECLARE @T1 UNIQUEIDENTIFIER = NEWID();
DECLARE @GateA01 UNIQUEIDENTIFIER = NEWID(), @GateA02 UNIQUEIDENTIFIER = NEWID();
DECLARE @Team1 UNIQUEIDENTIFIER = NEWID(), @Team2 UNIQUEIDENTIFIER = NEWID();
DECLARE @Season UNIQUEIDENTIFIER = NEWID();
DECLARE @Scheduled UNIQUEIDENTIFIER = NEWID(), @SlotConfirmed UNIQUEIDENTIFIER = NEWID(), @GateAssigned UNIQUEIDENTIFIER = NEWID(), @Cancelled UNIQUEIDENTIFIER = NEWID();
DECLARE @Flight1 UNIQUEIDENTIFIER = NEWID(), @Flight2 UNIQUEIDENTIFIER = NEWID();
DECLARE @Slot1 UNIQUEIDENTIFIER = NEWID();

INSERT INTO dbo.Airline VALUES (@Azul,'AZU','Azul Linhas Aéreas',1),(@Gol,'GLO','Gol Linhas Aéreas',1);
INSERT INTO dbo.AircraftCategory VALUES (@Medium,'Medium'),(@Large,'Large');
INSERT INTO dbo.Aircraft VALUES (@A1,'PR-ABC','Airbus A320',@Medium,'Ativa'),(@A2,'PR-GOL','Boeing 737',@Medium,'Ativa');
INSERT INTO dbo.Airport VALUES (@Gru,'GRU','Aeroporto Internacional de São Paulo','Guarulhos',3),(@Bsb,'BSB','Aeroporto Internacional de Brasília','Brasília',3),(@Gig,'GIG','Aeroporto Internacional do Rio de Janeiro','Rio de Janeiro',3);
INSERT INTO dbo.Terminal VALUES (@T1,@Gru,'T1');
INSERT INTO dbo.Gate VALUES (@GateA01,@T1,'A-01',@Medium,'Disponivel'),(@GateA02,@T1,'A-02',@Medium,'Disponivel');
INSERT INTO dbo.SupportTeam VALUES (@Team1,'TEAM-01','Disponivel',@T1),(@Team2,'TEAM-02','Disponivel',@T1);
INSERT INTO dbo.Season VALUES (@Season,'S26-WINTER','2026-06-01','2026-10-31');
INSERT INTO dbo.FlightStatus VALUES (@Scheduled,'Scheduled'),(@SlotConfirmed,'SlotConfirmed'),(@GateAssigned,'GateAssigned'),(@Cancelled,'Cancelled');
INSERT INTO dbo.Flight (FlightId,AirlineId,AircraftId,OriginAirportId,DestinationAirportId,SeasonId,FlightNumber,ScheduledDepartureUtc,ScheduledArrivalUtc,CurrentFlightStatusId)
VALUES
(@Flight1,@Azul,@A1,@Gru,@Bsb,@Season,'AZU1010',DATEADD(HOUR,2,SYSUTCDATETIME()),DATEADD(HOUR,4,SYSUTCDATETIME()),@Scheduled),
(@Flight2,@Gol,@A2,@Gru,@Gig,@Season,'GLO2020',DATEADD(HOUR,3,SYSUTCDATETIME()),DATEADD(HOUR,5,SYSUTCDATETIME()),@Scheduled);
INSERT INTO dbo.Slot (SlotId,AirportId,SeasonId,StartAtUtc,EndAtUtc,SlotStatus,CurrentFlightId,IsHistoricalPriority)
VALUES (@Slot1,@Gru,@Season,DATEADD(HOUR,2,SYSUTCDATETIME()),DATEADD(HOUR,3,SYSUTCDATETIME()),'Disponivel',NULL,1);
INSERT INTO dbo.AnacAuthorization (AnacAuthorizationId,AirlineId,AirportId,SeasonId,ExternalReference,AuthorizationType,AuthorizedStartUtc,AuthorizedEndUtc)
VALUES (NEWID(),@Azul,@Gru,@Season,'ANAC-AUTH-001','AutorizacaoDeSlot',DATEADD(HOUR,2,SYSUTCDATETIME()),DATEADD(HOUR,3,SYSUTCDATETIME()));
GO
