using Prena.BuildingBlocks.SharedKernel.Abstractions;

namespace Prena.BuildingBlocks.SharedKernel.Domain;


public abstract class AggregateRoot 
    : Entity,
      IAggregateRoot
{

    private readonly List<IDomainEvent> _events = new();


    public IReadOnlyCollection<IDomainEvent> DomainEvents 
        => _events.AsReadOnly();



    protected void AddDomainEvent(
        IDomainEvent domainEvent)
    {
        _events.Add(domainEvent);
    }



    public void ClearDomainEvents()
    {
        _events.Clear();
    }

}
