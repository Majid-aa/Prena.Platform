# ERP-1001 Organization Master Data

## Document Metadata

| Field | Value |
|---|---|
| Document ID | ERP-1001 |
| Title | Organization Master Data |
| Version | 0.1 |
| Status | Draft |
| Owner | Prena Platform |
| Module | ERP |
| Code | ERP-1001.Organization |

## Purpose

The Organization Master Data module manages the organizational structure of the Prena ERP platform.

## Core Concepts

The module currently includes:

- Tenant
- Organization
- Legal Entity
- Business Unit
- Branch
- Department
- Cost Center
- Location

## Tenant

A Tenant represents an isolated business or customer environment within the Prena platform.

Current Tenant attributes include:

- Id
- Code
- Name
- Status

## Tenant Status

Supported statuses:

- Active
- Suspended
- Inactive

## Domain Behavior

Tenant creation must:

1. Validate Code
2. Validate Name
3. Create a Tenant identity
4. Set initial status to Active
5. Raise TenantCreated domain event

## Application Flow

Create Tenant:

Client
  -> API
  -> Application Command
  -> Command Handler
  -> Domain Entity
  -> Repository
  -> EF Core
  -> SQL Server

## API

Current endpoint:

`POST /api/tenants`

Expected future endpoint:

`GET /api/tenants/{id}`

## Persistence

The module uses:

- Entity Framework Core
- SQL Server
- PrenaOrganizationDbContext

## Related Code

Domain:

`src/Modules/ERP/ERP-1001.Organization/Domain`

Application:

`src/Modules/ERP/ERP-1001.Organization/Application`

Infrastructure:

`src/Modules/ERP/ERP-1001.Organization/Infrastructure`

Contracts:

`src/Modules/ERP/ERP-1001.Organization/Contracts`

## Related Documentation

- API documentation
- Database documentation
- Multi-tenancy documentation
- Architecture decisions

## Future Work

- Organization hierarchy
- Legal entities
- Branch management
- Department management
- Cost centers
- Locations
- Organization relationships
- Tenant isolation strategy
- Tenant lifecycle management
