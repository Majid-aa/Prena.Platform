using Prena.API.Configuration;

namespace Prena.API.Extensions;

public static class WebApplicationExtensions
{
    public static WebApplication UsePrenaApplication(
        this WebApplication app)
    {
        app.UsePrenaSwagger();

        app.UsePrenaMiddleware();

        app.MapControllers();

        return app;
    }
}
