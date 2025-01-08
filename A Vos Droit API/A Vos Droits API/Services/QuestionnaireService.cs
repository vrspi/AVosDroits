using System.Text.Json;
using AVosDroitsAPI.Data;
using AVosDroitsAPI.Models.DTOs;
using AVosDroitsAPI.Models.Entities;
using AVosDroitsAPI.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace AVosDroitsAPI.Services;

public class QuestionnaireService : IQuestionnaireService
{
    private readonly ApplicationDbContext _context;

    public QuestionnaireService(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<QuestionnaireDTO> GetQuestionnaireAsync(int userId)
    {
        var questionnaire = await _context.Questionnaires
            .Include(q => q.Sections)
            .ThenInclude(s => s.Responses)
            .Where(q => q.UserId == userId)
            .OrderByDescending(q => q.Version)
            .FirstOrDefaultAsync();

        if (questionnaire == null)
        {
            throw new InvalidOperationException("No questionnaire found for this user");
        }

        return MapToDTO(questionnaire);
    }

    public async Task<QuestionnaireDTO> SubmitQuestionnaireAsync(int userId, SubmitQuestionnaireRequestDTO request)
    {
        await ValidateQuestionnaireResponsesAsync(request);

        var version = await _context.Questionnaires
            .Where(q => q.UserId == userId)
            .MaxAsync(q => (int?)q.Version) ?? 0;

        var questionnaire = new Questionnaire
        {
            UserId = userId,
            Version = version + 1,
            CompletedAt = DateTime.UtcNow,
            CreatedAt = DateTime.UtcNow
        };

        _context.Questionnaires.Add(questionnaire);
        
        foreach (var sectionDto in request.Sections)
        {
            var section = new QuestionnaireSection
            {
                Questionnaire = questionnaire,
                Title = GetSectionTitle(sectionDto.SectionId),
                Order = GetSectionOrder(sectionDto.SectionId)
            };

            _context.QuestionnaireSections.Add(section);

            foreach (var answer in sectionDto.Answers)
            {
                var response = new QuestionnaireResponse
                {
                    UserId = userId,
                    QuestionId = answer.QuestionId,
                    Answer = JsonSerializer.Serialize(answer.Answer)
                };

                _context.QuestionnaireResponses.Add(response);
            }
        }

        await _context.SaveChangesAsync();
        
        return await GetQuestionnaireAsync(userId);
    }

    public async Task<QuestionnaireDTO> UpdateQuestionnaireAsync(int userId, SubmitQuestionnaireRequestDTO request)
    {
        await ValidateQuestionnaireResponsesAsync(request);
        
        var latestQuestionnaire = await _context.Questionnaires
            .Include(q => q.Sections)
            .ThenInclude(s => s.Responses)
            .Where(q => q.UserId == userId)
            .OrderByDescending(q => q.Version)
            .FirstOrDefaultAsync();

        if (latestQuestionnaire == null)
        {
            return await SubmitQuestionnaireAsync(userId, request);
        }

        latestQuestionnaire.UpdatedAt = DateTime.UtcNow;
        
        // Remove existing responses
        foreach (var section in latestQuestionnaire.Sections)
        {
            _context.QuestionnaireResponses.RemoveRange(section.Responses);
        }
        _context.QuestionnaireSections.RemoveRange(latestQuestionnaire.Sections);

        // Add new responses
        foreach (var sectionDto in request.Sections)
        {
            var section = new QuestionnaireSection
            {
                Questionnaire = latestQuestionnaire,
                Title = GetSectionTitle(sectionDto.SectionId),
                Order = GetSectionOrder(sectionDto.SectionId)
            };

            _context.QuestionnaireSections.Add(section);

            foreach (var answer in sectionDto.Answers)
            {
                var response = new QuestionnaireResponse
                {
                    UserId = userId,
                    QuestionId = answer.QuestionId,
                    Answer = JsonSerializer.Serialize(answer.Answer)
                };

                _context.QuestionnaireResponses.Add(response);
            }
        }

        await _context.SaveChangesAsync();
        
        return await GetQuestionnaireAsync(userId);
    }

    private QuestionnaireDTO MapToDTO(Questionnaire questionnaire)
    {
        return new QuestionnaireDTO
        {
            Id = questionnaire.Id,
            UserId = questionnaire.UserId,
            CompletedAt = questionnaire.CompletedAt,
            CreatedAt = questionnaire.CreatedAt,
            UpdatedAt = questionnaire.UpdatedAt,
            Version = questionnaire.Version,
            Sections = questionnaire.Sections.Select(s => new QuestionnaireSectionDTO
            {
                Id = s.Id,
                Title = s.Title,
                Order = s.Order,
                Responses = s.Responses.Select(r => new QuestionnaireResponseDTO
                {
                    Id = r.Id,
                    UserId = r.UserId,
                    QuestionId = r.QuestionId,
                    Answer = r.Answer,
                    CreatedAt = r.CreatedAt,
                    UpdatedAt = r.UpdatedAt
                }).ToList()
            }).ToList()
        };
    }

    private string GetSectionTitle(string sectionId) => sectionId switch
    {
        "personal_info" => "Informations Personnelles",
        "family_status" => "Situation Familiale",
        "housing" => "Logement",
        "employment" => "Emploi et Revenus",
        "social_situation" => "Situation Sociale",
        _ => throw new InvalidOperationException($"Invalid section ID: {sectionId}")
    };

    private int GetSectionOrder(string sectionId) => sectionId switch
    {
        "personal_info" => 1,
        "family_status" => 2,
        "housing" => 3,
        "employment" => 4,
        "social_situation" => 5,
        _ => throw new InvalidOperationException($"Invalid section ID: {sectionId}")
    };

    public async Task ValidateQuestionnaireResponsesAsync(SubmitQuestionnaireRequestDTO request)
    {
        foreach (var section in request.Sections)
        {
            switch (section.SectionId)
            {
                case "personal_info":
                    ValidatePersonalInfo(section);
                    break;
                case "family_status":
                    ValidateFamilyStatus(section);
                    break;
                case "housing":
                    ValidateHousing(section);
                    break;
                case "employment":
                    ValidateEmployment(section);
                    break;
                case "social_situation":
                    ValidateSocialSituation(section);
                    break;
                default:
                    throw new InvalidOperationException($"Invalid section ID: {section.SectionId}");
            }
        }

        await Task.CompletedTask;
    }

    private void ValidatePersonalInfo(SectionSubmissionDTO section)
    {
        var data = JsonSerializer.Deserialize<PersonalInfoValidationDTO>(
            JsonSerializer.Serialize(section.Answers.ToDictionary(a => a.QuestionId, a => a.Answer)));
            
        if (data == null)
            throw new InvalidOperationException("Invalid personal information data");
            
        // Additional validation logic here
    }

    private void ValidateFamilyStatus(SectionSubmissionDTO section)
    {
        var data = JsonSerializer.Deserialize<FamilyStatusValidationDTO>(
            JsonSerializer.Serialize(section.Answers.ToDictionary(a => a.QuestionId, a => a.Answer)));
            
        if (data == null)
            throw new InvalidOperationException("Invalid family status data");
            
        // Additional validation logic here
    }

    private void ValidateHousing(SectionSubmissionDTO section)
    {
        var data = JsonSerializer.Deserialize<HousingValidationDTO>(
            JsonSerializer.Serialize(section.Answers.ToDictionary(a => a.QuestionId, a => a.Answer)));
            
        if (data == null)
            throw new InvalidOperationException("Invalid housing data");
            
        // Additional validation logic here
    }

    private void ValidateEmployment(SectionSubmissionDTO section)
    {
        var data = JsonSerializer.Deserialize<EmploymentValidationDTO>(
            JsonSerializer.Serialize(section.Answers.ToDictionary(a => a.QuestionId, a => a.Answer)));
            
        if (data == null)
            throw new InvalidOperationException("Invalid employment data");
            
        // Additional validation logic here
    }

    private void ValidateSocialSituation(SectionSubmissionDTO section)
    {
        var data = JsonSerializer.Deserialize<SocialSituationValidationDTO>(
            JsonSerializer.Serialize(section.Answers.ToDictionary(a => a.QuestionId, a => a.Answer)));
            
        if (data == null)
            throw new InvalidOperationException("Invalid social situation data");
            
        // Additional validation logic here
    }
} 