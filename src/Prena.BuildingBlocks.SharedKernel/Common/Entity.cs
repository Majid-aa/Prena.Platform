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
