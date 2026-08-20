using Prena.BuildingBlocks.SharedKernel.Common;

namespace Prena.ERP1001.Organization.Domain.Entities;

public sealed class Document : Entity
{
    private Document() { }

    private Document(string documentCode,string title,string documentType,string relativePath,string version)
    {
        DocumentCode=documentCode; Title=title; DocumentType=documentType;
        RelativePath=relativePath; Version=version; IsActive=true; CreatedAt=DateTime.UtcNow;
    }

    public string DocumentCode { get; private set; } = null!;
    public string Title { get; private set; } = null!;
    public string DocumentType { get; private set; } = null!;
    public string RelativePath { get; private set; } = null!;
    public string Version { get; private set; } = null!;
    public bool IsActive { get; private set; }
    public DateTime CreatedAt { get; private set; }

    public static Document Register(string documentCode,string title,string documentType,string relativePath,string version)
    {
        if(string.IsNullOrWhiteSpace(documentCode)) throw new ArgumentException("Document code is required.",nameof(documentCode));
        if(string.IsNullOrWhiteSpace(title)) throw new ArgumentException("Document title is required.",nameof(title));
        if(string.IsNullOrWhiteSpace(documentType)) throw new ArgumentException("Document type is required.",nameof(documentType));
        if(string.IsNullOrWhiteSpace(relativePath)) throw new ArgumentException("Document path is required.",nameof(relativePath));
        if(string.IsNullOrWhiteSpace(version)) throw new ArgumentException("Document version is required.",nameof(version));
        return new Document(documentCode.Trim(),title.Trim(),documentType.Trim(),relativePath.Trim(),version.Trim());
    }

    public void Deactivate()=>IsActive=false;
}