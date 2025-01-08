using System.ComponentModel.DataAnnotations;

namespace AVosDroitsAPI.Models.DTOs;

public class QuestionnaireDTO
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public DateTime CompletedAt { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
    public int Version { get; set; }
    public List<QuestionnaireSectionDTO> Sections { get; set; } = new();
}

public class QuestionnaireSectionDTO
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public int Order { get; set; }
    public List<QuestionnaireResponseDTO> Responses { get; set; } = new();
}

public class QuestionnaireResponseDTO
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public string QuestionId { get; set; } = string.Empty;
    public string Answer { get; set; } = string.Empty;
    public int Version { get; set; }
    public string SessionId { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
}

public class CreateQuestionnaireResponseDTO
{
    [Required]
    public string QuestionId { get; set; } = string.Empty;
    
    [Required]
    public string Answer { get; set; } = string.Empty;
    
    [Required]
    public string SessionId { get; set; } = string.Empty;
}

public class UpdateQuestionnaireResponseDTO
{
    [Required]
    public string Answer { get; set; } = string.Empty;
    
    [Required]
    public string SessionId { get; set; } = string.Empty;
}

public class UserQuestionnaireResponsesDTO
{
    public int UserId { get; set; }
    public List<QuestionnaireResponseDTO> Responses { get; set; } = new();
}

public class QuestionDTO
{
    public string Id { get; set; } = string.Empty;
    public string Question { get; set; } = string.Empty;
    public string Type { get; set; } = string.Empty;
    public object Answer { get; set; } = null!;
}

public class SubmitQuestionnaireRequestDTO
{
    [Required]
    public List<SectionSubmissionDTO> Sections { get; set; } = new();
}

public class SectionSubmissionDTO
{
    [Required]
    public string SectionId { get; set; } = string.Empty;
    
    [Required]
    public List<QuestionAnswerDTO> Answers { get; set; } = new();
}

public class QuestionAnswerDTO
{
    [Required]
    public string QuestionId { get; set; } = string.Empty;
    
    [Required]
    public object Answer { get; set; } = null!;
}

// Validation DTOs for specific question types
public class PersonalInfoValidationDTO
{
    [Required]
    public string Name { get; set; } = string.Empty;
    
    [Required]
    [Range(0, 150)]
    public int Age { get; set; }
    
    [Required]
    public string Nationality { get; set; } = string.Empty;
    
    [Required]
    public DateTime DateOfBirth { get; set; }
}

public class FamilyStatusValidationDTO
{
    [Required]
    public string MaritalStatus { get; set; } = string.Empty;
    
    [Required]
    [Range(0, 20)]
    public int NumberOfDependents { get; set; }
}

public class HousingValidationDTO
{
    [Required]
    public string HousingType { get; set; } = string.Empty;
    
    [Required]
    public string CurrentAddress { get; set; } = string.Empty;
    
    [Required]
    public string ResidenceDuration { get; set; } = string.Empty;
}

public class EmploymentValidationDTO
{
    [Required]
    public string EmploymentStatus { get; set; } = string.Empty;
    
    public string? Sector { get; set; }
    public string? ContractType { get; set; }
    
    [Range(0, double.MaxValue)]
    public decimal? MonthlyIncome { get; set; }
    
    [Required]
    public bool IsRegisteredJobSeeker { get; set; }
}

public class SocialSituationValidationDTO
{
    [Required]
    public bool HasHealthIssues { get; set; }
    
    [Required]
    public bool HasDisability { get; set; }
    
    [Required]
    public bool IsImmigrantOrRefugee { get; set; }
    
    [Required]
    public bool ReceivesSocialBenefits { get; set; }
    
    [Required]
    public bool HasDebtsOrCredits { get; set; }
    
    [Required]
    public bool ReceivesHousingAssistance { get; set; }
    
    [Required]
    public bool HasAppliedForFamilyAllowance { get; set; }
    
    [Required]
    public bool HasOtherIncomeSource { get; set; }
} 