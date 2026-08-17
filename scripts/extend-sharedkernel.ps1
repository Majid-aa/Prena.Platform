# =====================================================
# Prena Platform
# Extend Shared Kernel v0.1
# =====================================================


$Project = ".\src\Prena.BuildingBlocks.SharedKernel"


Write-Host "Extending Shared Kernel..." -ForegroundColor Green


# Create folders

$Folders = @(

"Domain",
"Domain\Events",
"Metadata",
"Identity"

)


foreach($folder in $Folders)
{

New-Item `
-ItemType Directory `
-Force `
-Path "$Project\$folder" | Out-Null

}



# Domain Event Base

@'
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



# Aggregate Root

@'
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
'@ | Set-Content `
"$Project\Domain\AggregateRoot.cs"



# Metadata

@'
namespace Prena.BuildingBlocks.SharedKernel.Metadata;


public interface IMetadataEntity
{

    string? MetadataJson { get; }

}
'@ | Set-Content `
"$Project\Metadata\IMetadataEntity.cs"



# User Identity

@'
namespace Prena.BuildingBlocks.SharedKernel.Identity;


public interface ICreatedBy
{

    string CreatedBy { get; }

}
'@ | Set-Content `
"$Project\Identity\ICreatedBy.cs"



Write-Host ""
Write-Host "Shared Kernel Extended Successfully." -ForegroundColor Green