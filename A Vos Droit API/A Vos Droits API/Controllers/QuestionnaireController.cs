using AVosDroitsAPI.Models.DTOs;
using AVosDroitsAPI.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace AVosDroitsAPI.Controllers;

[Authorize]
[ApiController]
[Route("api/questionnaire")]
public class QuestionnaireController : ControllerBase
{
    private readonly IQuestionnaireService _questionnaireService;

    public QuestionnaireController(IQuestionnaireService questionnaireService)
    {
        _questionnaireService = questionnaireService;
    }

    [HttpGet]
    public async Task<ActionResult<dynamic>> GetQuestionnaire()
    {
        try
        {
            var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? 
                throw new InvalidOperationException("User ID not found in token"));

            var questionnaire = await _questionnaireService.GetQuestionnaireAsync(userId);
            
            return Ok(new
            {
                success = true,
                data = questionnaire
            });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new
            {
                success = false,
                error = new { message = ex.Message }
            });
        }
    }

    [HttpPost("submit")]
    public async Task<ActionResult<dynamic>> SubmitQuestionnaire(SubmitQuestionnaireRequestDTO request)
    {
        try
        {
            var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? 
                throw new InvalidOperationException("User ID not found in token"));

            var questionnaire = await _questionnaireService.SubmitQuestionnaireAsync(userId, request);
            
            return Ok(new
            {
                success = true,
                data = questionnaire,
                message = "Questionnaire submitted successfully"
            });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new
            {
                success = false,
                error = new { message = ex.Message }
            });
        }
    }

    [HttpPut("{userId}")]
    [Authorize(Roles = "Admin")] // Only admins can update other users' questionnaires
    public async Task<ActionResult<dynamic>> UpdateQuestionnaire(int userId, SubmitQuestionnaireRequestDTO request)
    {
        try
        {
            var questionnaire = await _questionnaireService.UpdateQuestionnaireAsync(userId, request);
            
            return Ok(new
            {
                success = true,
                data = questionnaire,
                message = "Questionnaire updated successfully"
            });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new
            {
                success = false,
                error = new { message = ex.Message }
            });
        }
    }
} 