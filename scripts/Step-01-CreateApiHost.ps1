# ===========================
# Step 01
# Create API Host Structure
# ===========================

$ApiRoot = ".\src\Prena.API"

New-Item -ItemType Directory "$ApiRoot\Configuration" -Force | Out-Null
New-Item -ItemType Directory "$ApiRoot\Extensions" -Force | Out-Null

#-------------------------------------------------------
# Program.cs
#-------------------------------------------------------

@'
using Prena.API.Configuration;
using Prena.API.Extensions;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddPrenaServices(builder.Configuration);

var app = builder.Build();

app.UsePrenaPipeline();

app.Run();
'@ | Set-Content "$ApiRoot\Program.cs"

#-------------------------------------------------------
# Configuration/DependencyInjection.cs
#-------------------------------------------------------

@'
namespace Prena.API.Configuration;

public static class DependencyInjection
{
    public static IServiceCollection AddPrenaServices(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        services.AddEndpointsApiExplorer();

        services.AddSwaggerDocumentation();

        services.AddHealthChecks();

        return services;
    }
}
'@ | Set-Content "$ApiRoot\Configuration\DependencyInjection.cs"

#-------------------------------------------------------
# Configuration/SwaggerConfiguration.cs
#-------------------------------------------------------

@'
namespace Prena.API.Configuration;

public static class SwaggerConfiguration
{
    public static IServiceCollection AddSwaggerDocumentation(
        this IServiceCollection services)
    {
        services.AddSwaggerGen();

        return services;
    }
}
'@ | Set-Content "$ApiRoot\Configuration\SwaggerConfiguration.cs"

#-------------------------------------------------------
# Configuration/MiddlewareConfiguration.cs
#-------------------------------------------------------

@'
namespace Prena.API.Configuration;

public static class MiddlewareConfiguration
{
    public static WebApplication UseSwaggerDocumentation(
        this WebApplication app)
    {
        app.UseSwagger();

        app.UseSwaggerUI();

        return app;
    }
}
'@ | Set-Content "$ApiRoot\Configuration\MiddlewareConfiguration.cs"

#-------------------------------------------------------
# Extensions/WebApplicationExtensions.cs
#-------------------------------------------------------

@'
using Prena.API.Configuration;

namespace Prena.API.Extensions;

public static class WebApplicationExtensions
{
    public static WebApplication UsePrenaPipeline(
        this WebApplication app)
    {
        if (app.Environment.IsDevelopment())
        {
            app.UseSwaggerDocumentation();
        }

        app.UseHttpsRedirection();

        app.MapHealthChecks("/health");

        app.MapGet("/", () => Results.Ok(new
        {
            Name = "Prena Platform",
            Version = "0.1.0",
            Status = "Running"
        }));

        return app;
    }
}
'@ | Set-Content "$ApiRoot\Extensions\WebApplicationExtensions.cs"

Write-Host ""
Write-Host "API Host created successfully." -ForegroundColor Green