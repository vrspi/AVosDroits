using AVosDroitsAPI.Data;
using AVosDroitsAPI.Models.DTOs;
using AVosDroitsAPI.Models.Entities;
using AVosDroitsAPI.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace AVosDroitsAPI.Services;

public class QuestionnaireResponseService : IQuestionnaireResponseService
{
    private readonly ApplicationDbContext _context;
    private readonly IQuestionnaireQuestionService _questionService;

    public QuestionnaireResponseService(ApplicationDbContext context, IQuestionnaireQuestionService questionService)
    {
        _context = context;
        _questionService = questionService;
    }

    public async Task<QuestionnaireResponseDTO> CreateResponseAsync(int userId, CreateQuestionnaireResponseDTO request)
    {
        // Validate that the question exists
        await _questionService.GetQuestionByIdAsync(request.QuestionId);

        var response = new QuestionnaireResponse
        {
            UserId = userId,
            QuestionId = request.QuestionId,
            Answer = request.Answer,
            CreatedAt = DateTime.UtcNow
        };

        _context.QuestionnaireResponses.Add(response);
        await _context.SaveChangesAsync();

        return MapToDTO(response);
    }

    public async Task<QuestionnaireResponseDTO> UpdateResponseAsync(int userId, int responseId, UpdateQuestionnaireResponseDTO request)
    {
        var response = await _context.QuestionnaireResponses
            .FirstOrDefaultAsync(r => r.Id == responseId && r.UserId == userId);

        if (response == null)
        {
            throw new InvalidOperationException("Response not found");
        }

        response.Answer = request.Answer;
        response.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();

        return MapToDTO(response);
    }

    public async Task DeleteResponseAsync(int userId, int responseId)
    {
        var response = await _context.QuestionnaireResponses
            .FirstOrDefaultAsync(r => r.Id == responseId && r.UserId == userId);

        if (response == null)
        {
            throw new InvalidOperationException("Response not found");
        }

        _context.QuestionnaireResponses.Remove(response);
        await _context.SaveChangesAsync();
    }

    public async Task<QuestionnaireResponseDTO> GetResponseByIdAsync(int userId, int responseId)
    {
        var response = await _context.QuestionnaireResponses
            .FirstOrDefaultAsync(r => r.Id == responseId && r.UserId == userId);

        if (response == null)
        {
            throw new InvalidOperationException("Response not found");
        }

        return MapToDTO(response);
    }

    public async Task<List<QuestionnaireResponseDTO>> GetUserResponsesAsync(int userId)
    {
        var responses = await _context.QuestionnaireResponses
            .Where(r => r.UserId == userId)
            .OrderBy(r => r.CreatedAt)
            .ToListAsync();

        return responses.Select(MapToDTO).ToList();
    }

    public async Task<UserQuestionnaireResponsesDTO> GetUserQuestionnaireAsync(int userId)
    {
        var responses = await GetUserResponsesAsync(userId);

        return new UserQuestionnaireResponsesDTO
        {
            UserId = userId,
            Responses = responses
        };
    }

    private static QuestionnaireResponseDTO MapToDTO(QuestionnaireResponse response)
    {
        return new QuestionnaireResponseDTO
        {
            Id = response.Id,
            UserId = response.UserId,
            QuestionId = response.QuestionId,
            Answer = response.Answer,
            CreatedAt = response.CreatedAt,
            UpdatedAt = response.UpdatedAt
        };
    }
} 