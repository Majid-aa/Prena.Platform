# Document Registry Specification

## Document Entity

| Field | Required | Description |
|---|---|---|
| DocumentId | Yes | Globally unique document identifier |
| Title | Yes | Human-readable title |
| Category | Yes | Controlled document category |
| Domain | Yes | Business or technical domain |
| Module | No | Related Prena module |
| Status | Yes | Lifecycle status |
| Version | Yes | Document version |
| FilePath | Yes | Repository-relative path |
| Owner | Yes | Responsible owner |
| CreatedAt | Yes | Creation timestamp |
| UpdatedAt | Yes | Last update timestamp |
| Tags | No | Search keywords |
| Summary | Yes | Short summary |
| Authoritative | Yes | Whether AI may treat it as authoritative |
| Supersedes | No | Previous document ID |
| RelatedDocuments | No | Related document IDs |
| RelatedCode | No | Related source-code paths |

## Categories

- Governance
- Architecture
- BuildingBlock
- Platform
- Module
- API
- Data
- Security
- Operations
- Decision
- Glossary
- Template

## Status Values

- Draft
- Review
- Approved
- Superseded
- Archived

## AI Retrieval Priority

1. Approved status
2. Authoritative = true
3. Latest version
4. Exact domain match
5. Exact module match
6. Related document graph
7. Tags and semantic similarity
