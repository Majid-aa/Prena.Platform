using Microsoft.EntityFrameworkCore;
using Prena.ERP1001.Organization.Domain.Entities;

namespace Prena.ERP1001.Organization.Infrastructure.DocumentManagement.Persistence;

public sealed class DocumentRegistryDbContext(DbContextOptions<DocumentRegistryDbContext> options) : DbContext(options)
{
    public DbSet<Document> Documents => Set<Document>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        var e=modelBuilder.Entity<Document>();
        e.ToTable("Documents","document_management");
        e.HasKey(x=>x.Id);
        e.HasIndex(x=>x.DocumentCode).IsUnique();
        e.Property(x=>x.DocumentCode).HasMaxLength(100).IsRequired();
        e.Property(x=>x.Title).HasMaxLength(300).IsRequired();
        e.Property(x=>x.DocumentType).HasMaxLength(100).IsRequired();
        e.Property(x=>x.RelativePath).HasMaxLength(1000).IsRequired();
        e.Property(x=>x.Version).HasMaxLength(50).IsRequired();
        e.Property(x=>x.CreatedAt).IsRequired();
    }
}