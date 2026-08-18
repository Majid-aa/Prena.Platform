using Prena.API.Configuration;
using Prena.API.Extensions;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddDocumentRegistry(builder.Configuration);

builder.Services.AddControllers();

builder.Services.AddEndpointsApiExplorer();

builder.Services.AddPrenaInfrastructure(
    builder.Configuration);

builder.Services.AddPrenaSwagger();

var app = builder.Build();

app.UsePrenaApplication();

app.Run();

public partial class Program
{
}
