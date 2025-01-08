using System.ComponentModel.DataAnnotations;

namespace AVosDroitsAPI.Models.DTOs;

public class QuestionnaireQuestionDTO
{
    public string Id { get; set; } = string.Empty;
    public string SectionId { get; set; } = string.Empty;
    public string Question { get; set; } = string.Empty;
    public string Type { get; set; } = string.Empty;
    public bool Required { get; set; }
    public string? ValidationRules { get; set; }
    public int Order { get; set; }
    public List<QuestionOptionDTO>? Options { get; set; }
}

public class QuestionOptionDTO
{
    public int Id { get; set; }
    public string Value { get; set; } = string.Empty;
    public string Label { get; set; } = string.Empty;
    public int Order { get; set; }
}

public class CreateQuestionRequestDTO
{
    [Required]
    public string SectionId { get; set; } = string.Empty;
    
    [Required]
    public string Question { get; set; } = string.Empty;
    
    [Required]
    public string Type { get; set; } = string.Empty;
    
    public bool Required { get; set; }
    
    public string? ValidationRules { get; set; }
    
    public int Order { get; set; }
    
    public List<CreateQuestionOptionDTO>? Options { get; set; }
}

public class CreateQuestionOptionDTO
{
    [Required]
    public string Value { get; set; } = string.Empty;
    
    [Required]
    public string Label { get; set; } = string.Empty;
    
    public int Order { get; set; }
}

public class UpdateQuestionRequestDTO
{
    [Required]
    public string Question { get; set; } = string.Empty;
    
    [Required]
    public string Type { get; set; } = string.Empty;
    
    public bool Required { get; set; }
    
    public string? ValidationRules { get; set; }
    
    public int Order { get; set; }
    
    public List<CreateQuestionOptionDTO>? Options { get; set; }
}

public class QuestionnaireTemplateDTO
{
    public List<SectionTemplateDTO> Sections { get; set; } = new();
}

public class SectionTemplateDTO
{
    public string Id { get; set; } = string.Empty;
    public string Title { get; set; } = string.Empty;
    public int Order { get; set; }
    public List<QuestionnaireQuestionDTO> Questions { get; set; } = new();
} 