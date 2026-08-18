using Microsoft.AspNetCore.Mvc;
using Prena.ERP1001.Organization.Application.Commands;
using Prena.ERP1001.Organization.Application.DTOs;
using Prena.ERP1001.Organization.Application.Handlers;
using Prena.ERP1001.Organization.Application.Queries.GetTenantById;

namespace Prena.API.Controllers;

[ApiController]
[Route("api/v1/tenants")]
public sealed class TenantsController : ControllerBase
{
    private readonly CreateTenantCommandHandler _createTenantHandler;
    private readonly GetTenantByIdQueryHandler _getTenantByIdHandler;

    public TenantsController(
        CreateTenantCommandHandler createTenantHandler,
        GetTenantByIdQueryHandler getTenantByIdHandler)
    {
        _createTenantHandler = createTenantHandler;
        _getTenantByIdHandler = getTenantByIdHandler;
    }

    [HttpPost]
    [ProducesResponseType(
        typeof(TenantDto),
        StatusCodes.Status201Created)]
    [ProducesResponseType(
        StatusCodes.Status400BadRequest)]
    public async Task<ActionResult<TenantDto>> Create(
        [FromBody] CreateTenantCommand command,
        CancellationToken cancellationToken)
    {
        var result = await _createTenantHandler.Handle(
            command,
            cancellationToken);

        return CreatedAtAction(
            nameof(GetById),
            new { id = result.Id },
            result);
    }

    [HttpGet("{id:guid}")]
    [ProducesResponseType(
        typeof(TenantDto),
        StatusCodes.Status200OK)]
    [ProducesResponseType(
        StatusCodes.Status404NotFound)]
    public async Task<ActionResult<TenantDto>> GetById(
        Guid id,
        CancellationToken cancellationToken)
    {
        var result = await _getTenantByIdHandler.Handle(
            new GetTenantByIdQuery(id),
            cancellationToken);

        if (result is null)
        {
            return NotFound();
        }

        return Ok(result);
    }
}
