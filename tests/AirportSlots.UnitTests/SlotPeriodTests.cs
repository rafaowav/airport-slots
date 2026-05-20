using AirportSlots.Domain;
using Xunit;

namespace AirportSlots.UnitTests;

public class SlotPeriodTests
{
    [Fact]
    public void DeveFalharQuandoFimForMenorOuIgualAoInicio()
    {
        Assert.Throws<InvalidOperationException>(() => new SlotPeriod(DateTime.UtcNow.AddHours(2), DateTime.UtcNow.AddHours(1)));
    }
}
