# ============================================================
# Prena Platform
# Phase 09-01 - Documentation Foundation
# ============================================================

$ErrorActionPreference = "Stop"

$Root = (Get-Location).Path
$Docs = Join-Path $Root "docs"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "PHASE 09-01 - DOCUMENTATION FOUNDATION" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

function New-Directory {
    param([string]$Path)

    if (-not (Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
        Write-Host "[DIR]  $Path" -ForegroundColor DarkGreen
    }
}

function Write-Markdown {
    param(
        [string]$Path,
        [string]$Content
    )

    $Parent = Split-Path $Path -Parent

    if (-not (Test-Path $Parent)) {
        New-Item -ItemType Directory -Path $Parent -Force | Out-Null
    }

    Set-Content -Path $Path -Value $Content -Encoding UTF8
    Write-Host "[FILE] $Path" -ForegroundColor Green
}

# ============================================================
# 1. Documentation directories
# ============================================================

Write-Host "[1/8] Creating documentation structure..." -ForegroundColor Yellow

$Directories = @(
    "00-Governance",
    "01-Architecture",
    "02-Building-Blocks",
    "03-Platform",
    "04-Modules",
    "04-Modules\ERP-1001.Organization",
    "05-API",
    "06-Data",
    "07-Security",
    "08-Operations",
    "09-Decisions",
    "10-Glossary",
    "11-Templates",
    "99-Archive"
)

foreach ($Directory in $Directories) {
    New-Directory (Join-Path $Docs $Directory)
}

# ============================================================
# 2. Root documentation README
# ============================================================

Write-Host "[2/8] Creating documentation index..." -ForegroundColor Yellow

Write-Markdown (Join-Path $Docs "README.md") @'
# Prena Platform Documentation

Welcome to the central documentation repository for the Prena Platform.

## Purpose

This documentation system provides a structured and machine-readable knowledge base for:

- Product requirements
- Business processes
- Domain models
- Software architecture
- ERP modules
- APIs
- Database design
- Security
- Infrastructure
- Operations
- Architectural decisions

The documentation is maintained in Git and is designed to be consumed by:

1. Human developers
2. Business analysts
3. Process analysts
4. Technical architects
5. AI assistants and agents
6. Automated documentation and knowledge systems

## Documentation Areas

- [Governance](00-Governance/README.md)
- [Architecture](01-Architecture/README.md)
- [Building Blocks](02-Building-Blocks/README.md)
- [Platform](03-Platform/README.md)
- [ERP Modules](04-Modules/README.md)
- [API](05-API/README.md)
- [Data](06-Data/README.md)
- [Security](07-Security/README.md)
- [Operations](08-Operations/README.md)
- [Architecture Decisions](09-Decisions/README.md)
- [Glossary](10-Glossary/README.md)
- [Templates](11-Templates/README.md)

## Documentation Principles

- Single source of truth
- Version controlled
- Traceable
- Modular
- Machine-readable
- AI-friendly
- Domain-oriented
- Explicit ownership
- Clear document identifiers

## Document Identification

Documents should use stable identifiers whenever possible.

Examples:

- ERP-1001: Organization Master Data
- ERP-1002: Financial Master Data
- ERP-1003: Product & Inventory Master Data
- ADR-0001: Architecture Decision Record
- API-0001: API Architecture
'@

# ============================================================
# 3. Governance
# ============================================================

Write-Host "[3/8] Creating governance documentation..." -ForegroundColor Yellow

Write-Markdown (Join-Path $Docs "00-Governance\README.md") @'
# Documentation Governance

## Purpose

Defines the rules for creating, maintaining, reviewing, and publishing Prena documentation.

## Document Lifecycle

1. Draft
2. Review
3. Approved
4. Published
5. Deprecated
6. Archived

## Required Metadata

Each important document should define:

- Document ID
- Title
- Version
- Status
- Owner
- Created Date
- Last Updated
- Related Documents

## Change Management

All significant documentation changes must be committed to Git.

Architecture and domain changes should be linked to:

- Code changes
- API changes
- Database changes
- ADRs
- Related requirements
'@

# ============================================================
# 4. Architecture
# ============================================================

Write-Host "[4/8] Creating architecture documentation..." -ForegroundColor Yellow

Write-Markdown (Join-Path $Docs "01-Architecture\README.md") @'
# Prena Platform Architecture

## Overview

Prena is designed as a modular, enterprise-grade ERP platform.

The architecture emphasizes:

- Modular monolith evolution
- Domain-driven design
- Clean Architecture
- Separation of concerns
- API-first integration
- Multi-tenancy
- Extensibility
- Cloud readiness
- AI readiness

## Main Layers

### Domain

Contains:

- Entities
- Value Objects
- Domain Events
- Domain Rules
- Aggregates

### Application

Contains:

- Commands
- Queries
- Handlers
- DTOs
- Application Services
- Repository Contracts

### Infrastructure

Contains:

- Entity Framework Core
- Database Contexts
- Repositories
- Persistence
- External integrations

### API

Contains:

- HTTP endpoints
- Authentication
- Middleware
- API configuration
- Swagger/OpenAPI

## Architecture Direction

Dependencies should generally point inward:

API
  -> Application
      -> Domain

Infrastructure
  -> Application
  -> Domain

Domain must remain independent from Infrastructure and API concerns.
'@

# ============================================================
# 5. Platform and Building Blocks
# ============================================================

Write-Host "[5/8] Creating platform documentation..." -ForegroundColor Yellow

Write-Markdown (Join-Path $Docs "02-Building-Blocks\README.md") @'
# Building Blocks

Shared technical capabilities used across Prena modules.

Expected building blocks include:

- Shared Kernel
- Core abstractions
- Application abstractions
- Infrastructure abstractions
- Contracts
- Testing utilities
- Identity
- Multi-tenancy
- Auditing
- Domain events
- Result patterns
- Error handling
'@

Write-Markdown (Join-Path $Docs "03-Platform\README.md") @'
# Prena Platform

This section documents platform-level capabilities.

## Current Platform Components

- Prena API
- Prena CLI
- Shared Kernel
- Building Blocks
- Module Infrastructure
- Documentation System

## Future Platform Capabilities

- Identity and Access Management
- Tenant Management
- Configuration Management
- Event Bus
- Background Jobs
- Observability
- Audit Logging
- AI Knowledge Management
'@

# ============================================================
# 6. ERP module documentation
# ============================================================

Write-Host "[6/8] Creating ERP module documentation..." -ForegroundColor Yellow

Write-Markdown (Join-Path $Docs "04-Modules\README.md") @'
# ERP Modules

This section contains documentation for ERP business modules.

## Master Data Modules

- ERP-1001 Organization Master Data
- ERP-1002 Financial Master Data
- ERP-1003 Product & Inventory Master Data
- ERP-1004 Customer & Supplier Master Data
- ERP-1005 Commerce Master Data
- ERP-1006 Human Resources Master Data
- ERP-1007 Manufacturing Master Data
- ERP-1008 Security & Identity Master Data
- ERP-1009 Integration Master Data
- ERP-1010 AI & Analytics Master Data
'@

Write-Markdown (Join-Path $Docs "04-Modules\ERP-1001.Organization\ERP-1001-Organization-Master-Data.md") @'
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
'@

# ============================================================
# 7. API, Data, Security, Operations, Decisions, Glossary
# ============================================================

Write-Host "[7/8] Creating supporting documentation..." -ForegroundColor Yellow

Write-Markdown (Join-Path $Docs "05-API\README.md") @'
# API Documentation

The Prena API is the primary HTTP interface for platform and module operations.

## Current API

- ASP.NET Core
- .NET 10
- OpenAPI / Swagger
- Modular controller organization

## API Principles

- RESTful design
- Versioning readiness
- Consistent error responses
- Validation
- Authentication
- Authorization
- Observability
'@

Write-Markdown (Join-Path $Docs "06-Data\README.md") @'
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
'@

Write-Markdown (Join-Path $Docs "07-Security\README.md") @'
# Security

Security architecture for the Prena Platform.

Future areas:

- Identity
- Authentication
- Authorization
- Role-Based Access Control
- Permission Management
- Tenant Isolation
- Secrets Management
- Audit Logging
- Security Monitoring
'@

Write-Markdown (Join-Path $Docs "08-Operations\README.md") @'
# Operations

Operational documentation for running and maintaining Prena.

Future areas:

- Local development
- Configuration
- Deployment
- Database migration
- Logging
- Monitoring
- Health checks
- Backup
- Disaster recovery
'@

Write-Markdown (Join-Path $Docs "09-Decisions\README.md") @'
# Architecture Decision Records

This section contains important architecture decisions.

## ADR Format

Each decision should document:

- Context
- Problem
- Options
- Decision
- Consequences
- Status

Example:

`ADR-0001-Architecture-Style.md`
'@

Write-Markdown (Join-Path $Docs "10-Glossary\README.md") @'
# Glossary

## Tenant

An isolated customer or business environment within Prena.

## Organization

A business organizational structure managed by the ERP platform.

## Aggregate

A consistency boundary in the domain model.

## Domain Event

An event representing an important occurrence within the domain.

## Master Data

Core business data shared across business processes.

## Building Block

A reusable technical capability shared by multiple modules.
'@

# ============================================================
# 8. Document management foundation
# ============================================================

Write-Host "[8/8] Creating document metadata and templates..." -ForegroundColor Yellow

Write-Markdown (Join-Path $Docs "11-Templates\Document-Template.md") @'
# Document Title

## Document Metadata

| Field | Value |
|---|---|
| Document ID | |
| Title | |
| Version | 0.1 |
| Status | Draft |
| Owner | |
| Created Date | |
| Last Updated | |

## Purpose

## Scope

## Definitions

## Business Rules

## Architecture

## Data Model

## API

## Security

## Operations

## Related Code

## Related Documents

## Open Questions

## Future Work
'@

Write-Markdown (Join-Path $Docs "DOCUMENT-INDEX.md") @'
# Prena Document Index

| Document ID | Title | Category | Status |
|---|---|---|---|
| ERP-1001 | Organization Master Data | ERP | Draft |
| API-0001 | API Architecture | API | Planned |
| ADR-0001 | Architecture Decision Record | Architecture | Planned |

## Purpose

This index is the initial foundation for the future Prena Documentation Management System.

The future system should be able to:

1. Scan documentation.
2. Parse metadata.
3. Index documents.
4. Search documents.
5. Track relationships.
6. Track versions.
7. Expose documents through an API.
8. Provide AI-friendly retrieval.
9. Support semantic search.
10. Support RAG-based knowledge access.

## Future Metadata Model

Documents should eventually expose:

- DocumentId
- Title
- Category
- Module
- Version
- Status
- Owner
- Tags
- RelatedDocuments
- SourcePath
- GitCommit
- LastModified
'@

# ============================================================
# Verification
# ============================================================

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "VERIFYING DOCUMENTATION FOUNDATION" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$RequiredFiles = @(
    "README.md",
    "DOCUMENT-INDEX.md",
    "00-Governance\README.md",
    "01-Architecture\README.md",
    "02-Building-Blocks\README.md",
    "03-Platform\README.md",
    "04-Modules\README.md",
    "04-Modules\ERP-1001.Organization\ERP-1001-Organization-Master-Data.md",
    "05-API\README.md",
    "06-Data\README.md",
    "07-Security\README.md",
    "08-Operations\README.md",
    "09-Decisions\README.md",
    "10-Glossary\README.md",
    "11-Templates\Document-Template.md"
)

$MissingFiles = @()

foreach ($File in $RequiredFiles) {
    $FullPath = Join-Path $Docs $File

    if (Test-Path $FullPath) {
        Write-Host "[OK] $File" -ForegroundColor Green
    }
    else {
        Write-Host "[MISSING] $File" -ForegroundColor Red
        $MissingFiles += $File
    }
}

if ($MissingFiles.Count -gt 0) {
    throw "Documentation verification failed. Missing files: $($MissingFiles -join ', ')"
}

Write-Host ""
Write-Host "Documentation files created successfully." -ForegroundColor Green

# ============================================================
# Git status
# ============================================================

Write-Host ""
Write-Host "Git status:" -ForegroundColor Cyan

git status --short

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "PHASE 09-01 COMPLETED SUCCESSFULLY" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

