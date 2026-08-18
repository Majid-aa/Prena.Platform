using Prena.ERP1001.Organization.Application.Commands;
using Prena.ERP1001.Organization.Application.DTOs;
using Prena.ERP1001.Organization.Application.Interfaces;
using Prena.ERP1001.Organization.Domain.Entities;


namespace Prena.ERP1001.Organization.Application.Handlers;


public sealed class CreateTenantCommandHandler
{

    private readonly ITenantRepository _repository;


    public CreateTenantCommandHandler(
        ITenantRepository repository)
    {
        _repository = repository;
    }



    public async Task<TenantDto> Handle(
        CreateTenantCommand command,
        CancellationToken cancellationToken)
    {

        var tenant = Tenant.Create(
            command.Code,
            command.Name);



        await _repository.AddAsync(
            tenant,
            cancellationToken);



        return new TenantDto(
            tenant.Id,
            tenant.Code,
            tenant.Name);

    }

}