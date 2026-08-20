using Prena.ERP1001.Organization.Domain.Entities;

namespace Prena.ERP1001.Organization.Application.DocumentManagement.Interfaces;

public interface IDocumentRepository
{
    Task<Document> AddAsync(Document document,CancellationToken cancellationToken=default);
    Task<Document?> GetByIdAsync(Guid id,CancellationToken cancellationToken=default);
    Task<Document?> GetByCodeAsync(string documentCode,CancellationToken cancellationToken=default);
    Task<IReadOnlyList<Document>> GetAllAsync(CancellationToken cancellationToken=default);
}