# Data Architecture

Documents database architecture and persistence.

## Current Technologies

- SQL Server
- Entity Framework Core
- Code First Migrations

## Module Database Contexts

Each module may own its persistence model and database context.

Current context:

`PrenaOrganizationDbContext`

## Migration Strategy

Database schema changes are managed through EF Core migrations.

Migrations must be version controlled in Git.
