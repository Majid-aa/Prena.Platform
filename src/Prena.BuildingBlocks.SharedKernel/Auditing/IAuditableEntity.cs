namespace Prena.BuildingBlocks.SharedKernel.Auditing;


public interface IAuditableEntity
{

    DateTime CreatedAt { get; }

    string CreatedBy { get; }

}
