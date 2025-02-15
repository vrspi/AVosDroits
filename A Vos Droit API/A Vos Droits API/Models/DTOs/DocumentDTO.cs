using System;

namespace AVosDroitsAPI.Models.DTOs
{
    public class DocumentDTO
    {
        public Guid Id { get; set; }
        public string FileName { get; set; } = string.Empty;
        public string ContentType { get; set; } = string.Empty;
        public long FileSize { get; set; }
        public DateTime UploadDate { get; set; }
        public string? Description { get; set; }
        public string? Category { get; set; }
        public int? FolderId { get; set; }
        public string? FolderName { get; set; }
    }

    public class DocumentUploadRequest
    {
        public string? Description { get; set; }
        public string? Category { get; set; }
        public int? FolderId { get; set; }
    }

    public class DocumentResponse
    {
        public bool Success { get; set; }
        public string Message { get; set; } = string.Empty;
        public DocumentDTO? Document { get; set; }
    }

    public class UserFolderDTO
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Path { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
    }
} 