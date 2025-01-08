using AVosDroitsAPI.Models.DTOs;
using AVosDroitsAPI.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace AVosDroitsAPI.Controllers;

[ApiController]
[Route("api/questionnaire/questions")]
public class QuestionnaireQuestionController : ControllerBase
{
    private readonly IQuestionnaireQuestionService _questionService;

    public QuestionnaireQuestionController(IQuestionnaireQuestionService questionService)
    {
        _questionService = questionService;
    }

    [HttpGet("template")]
    public async Task<ActionResult<dynamic>> GetQuestionnaireTemplate()
    {
        try
        {
            var template = await _questionService.GetQuestionnaireTemplateAsync();
            return Ok(new
            {
                success = true,
                data = template
            });
        }
        catch (Exception ex)
        {
            return BadRequest(new
            {
                success = false,
                error = new { message = ex.Message }
            });
        }
    }

    [HttpGet("sections/{sectionId}")]
    public async Task<ActionResult<dynamic>> GetQuestionsBySection(string sectionId)
    {
        try
        {
            var questions = await _questionService.GetQuestionsBySectionAsync(sectionId);
            return Ok(new
            {
                success = true,
                data = new { questions }
            });
        }
        catch (Exception ex)
        {
            return BadRequest(new
            {
                success = false,
                error = new { message = ex.Message }
            });
        }
    }

    [HttpGet("{questionId}")]
    public async Task<ActionResult<dynamic>> GetQuestionById(string questionId)
    {
        try
        {
            var question = await _questionService.GetQuestionByIdAsync(questionId);
            return Ok(new
            {
                success = true,
                data = new { question }
            });
        }
        catch (InvalidOperationException ex)
        {
            return NotFound(new
            {
                success = false,
                error = new { message = ex.Message }
            });
        }
        catch (Exception ex)
        {
            return BadRequest(new
            {
                success = false,
                error = new { message = ex.Message }
            });
        }
    }

    [Authorize(Roles = "Admin")]
    [HttpPost]
    public async Task<ActionResult<dynamic>> CreateQuestion(CreateQuestionRequestDTO request)
    {
        try
        {
            var question = await _questionService.CreateQuestionAsync(request);
            return Ok(new
            {
                success = true,
                data = new { question },
                message = "Question created successfully"
            });
        }
        catch (Exception ex)
        {
            return BadRequest(new
            {
                success = false,
                error = new { message = ex.Message }
            });
        }
    }

    [Authorize(Roles = "Admin")]
    [HttpPut("{questionId}")]
    public async Task<ActionResult<dynamic>> UpdateQuestion(string questionId, UpdateQuestionRequestDTO request)
    {
        try
        {
            var question = await _questionService.UpdateQuestionAsync(questionId, request);
            return Ok(new
            {
                success = true,
                data = new { question },
                message = "Question updated successfully"
            });
        }
        catch (InvalidOperationException ex)
        {
            return NotFound(new
            {
                success = false,
                error = new { message = ex.Message }
            });
        }
        catch (Exception ex)
        {
            return BadRequest(new
            {
                success = false,
                error = new { message = ex.Message }
            });
        }
    }

    [Authorize(Roles = "Admin")]
    [HttpDelete("{questionId}")]
    public async Task<ActionResult<dynamic>> DeleteQuestion(string questionId)
    {
        try
        {
            await _questionService.DeleteQuestionAsync(questionId);
            return Ok(new
            {
                success = true,
                message = "Question deleted successfully"
            });
        }
        catch (InvalidOperationException ex)
        {
            return NotFound(new
            {
                success = false,
                error = new { message = ex.Message }
            });
        }
        catch (Exception ex)
        {
            return BadRequest(new
            {
                success = false,
                error = new { message = ex.Message }
            });
        }
    }

    [HttpPost("{questionId}/validate")]
    public async Task<ActionResult<dynamic>> ValidateAnswer(string questionId, [FromBody] object answer)
    {
        try
        {
            var isValid = await _questionService.ValidateAnswerAsync(questionId, answer);
            return Ok(new
            {
                success = true,
                data = new { isValid }
            });
        }
        catch (InvalidOperationException ex)
        {
            return NotFound(new
            {
                success = false,
                error = new { message = ex.Message }
            });
        }
        catch (Exception ex)
        {
            return BadRequest(new
            {
                success = false,
                error = new { message = ex.Message }
            });
        }
    }
} 