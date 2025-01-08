using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace AVosDroitsAPI.Models.Entities;

public class Questionnaire
{
    [Key]
    public int Id { get; set; }
    
    [Required]
    public int UserId { get; set; }
    
    [ForeignKey(nameof(UserId))]
    public User User { get; set; } = null!;
    
    public DateTime CompletedAt { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
    public int Version { get; set; }
    
    public List<QuestionnaireSection> Sections { get; set; } = new();
}

public class QuestionnaireSection
{
    [Key]
    public int Id { get; set; }
    
    [Required]
    public int QuestionnaireId { get; set; }
    
    [ForeignKey(nameof(QuestionnaireId))]
    public Questionnaire Questionnaire { get; set; } = null!;
    
    [Required]
    public string Title { get; set; } = string.Empty;
    
    public int Order { get; set; }
    
    public List<QuestionnaireResponse> Responses { get; set; } = new();
}
