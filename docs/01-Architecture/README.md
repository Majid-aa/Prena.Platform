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
