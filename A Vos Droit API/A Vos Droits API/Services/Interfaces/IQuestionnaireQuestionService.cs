using AVosDroitsAPI.Models.DTOs;

namespace AVosDroitsAPI.Services.Interfaces;

public interface IQuestionnaireQuestionService
{
    Task<QuestionnaireTemplateDTO> GetQuestionnaireTemplateAsync();
    Task<List<QuestionnaireQuestionDTO>> GetQuestionsBySectionAsync(string sectionId);
    Task<QuestionnaireQuestionDTO> GetQuestionByIdAsync(string questionId);
    Task<QuestionnaireQuestionDTO> CreateQuestionAsync(CreateQuestionRequestDTO request);
    Task<QuestionnaireQuestionDTO> UpdateQuestionAsync(string questionId, UpdateQuestionRequestDTO request);
    Task DeleteQuestionAsync(string questionId);
    Task<bool> ValidateAnswerAsync(string questionId, object answer);
} 