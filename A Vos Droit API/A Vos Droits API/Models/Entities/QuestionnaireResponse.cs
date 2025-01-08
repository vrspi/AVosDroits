using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace AVosDroitsAPI.Models.Entities;

public class QuestionnaireResponse
{
    [Key]
    public int Id { get; set; }
    
    [Required]
    public int UserId { get; set; }
    
    [ForeignKey(nameof(UserId))]
    public User? User { get; set; }
    
    [Required]
    public string QuestionId { get; set; } = string.Empty;
    
    [Required]
    public string Answer { get; set; } = string.Empty;
    
    [Required]
    public int Version { get; set; }
    
    [Required]
    public string SessionId { get; set; } = string.Empty;
    
    public DateTime CreatedAt { get; set; }
    
    public DateTime? UpdatedAt { get; set; }

    // Composite index to ensure one active response per question per user per session
    public class QuestionnaireResponseConfiguration : IEntityTypeConfiguration<QuestionnaireResponse>
    {
        public void Configure(EntityTypeBuilder<QuestionnaireResponse> builder)
        {
            builder.HasIndex(r => new { r.UserId, r.QuestionId, r.SessionId })
                .IsUnique()
                .HasDatabaseName("IX_QuestionnaireResponse_UserQuestion");
        }
    }
} 