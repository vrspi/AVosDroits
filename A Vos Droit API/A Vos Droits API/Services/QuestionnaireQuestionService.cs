using System.Text.Json;
using AVosDroitsAPI.Data;
using AVosDroitsAPI.Models.DTOs;
using AVosDroitsAPI.Models.Entities;
using AVosDroitsAPI.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace AVosDroitsAPI.Services;

public class QuestionnaireQuestionService : IQuestionnaireQuestionService
{
    private readonly ApplicationDbContext _context;
    private readonly Dictionary<string, QuestionnaireQuestion> _questionTemplates;

    public QuestionnaireQuestionService(ApplicationDbContext context)
    {
        _context = context;
        _questionTemplates = InitializeQuestionTemplates();
    }

    public async Task<QuestionnaireTemplateDTO> GetQuestionnaireTemplateAsync()
    {
        var template = new QuestionnaireTemplateDTO
        {
            Sections = new List<SectionTemplateDTO>
            {
                new()
                {
                    Id = "personal_info",
                    Title = "Informations Personnelles",
                    Order = 1,
                    Questions = _questionTemplates
                        .Where(q => q.Value.SectionId == "personal_info")
                        .OrderBy(q => q.Value.Order)
                        .Select(q => MapToQuestionDTO(q.Value))
                        .ToList()
                },
                new()
                {
                    Id = "family_status",
                    Title = "Situation Familiale",
                    Order = 2,
                    Questions = _questionTemplates
                        .Where(q => q.Value.SectionId == "family_status")
                        .OrderBy(q => q.Value.Order)
                        .Select(q => MapToQuestionDTO(q.Value))
                        .ToList()
                },
                new()
                {
                    Id = "housing",
                    Title = "Logement",
                    Order = 3,
                    Questions = _questionTemplates
                        .Where(q => q.Value.SectionId == "housing")
                        .OrderBy(q => q.Value.Order)
                        .Select(q => MapToQuestionDTO(q.Value))
                        .ToList()
                },
                new()
                {
                    Id = "employment",
                    Title = "Emploi et Revenus",
                    Order = 4,
                    Questions = _questionTemplates
                        .Where(q => q.Value.SectionId == "employment")
                        .OrderBy(q => q.Value.Order)
                        .Select(q => MapToQuestionDTO(q.Value))
                        .ToList()
                },
                new()
                {
                    Id = "social_situation",
                    Title = "Situation Sociale",
                    Order = 5,
                    Questions = _questionTemplates
                        .Where(q => q.Value.SectionId == "social_situation")
                        .OrderBy(q => q.Value.Order)
                        .Select(q => MapToQuestionDTO(q.Value))
                        .ToList()
                }
            }
        };

        await Task.CompletedTask;
        return template;
    }

    public async Task<List<QuestionnaireQuestionDTO>> GetQuestionsBySectionAsync(string sectionId)
    {
        var questions = _questionTemplates
            .Where(q => q.Value.SectionId == sectionId)
            .OrderBy(q => q.Value.Order)
            .Select(q => MapToQuestionDTO(q.Value))
            .ToList();

        await Task.CompletedTask;
        return questions;
    }

    public async Task<QuestionnaireQuestionDTO> GetQuestionByIdAsync(string questionId)
    {
        if (!_questionTemplates.TryGetValue(questionId, out var question))
        {
            throw new InvalidOperationException("Question not found");
        }

        await Task.CompletedTask;
        return MapToQuestionDTO(question);
    }

    public async Task<QuestionnaireQuestionDTO> CreateQuestionAsync(CreateQuestionRequestDTO request)
    {
        var questionId = $"custom_{Guid.NewGuid():N}";
        var question = new QuestionnaireQuestion
        {
            Id = questionId,
            SectionId = request.SectionId,
            Question = request.Question,
            Type = request.Type,
            Required = request.Required,
            ValidationRules = request.ValidationRules,
            Order = request.Order,
            Options = request.Options?.Select(o => new QuestionOption
            {
                Value = o.Value,
                Label = o.Label,
                Order = o.Order
            }).ToList()
        };

        _questionTemplates.Add(questionId, question);
        await Task.CompletedTask;
        return MapToQuestionDTO(question);
    }

    public async Task<QuestionnaireQuestionDTO> UpdateQuestionAsync(string questionId, UpdateQuestionRequestDTO request)
    {
        if (!_questionTemplates.TryGetValue(questionId, out var question))
        {
            throw new InvalidOperationException("Question not found");
        }

        question.Question = request.Question;
        question.Type = request.Type;
        question.Required = request.Required;
        question.ValidationRules = request.ValidationRules;
        question.Order = request.Order;
        question.Options = request.Options?.Select(o => new QuestionOption
        {
            Value = o.Value,
            Label = o.Label,
            Order = o.Order
        }).ToList();

        await Task.CompletedTask;
        return MapToQuestionDTO(question);
    }

