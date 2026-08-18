namespace Prena.API.Configuration;

public static class MiddlewareConfiguration
{
    public static WebApplication UsePrenaMiddleware(
        this WebApplication app)
    {
        if (app.Environment.IsDevelopment())
        {
            app.UseDeveloperExceptionPage();
        }

        app.UseHttpsRedirection();

        app.UseAuthorization();

        return app;
    }
}
