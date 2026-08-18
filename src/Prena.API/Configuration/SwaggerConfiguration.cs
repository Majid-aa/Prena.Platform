namespace Prena.API.Configuration;

public static class SwaggerConfiguration
{
    public static IServiceCollection AddPrenaSwagger(
        this IServiceCollection services)
    {
        return services;
    }

    public static WebApplication UsePrenaSwagger(
        this WebApplication app)
    {
        return app;
    }
}
