using AVosDroitsAPI.Models.DTOs;

namespace AVosDroitsAPI.Services.Interfaces;

public interface IQuestionnaireService
{
    Task<QuestionnaireDTO> GetQuestionnaireAsync(int userId);
    Task<QuestionnaireDTO> SubmitQuestionnaireAsync(int userId, SubmitQuestionnaireRequestDTO request);
    Task<QuestionnaireDTO> UpdateQuestionnaireAsync(int userId, SubmitQuestionnaireRequestDTO request);
    Task ValidateQuestionnaireResponsesAsync(SubmitQuestionnaireRequestDTO request);
} 