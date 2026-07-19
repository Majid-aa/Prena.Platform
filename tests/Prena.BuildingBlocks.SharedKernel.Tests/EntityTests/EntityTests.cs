using Prena.BuildingBlocks.SharedKernel.Common;

namespace Prena.BuildingBlocks.SharedKernel.Tests.EntityTests;


public class EntityTests
{

    private class TestEntity : Entity
    {

    }


    [Fact]
    public void Entity_Should_Create_Id()
    {

        var entity = new TestEntity();


        Assert.NotEqual(
            Guid.Empty,
            entity.Id);

    }



    [Fact]
    public void Different_Entities_Should_Have_Different_Id()
    {

        var first = new TestEntity();

        var second = new TestEntity();


        Assert.NotEqual(
            first.Id,
            second.Id);

    }

}
