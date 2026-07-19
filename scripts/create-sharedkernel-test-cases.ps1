# =====================================================
# Prena Platform
# SharedKernel Test Cases Generator
# =====================================================


$TestProject = ".\tests\Prena.BuildingBlocks.SharedKernel.Tests"


Write-Host "Creating SharedKernel Test Structure..." -ForegroundColor Green


$Folders = @(
"EntityTests",
"ResultTests",
"AggregateRootTests",
"DomainEventTests"
)


foreach($folder in $Folders)
{
    New-Item `
    -ItemType Directory `
    -Force `
    -Path "$TestProject\$folder" | Out-Null
}



Write-Host "Generating test files..." -ForegroundColor Cyan



# Entity Tests

@'
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
'@ | Set-Content `
"$TestProject\EntityTests\EntityTests.cs"



# Result Tests

@'
using Prena.BuildingBlocks.SharedKernel.Results;


namespace Prena.BuildingBlocks.SharedKernel.Tests.ResultTests;


public class ResultTests
{


    [Fact]
    public void Success_Result_Should_Be_Successful()
    {

        var result = Result.Success();


        Assert.True(result.IsSuccess);

        Assert.Null(result.Error);

    }



    [Fact]
    public void Failure_Result_Should_Contain_Error()
    {

        var error = new Error(
            "TEST_ERROR",
            "Test error");


        var result =
            Result.Failure(error);



        Assert.False(result.IsSuccess);

        Assert.Equal(
            error,
            result.Error);

    }

}
'@ | Set-Content `
"$TestProject\ResultTests\ResultTests.cs"




# Aggregate Root Tests

@'
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
'@ | Set-Content `
"$TestProject\AggregateRootTests\AggregateRootTests.cs"



# Domain Event Tests

@'
using Prena.BuildingBlocks.SharedKernel.Domain.Events;


namespace Prena.BuildingBlocks.SharedKernel.Tests.DomainEventTests;



public class DomainEventTests
{


    private class TestEvent : DomainEvent
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
'@ | Set-Content `
"$TestProject\DomainEventTests\DomainEventTests.cs"



Write-Host ""
Write-Host "SharedKernel Tests Generated Successfully." -ForegroundColor Green