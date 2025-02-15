using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace AVosDroitsAPI.Models.Entities
{
    public class Document
    {
        [Key]
        public Guid Id { get; set; }
        
        [Required]
        public string FileName { get; set; } = string.Empty;
        
        [Required]
        public string ContentType { get; set; } = string.Empty;
        
        [Required]
        public string FilePath { get; set; } = string.Empty;
        
        [Required]
        public long FileSize { get; set; }
        
        [Required]
        public DateTime UploadDate { get; set; }
        
        [Required]
        public int UserId { get; set; }
        
        [ForeignKey(nameof(UserId))]
        public User User { get; set; } = null!;
        
        public int? FolderId { get; set; }
        
        [ForeignKey(nameof(FolderId))]
        public UserFolder? Folder { get; set; }
        
        public string? Description { get; set; }
        public string? Category { get; set; }
    }
} 