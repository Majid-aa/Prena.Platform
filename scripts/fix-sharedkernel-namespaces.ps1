# =====================================================
# Prena Platform
# Fix SharedKernel namespaces
# =====================================================


$Project = ".\src\Prena.BuildingBlocks.SharedKernel"


Write-Host "Fixing SharedKernel namespaces..." -ForegroundColor Green



# AggregateRoot

@'
using Prena.BuildingBlocks.SharedKernel.Abstractions;
using Prena.BuildingBlocks.SharedKernel.Common;

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
'@ | Set-Content `
"$Project\Domain\AggregateRoot.cs"



# Domain Event

@'
using Prena.BuildingBlocks.SharedKernel.Abstractions;

namespace Prena.BuildingBlocks.SharedKernel.Domain.Events;


public abstract record DomainEvent : IDomainEvent
{

    public DateTime OccurredOn { get; init; }


    protected DomainEvent()
    {
        OccurredOn = DateTime.UtcNow;
    }

}
'@ | Set-Content `
"$Project\Domain\Events\DomainEvent.cs"



Write-Host "Namespace fix completed." -ForegroundColor Green