    public async Task DeleteQuestionAsync(string questionId)
    {
        if (!_questionTemplates.Remove(questionId))
        {
            throw new InvalidOperationException("Question not found");
        }

        await Task.CompletedTask;
    }

    public async Task<bool> ValidateAnswerAsync(string questionId, object answer)
    {
        if (!_questionTemplates.TryGetValue(questionId, out var question))
        {
            throw new InvalidOperationException("Question not found");
        }

        if (question.Required && answer == null)
        {
            return false;
        }

        if (!string.IsNullOrEmpty(question.ValidationRules))
        {
            // Implement validation based on rules
            var rules = JsonSerializer.Deserialize<Dictionary<string, object>>(question.ValidationRules);
            // Add validation logic here
        }

        await Task.CompletedTask;
        return true;
    }

    private QuestionnaireQuestionDTO MapToQuestionDTO(QuestionnaireQuestion question)
    {
        return new QuestionnaireQuestionDTO
        {
            Id = question.Id,
            SectionId = question.SectionId,
            Question = question.Question,
            Type = question.Type,
            Required = question.Required,
            ValidationRules = question.ValidationRules,
            Order = question.Order,
            Options = question.Options?.Select(o => new QuestionOptionDTO
            {
                Id = o.Id,
                Value = o.Value,
                Label = o.Label,
                Order = o.Order
            }).ToList()
        };
    }

