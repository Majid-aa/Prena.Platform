using Prena.BuildingBlocks.SharedKernel.Domain.Events;


namespace Prena.BuildingBlocks.SharedKernel.Tests.DomainEventTests;



public class DomainEventTests
{


    private record TestEvent : DomainEvent
    {

    }



    [Fact]
    public void DomainEvent_Should_Set_Occurred_Date()
    {

        var item =
            new TestEvent();


        Assert.NotEqual(
            default,
            item.OccurredOn);

    }

}

