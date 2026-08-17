namespace Prena.BuildingBlocks.SharedKernel.Domain.Events;


public abstract record DomainEvent : IDomainEvent
{

    public DateTime OccurredOn { get; init; }


    protected DomainEvent()
    {
        OccurredOn = DateTime.UtcNow;
    }

}
