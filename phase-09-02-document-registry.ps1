$ErrorActionPreference = "Stop"

$Root = (Get-Location).Path
$Docs = Join-Path $Root "docs"

Write-Host ""
Write-Host "========================================"
Write-Host "PHASE 09-02 - DOCUMENT REGISTRY"
Write-Host "========================================"
Write-Host ""

function Write-Utf8File {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string[]]$Lines
    )

    $Directory = Split-Path -Path $Path -Parent

    if (-not (Test-Path -LiteralPath $Directory)) {
        New-Item -ItemType Directory -Force -Path $Directory | Out-Null
    }

    [System.IO.File]::WriteAllLines(
        $Path,
        $Lines,
        [System.Text.UTF8Encoding]::new($false)
    )
}

Write-Host "[1/7] Creating document management structure..."

$Directories = @(
    (Join-Path $Docs "12-Document-Management"),
    (Join-Path $Docs "12-Document-Management\Documents"),
    (Join-Path $Docs "12-Document-Management\Metadata"),
    (Join-Path $Docs "12-Document-Management\Relationships"),
    (Join-Path $Docs "12-Document-Management\AI-Access")
)

foreach ($Directory in $Directories) {
    New-Item -ItemType Directory -Force -Path $Directory | Out-Null
    Write-Host "[DIR] $Directory"
}

Write-Host "[2/7] Creating Document Management README..."

$Readme = @(
    "# Document Management",
    "",
    "## Purpose",
    "",
    "The Prena Document Management Foundation provides a canonical registry for project documentation.",
    "",
    "The registry makes documents discoverable, structured, versionable, traceable, and accessible to humans and AI agents.",
    "",
    "## Principles",
    "",
    "1. Every important document has a unique Document ID.",
    "2. Every document belongs to a controlled category.",
    "3. Every document has a lifecycle status.",
    "4. Documents can reference related documents.",
    "5. Documents can be mapped to source-code artifacts.",
    "6. Documents can be indexed for AI retrieval.",
    "7. Markdown files remain the source of truth for document content.",
    "8. Registry metadata is the source of truth for document metadata.",
    "",
    "## Document ID",
    "",
    "Recommended format:",
    "",
    "DOC-{DOMAIN}-{NUMBER}",
    "",
    "Examples:",
    "",
    "- DOC-GOV-001",
    "- DOC-ARCH-001",
    "- DOC-ERP1001-001",
    "- DOC-API-001",
    "",
    "## Lifecycle",
    "",
    "Draft -> Review -> Approved -> Superseded -> Archived",
    "",
    "## AI Accessibility",
    "",
    "AI agents should be able to determine what a document is, why it exists, which module it belongs to, which version is current, which documents are related, and whether the document is authoritative."
)

Write-Utf8File -Path (Join-Path $Docs "12-Document-Management\README.md") -Lines $Readme

Write-Host "[3/7] Creating Document Registry specification..."

$RegistrySpec = @(
    "# Document Registry Specification",
    "",
    "## Document Entity",
    "",
    "| Field | Required | Description |",
    "|---|---|---|",
    "| DocumentId | Yes | Globally unique document identifier |",
    "| Title | Yes | Human-readable title |",
    "| Category | Yes | Controlled document category |",
    "| Domain | Yes | Business or technical domain |",
    "| Module | No | Related Prena module |",
    "| Status | Yes | Lifecycle status |",
    "| Version | Yes | Document version |",
    "| FilePath | Yes | Repository-relative path |",
    "| Owner | Yes | Responsible owner |",
    "| CreatedAt | Yes | Creation timestamp |",
    "| UpdatedAt | Yes | Last update timestamp |",
    "| Tags | No | Search keywords |",
    "| Summary | Yes | Short summary |",
    "| Authoritative | Yes | Whether AI may treat it as authoritative |",
    "| Supersedes | No | Previous document ID |",
    "| RelatedDocuments | No | Related document IDs |",
    "| RelatedCode | No | Related source-code paths |",
    "",
    "## Categories",
    "",
    "- Governance",
    "- Architecture",
    "- BuildingBlock",
    "- Platform",
    "- Module",
    "- API",
    "- Data",
    "- Security",
    "- Operations",
    "- Decision",
    "- Glossary",
    "- Template",
    "",
    "## Status Values",
    "",
    "- Draft",
    "- Review",
    "- Approved",
    "- Superseded",
    "- Archived",
    "",
    "## AI Retrieval Priority",
    "",
    "1. Approved status",
    "2. Authoritative = true",
    "3. Latest version",
    "4. Exact domain match",
    "5. Exact module match",
    "6. Related document graph",
    "7. Tags and semantic similarity"
)

Write-Utf8File -Path (Join-Path $Docs "12-Document-Management\Metadata\Document-Registry-Specification.md") -Lines $RegistrySpec

Write-Host "[4/7] Creating document manifest..."

