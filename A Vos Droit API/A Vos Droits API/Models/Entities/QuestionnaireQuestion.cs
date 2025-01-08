using System.ComponentModel.DataAnnotations;

namespace AVosDroitsAPI.Models.Entities;

public class QuestionnaireQuestion
{
    [Key]
    public string Id { get; set; } = string.Empty;
    
    [Required]
    public string SectionId { get; set; } = string.Empty;
    
    [Required]
    public string Question { get; set; } = string.Empty;
    
    [Required]
    public string Type { get; set; } = string.Empty;
    
    public bool Required { get; set; }
    
    public string? ValidationRules { get; set; }
    
    public int Order { get; set; }
    
    public List<QuestionOption> Options { get; set; } = new();
}

public class QuestionOption
{
    [Key]
    public int Id { get; set; }
    
    [Required]
    public string QuestionId { get; set; } = string.Empty;
    
    [Required]
    public string Value { get; set; } = string.Empty;
    
    [Required]
    public string Label { get; set; } = string.Empty;
    
    public int Order { get; set; }
} 