    private Dictionary<string, QuestionnaireQuestion> InitializeQuestionTemplates()
    {
        return new Dictionary<string, QuestionnaireQuestion>
        {
            // Personal Information Section
            {
                "name", new QuestionnaireQuestion
                {
                    Id = "name",
                    SectionId = "personal_info",
                    Question = "Quel est votre nom ?",
                    Type = "text",
                    Required = true,
                    Order = 1
                }
            },
            {
                "age", new QuestionnaireQuestion
                {
                    Id = "age",
                    SectionId = "personal_info",
                    Question = "Quel est votre âge ?",
                    Type = "number",
                    Required = true,
                    ValidationRules = JsonSerializer.Serialize(new { min = 0, max = 150 }),
                    Order = 2
                }
            },
            {
                "nationality", new QuestionnaireQuestion
                {
                    Id = "nationality",
                    SectionId = "personal_info",
                    Question = "Quelle est votre nationalité ?",
                    Type = "text",
                    Required = true,
                    Order = 3
                }
            },
            {
                "birth_date", new QuestionnaireQuestion
                {
                    Id = "birth_date",
                    SectionId = "personal_info",
                    Question = "Quelle est votre date de naissance ?",
                    Type = "date",
                    Required = true,
                    Order = 4
                }
            },

            // Family Status Section
            {
                "marital_status", new QuestionnaireQuestion
                {
                    Id = "marital_status",
                    SectionId = "family_status",
                    Question = "Quelle est votre situation familiale ?",
                    Type = "select",
                    Required = true,
                    Order = 1,
                    Options = new List<QuestionOption>
                    {
                        new() { Value = "single", Label = "Célibataire", Order = 1 },
                        new() { Value = "married", Label = "Marié(e)", Order = 2 },
                        new() { Value = "pacs", Label = "Pacsé(e)", Order = 3 },
                        new() { Value = "divorced", Label = "Divorcé(e)", Order = 4 },
                        new() { Value = "widowed", Label = "Veuf/Veuve", Order = 5 }
                    }
                }
            },
            {
                "dependents", new QuestionnaireQuestion
                {
                    Id = "dependents",
                    SectionId = "family_status",
                    Question = "Combien d'enfants à charge avez-vous ?",
                    Type = "select",
                    Required = true,
                    Order = 2,
                    Options = Enumerable.Range(0, 11)
                        .Select(i => new QuestionOption
                        {
                            Value = i.ToString(),
                            Label = i == 10 ? "10+" : i.ToString(),
                            Order = i + 1
                        }).ToList()
                }
            },

            // Housing Section
            {
                "housing_type", new QuestionnaireQuestion
                {
                    Id = "housing_type",
                    SectionId = "housing",
                    Question = "Quel est votre type de logement ?",
                    Type = "select",
                    Required = true,
                    Order = 1,
                    Options = new List<QuestionOption>
                    {
                        new() { Value = "owner", Label = "Propriétaire", Order = 1 },
                        new() { Value = "tenant", Label = "Locataire", Order = 2 },
                        new() { Value = "hosted", Label = "Hébergé", Order = 3 },
                        new() { Value = "homeless", Label = "Sans domicile fixe", Order = 4 }
                    }
                }
            },
            {
                "current_address", new QuestionnaireQuestion
                {
                    Id = "current_address",
                    SectionId = "housing",
                    Question = "Quelle est votre adresse actuelle ?",
                    Type = "text",
                    Required = true,
                    Order = 2
                }
            },
            {
                "residence_duration", new QuestionnaireQuestion
                {
                    Id = "residence_duration",
                    SectionId = "housing",
                    Question = "Depuis combien de temps habitez-vous à cette adresse ?",
                    Type = "text",
                    Required = true,
                    Order = 3
                }
            },

            // Employment Section
            {
                "employment_status", new QuestionnaireQuestion
                {
                    Id = "employment_status",
                    SectionId = "employment",
                    Question = "Quel est votre statut d'emploi ?",
                    Type = "select",
                    Required = true,
                    Order = 1,
                    Options = new List<QuestionOption>
                    {
                        new() { Value = "employed", Label = "Employé(e)", Order = 1 },
                        new() { Value = "self_employed", Label = "Indépendant(e)", Order = 2 },
                        new() { Value = "unemployed", Label = "Sans emploi", Order = 3 },
                        new() { Value = "student", Label = "Étudiant(e)", Order = 4 },
                        new() { Value = "retired", Label = "Retraité(e)", Order = 5 }
                    }
                }
            },
            {
                "sector", new QuestionnaireQuestion
                {
                    Id = "sector",
                    SectionId = "employment",
                    Question = "Dans quel secteur travaillez-vous ?",
                    Type = "text",
                    Required = false,
                    Order = 2
                }
            },
            {
                "contract_type", new QuestionnaireQuestion
                {
                    Id = "contract_type",
                    SectionId = "employment",
                    Question = "Quel est le type de votre contrat de travail ?",
                    Type = "text",
                    Required = false,
                    Order = 3
                }
            },
            {
                "monthly_income", new QuestionnaireQuestion
                {
                    Id = "monthly_income",
                    SectionId = "employment",
                    Question = "Quel est votre revenu mensuel brut ?",
                    Type = "number",
                    Required = false,
                    ValidationRules = JsonSerializer.Serialize(new { min = 0 }),
                    Order = 4
                }
            },
            {
                "job_seeker", new QuestionnaireQuestion
                {
                    Id = "job_seeker",
                    SectionId = "employment",
                    Question = "Êtes-vous inscrit à Pôle Emploi ?",
                    Type = "boolean",
                    Required = true,
                    Order = 5
                }
            },

            // Social Situation Section
            {
                "health_issues", new QuestionnaireQuestion
                {
                    Id = "health_issues",
                    SectionId = "social_situation",
                    Question = "Avez-vous des problèmes de santé qui nécessitent une assistance spécifique ?",
                    Type = "boolean",
                    Required = true,
                    Order = 1
                }
            },
            {
                "disability", new QuestionnaireQuestion
                {
                    Id = "disability",
                    SectionId = "social_situation",
                    Question = "Êtes-vous en situation de handicap ?",
                    Type = "boolean",
                    Required = true,
                    Order = 2
                }
            },
            {
                "immigrant_status", new QuestionnaireQuestion
                {
                    Id = "immigrant_status",
                    SectionId = "social_situation",
                    Question = "Avez-vous un statut d'immigrant ou de réfugié ?",
                    Type = "boolean",
                    Required = true,
                    Order = 3
                }
            },
            {
                "social_benefits", new QuestionnaireQuestion
                {
                    Id = "social_benefits",
                    SectionId = "social_situation",
                    Question = "Recevez-vous actuellement des allocations ou aides sociales ?",
                    Type = "boolean",
                    Required = true,
                    Order = 4
                }
            },
            {
                "debts", new QuestionnaireQuestion
                {
                    Id = "debts",
                    SectionId = "social_situation",
                    Question = "Avez-vous des dettes ou des crédits en cours ?",
                    Type = "boolean",
                    Required = true,
                    Order = 5
                }
            },
            {
                "housing_assistance", new QuestionnaireQuestion
                {
                    Id = "housing_assistance",
                    SectionId = "social_situation",
                    Question = "Êtes-vous bénéficiaire de l'aide au logement (APL) ?",
                    Type = "boolean",
                    Required = true,
                    Order = 6
                }
            },
            {
                "family_allowance", new QuestionnaireQuestion
                {
                    Id = "family_allowance",
                    SectionId = "social_situation",
                    Question = "Avez-vous déjà fait une demande d'allocations familiales ?",
                    Type = "boolean",
                    Required = true,
                    Order = 7
                }
            },
            {
                "other_income", new QuestionnaireQuestion
                {
                    Id = "other_income",
                    SectionId = "social_situation",
                    Question = "Avez-vous d'autres sources de revenus ?",
                    Type = "boolean",
                    Required = true,
                    Order = 8
                }
            }
        };
    }
} 