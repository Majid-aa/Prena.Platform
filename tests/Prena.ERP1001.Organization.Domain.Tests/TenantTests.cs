using Xunit;
using Prena.ERP1001.Organization.Domain.Entities;
using Prena.ERP1001.Organization.Domain.Events;

namespace Prena.ERP1001.Organization.Domain.Tests;


public class TenantTests
{

    [Fact]
    public void Create_Should_Create_Active_Tenant()
    {
        // Arrange
        var code = "PRENA001";
        var name = "Demo Organization";


        // Act
        var tenant = Tenant.Create(
            code,
            name);


        // Assert
        Assert.Equal(code, tenant.Code);
        Assert.Equal(name, tenant.Name);
        Assert.Equal(
            TenantStatus.Active,
            tenant.Status);
    }



    [Fact]
    public void Create_Should_Reject_Empty_Code()
    {
        Assert.Throws<ArgumentException>(() =>
            Tenant.Create(
                "",
                "Demo Organization"));
    }



    [Fact]
    public void Create_Should_Reject_Empty_Name()
    {
        Assert.Throws<ArgumentException>(() =>
            Tenant.Create(
                "PRENA001",
                ""));
    }

    [Fact]
    public void Create_Should_Raise_TenantCreated_Event()
    {
        var tenant = Tenant.Create(
            "PRENA001",
            "Demo Organization");


        Assert.Single(
            tenant.DomainEvents);


        var domainEvent =
            tenant.DomainEvents.First();


        Assert.IsType<TenantCreatedEvent>(
            domainEvent);
    }

}