# Document Management

## Purpose

The Prena Document Management Foundation provides a canonical registry for project documentation.

The registry makes documents discoverable, structured, versionable, traceable, and accessible to humans and AI agents.

## Principles

1. Every important document has a unique Document ID.
2. Every document belongs to a controlled category.
3. Every document has a lifecycle status.
4. Documents can reference related documents.
5. Documents can be mapped to source-code artifacts.
6. Documents can be indexed for AI retrieval.
7. Markdown files remain the source of truth for document content.
8. Registry metadata is the source of truth for document metadata.

## Document ID

Recommended format:

DOC-{DOMAIN}-{NUMBER}

Examples:

- DOC-GOV-001
- DOC-ARCH-001
- DOC-ERP1001-001
- DOC-API-001

## Lifecycle

Draft -> Review -> Approved -> Superseded -> Archived

## AI Accessibility

AI agents should be able to determine what a document is, why it exists, which module it belongs to, which version is current, which documents are related, and whether the document is authoritative.
