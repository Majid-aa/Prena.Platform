using Microsoft.EntityFrameworkCore;
using Prena.ERP1001.Organization.Infrastructure.DocumentManagement.Entities;

namespace Prena.ERP1001.Organization.Infrastructure.DocumentManagement.Persistence;

/// <summary>
/// EF Core context for the Prena document registry.
/// </summary>
public sealed class DocumentRegistryDbContext : DbContext
{
    public DocumentRegistryDbContext(DbContextOptions<DocumentRegistryDbContext> options)
        : base(options)
    {
    }

    public DbSet<Document> Documents => Set<Document>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        var entity = modelBuilder.Entity<Document>();

        entity.ToTable("Documents", "document_management");

        entity.HasKey(x => x.Id);

        entity.Property(x => x.DocumentCode)
            .HasMaxLength(100)
            .IsRequired();

        entity.HasIndex(x => x.DocumentCode)
            .IsUnique();

        entity.Property(x => x.Title)
            .HasMaxLength(300)
            .IsRequired();

        entity.Property(x => x.DocumentType)
            .HasMaxLength(100)
            .IsRequired();

        entity.Property(x => x.RelativePath)
            .HasMaxLength(1000)
            .IsRequired();

        entity.Property(x => x.Version)
            .HasMaxLength(50)
            .IsRequired();

        entity.Property(x => x.CreatedAt)
            .IsRequired();
    }
}