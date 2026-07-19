using Prena.BuildingBlocks.SharedKernel.Domain;
using Prena.BuildingBlocks.SharedKernel.Abstractions;


namespace Prena.BuildingBlocks.SharedKernel.Tests.AggregateRootTests;



public class AggregateRootTests
{


    private record TestEvent() : IDomainEvent
    {
        public DateTime OccurredOn { get; } =
            DateTime.UtcNow;
    }



    private class TestAggregate : AggregateRoot
    {

        public void RaiseEvent()
        {
            AddDomainEvent(
                new TestEvent());
        }

    }



    [Fact]
    public void Aggregate_Should_Store_Domain_Event()
    {

        var aggregate =
            new TestAggregate();


        aggregate.RaiseEvent();


        Assert.Single(
            aggregate.DomainEvents);

    }

}