$Manifest = @(
    "# Prena Document Manifest",
    "",
    "## DOC-GOV-001",
    "",
    "- Title: Documentation Governance",
    "- Category: Governance",
    "- Domain: Platform",
    "- Status: Approved",
    "- Version: 1.0.0",
    "- FilePath: docs/00-Governance/README.md",
    "- Authoritative: true",
    "",
    "## DOC-ARCH-001",
    "",
    "- Title: Architecture Documentation",
    "- Category: Architecture",
    "- Domain: Platform",
    "- Status: Approved",
    "- Version: 1.0.0",
    "- FilePath: docs/01-Architecture/README.md",
    "- Authoritative: true",
    "",
    "## DOC-ERP1001-001",
    "",
    "- Title: Organization Master Data",
    "- Category: Module",
    "- Domain: ERP",
    "- Module: ERP-1001.Organization",
    "- Status: Approved",
    "- Version: 1.0.0",
    "- FilePath: docs/04-Modules/ERP-1001.Organization/ERP-1001-Organization-Master-Data.md",
    "- Authoritative: true",
    "- RelatedCode: src/Modules/ERP/ERP-1001.Organization",
    "",
    "## DOC-API-001",
    "",
    "- Title: Prena API Documentation",
    "- Category: API",
    "- Domain: Platform",
    "- Status: Draft",
    "- Version: 1.0.0",
    "- FilePath: docs/05-API/README.md",
    "- Authoritative: false",
    "- RelatedCode: src/Prena.API"
)

Write-Utf8File -Path (Join-Path $Docs "12-Document-Management\Documents\DOCUMENT-MANIFEST.md") -Lines $Manifest

Write-Host "[5/7] Creating document relationships..."

$Relationships = @(
    "# Document Relationships",
    "",
    "Documents form a project knowledge graph.",
    "",
    "## Relationship Types",
    "",
    "- depends-on",
    "- references",
    "- implements",
    "- supersedes",
    "- derived-from",
    "- related-to",
    "",
    "## Example",
    "",
    "DOC-ERP1001-001",
    "",
    "- references -> DOC-ARCH-001",
    "- implements -> ERP-1001.Domain",
    "- implements -> ERP-1001.Application",
    "- implements -> ERP-1001.Infrastructure",
    "- related-to -> DOC-API-001"
)

Write-Utf8File -Path (Join-Path $Docs "12-Document-Management\Relationships\Document-Relationships.md") -Lines $Relationships

Write-Host "[6/7] Creating AI document access contract..."

$AIContract = @(
    "# AI Document Access Contract",
    "",
    "## Purpose",
    "",
    "The Prena documentation system must allow AI agents to discover authoritative project knowledge without depending on conversational memory.",
    "",
    "## AI Query Flow",
    "",
    "1. Identify user intent.",
    "2. Identify domain.",
    "3. Identify module.",
    "4. Query the Document Registry.",
    "5. Filter by lifecycle status.",
    "6. Prefer authoritative documents.",
    "7. Retrieve document content.",
    "8. Resolve related documents when necessary.",
    "9. Return answers with document references.",
    "",
    "## Authority Rule",
    "",
    "AI must not treat Draft documents as authoritative when an Approved document exists.",
    "",
    "If multiple Approved documents conflict, prefer the latest version and flag the conflict.",
    "",
    "## Future API",
    "",
    "GET /api/v1/documents",
    "",
    "GET /api/v1/documents/{documentId}",
    "",
    "GET /api/v1/documents/search",
    "",
    "GET /api/v1/documents/{documentId}/relationships",
    "",
    "GET /api/v1/documents/{documentId}/content",
    "",
    "GET /api/v1/documents/authoritative",
    "",
    "## Future AI Integration",
    "",
    "- Full-text search",
    "- Semantic search",
    "- Embeddings",
    "- Vector indexes",
    "- Hybrid retrieval",
    "- Document chunking",
    "- Retrieval-Augmented Generation",
    "- AI citation tracking"
)

Write-Utf8File -Path (Join-Path $Docs "12-Document-Management\AI-Access\AI-Document-Access-Contract.md") -Lines $AIContract

Write-Host "[7/7] Updating document index..."

$IndexPath = Join-Path $Docs "DOCUMENT-INDEX.md"

$DocumentManagementLinks = @(
    "",
    "## Document Management",
    "",
    "- [Document Management](12-Document-Management/README.md)",
    "- [Document Registry Specification](12-Document-Management/Metadata/Document-Registry-Specification.md)",
    "- [Document Manifest](12-Document-Management/Documents/DOCUMENT-MANIFEST.md)",
    "- [Document Relationships](12-Document-Management/Relationships/Document-Relationships.md)",
    "- [AI Document Access Contract](12-Document-Management/AI-Access/AI-Document-Access-Contract.md)"
)

if (Test-Path -LiteralPath $IndexPath) {
    $ExistingContent = Get-Content -LiteralPath $IndexPath -Raw

    if ($ExistingContent -notmatch "## Document Management") {
        Add-Content -LiteralPath $IndexPath -Value $DocumentManagementLinks
    }
}
else {
    Write-Utf8File -Path $IndexPath -Lines @(
        "# Prena Document Index"
    )

    Add-Content -LiteralPath $IndexPath -Value $DocumentManagementLinks
}

Write-Host ""
Write-Host "========================================"
Write-Host "PHASE 09-02 COMPLETED SUCCESSFULLY"
Write-Host "========================================"
Write-Host ""
Write-Host "Created:"
Write-Host "  [OK] Document Management Foundation"
Write-Host "  [OK] Document Registry Specification"
Write-Host "  [OK] Document Manifest"
Write-Host "  [OK] Document Relationship Model"
Write-Host "  [OK] AI Document Access Contract"
Write-Host ""
Write-Host "Next: Phase 09-03 - Document Registry API"
