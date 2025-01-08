using AVosDroitsAPI.Models.DTOs;

namespace AVosDroitsAPI.Services.Interfaces;

public interface IQuestionnaireResponseService
{
    Task<QuestionnaireResponseDTO> CreateResponseAsync(int userId, CreateQuestionnaireResponseDTO request);
    Task<QuestionnaireResponseDTO> UpdateResponseAsync(int userId, int responseId, UpdateQuestionnaireResponseDTO request);
    Task DeleteResponseAsync(int userId, int responseId);
    Task<QuestionnaireResponseDTO> GetResponseByIdAsync(int userId, int responseId);
    Task<List<QuestionnaireResponseDTO>> GetUserResponsesAsync(int userId);
    Task<UserQuestionnaireResponsesDTO> GetUserQuestionnaireAsync(int userId);
} 