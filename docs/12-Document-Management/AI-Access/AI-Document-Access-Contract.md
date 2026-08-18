# AI Document Access Contract

## Purpose

The Prena documentation system must allow AI agents to discover authoritative project knowledge without depending on conversational memory.

## AI Query Flow

1. Identify user intent.
2. Identify domain.
3. Identify module.
4. Query the Document Registry.
5. Filter by lifecycle status.
6. Prefer authoritative documents.
7. Retrieve document content.
8. Resolve related documents when necessary.
9. Return answers with document references.

## Authority Rule

AI must not treat Draft documents as authoritative when an Approved document exists.

If multiple Approved documents conflict, prefer the latest version and flag the conflict.

## Future API

GET /api/v1/documents

GET /api/v1/documents/{documentId}

GET /api/v1/documents/search

GET /api/v1/documents/{documentId}/relationships

GET /api/v1/documents/{documentId}/content

GET /api/v1/documents/authoritative

## Future AI Integration

- Full-text search
- Semantic search
- Embeddings
- Vector indexes
- Hybrid retrieval
- Document chunking
- Retrieval-Augmented Generation
- AI citation tracking
