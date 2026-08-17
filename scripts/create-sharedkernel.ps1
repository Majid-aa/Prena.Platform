# =====================================================
# Prena Platform
# Create Shared Kernel Structure
# =====================================================


$ProjectPath = ".\src\Prena.BuildingBlocks.SharedKernel"


Write-Host "Creating SharedKernel folders..." -ForegroundColor Green


$Folders = @(
"Abstractions",
"Common",
"Results",
"Exceptions",
"Auditing",
"MultiTenancy"
)


foreach($folder in $Folders)
{
    New-Item `
    -ItemType Directory `
    -Force `
    -Path "$ProjectPath\$folder" | Out-Null
}


Write-Host "Creating base files..." -ForegroundColor Cyan


# Entity

@'
namespace Prena.BuildingBlocks.SharedKernel.Abstractions;

public interface IEntity
{
    Guid Id { get; }
}
'@ | Set-Content `
"$ProjectPath\Abstractions\IEntity.cs"



# Domain Event

@'
namespace Prena.BuildingBlocks.SharedKernel.Abstractions;

public interface IDomainEvent
{
    DateTime OccurredOn { get; }
}
'@ | Set-Content `
"$ProjectPath\Abstractions\IDomainEvent.cs"



# Aggregate Root

@'
namespace Prena.BuildingBlocks.SharedKernel.Abstractions;

public interface IAggregateRoot : IEntity
{

}
'@ | Set-Content `
"$ProjectPath\Abstractions\IAggregateRoot.cs"



# Entity Base

@'
using Prena.BuildingBlocks.SharedKernel.Abstractions;

namespace Prena.BuildingBlocks.SharedKernel.Common;


public abstract class Entity : IEntity
{

    public Guid Id { get; protected set; }


    protected Entity()
    {
        Id = Guid.NewGuid();
    }

}
'@ | Set-Content `
"$ProjectPath\Common\Entity.cs"



# Result

@'
namespace Prena.BuildingBlocks.SharedKernel.Results;


public record Error(
    string Code,
    string Description
);



public class Result
{

    public bool IsSuccess { get; }

    public Error? Error { get; }


    protected Result(
        bool success,
        Error? error)
    {
        IsSuccess = success;
        Error = error;
    }


    public static Result Success()
        => new(true,null);


    public static Result Failure(Error error)
        => new(false,error);

}
'@ | Set-Content `
"$ProjectPath\Results\Result.cs"



# Exception

@'
namespace Prena.BuildingBlocks.SharedKernel.Exceptions;


public class DomainException : Exception
{

    public DomainException(string message)
        : base(message)
    {

    }

}
'@ | Set-Content `
"$ProjectPath\Exceptions\DomainException.cs"



# Auditing

@'
namespace Prena.BuildingBlocks.SharedKernel.Auditing;


public interface IAuditableEntity
{

    DateTime CreatedAt { get; }

    string CreatedBy { get; }

}
'@ | Set-Content `
"$ProjectPath\Auditing\IAuditableEntity.cs"



# Multi Tenancy

@'
namespace Prena.BuildingBlocks.SharedKernel.MultiTenancy;


public interface ITenantEntity
{

    Guid TenantId { get; }

}
'@ | Set-Content `
"$ProjectPath\MultiTenancy\ITenantEntity.cs"



Write-Host ""
Write-Host "SharedKernel Created Successfully." -ForegroundColor Green