using AVosDroitsAPI.Models.DTOs;
using AVosDroitsAPI.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace AVosDroitsAPI.Controllers;

[ApiController]
[Authorize]
[Route("api/questionnaire/responses")]
public class QuestionnaireResponseController : ControllerBase
{
    private readonly IQuestionnaireResponseService _responseService;

    public QuestionnaireResponseController(IQuestionnaireResponseService responseService)
    {
        _responseService = responseService;
    }

    private ActionResult<int> GetUserId()
    {
        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
        if (userIdClaim == null)
        {
            return BadRequest(new
            {
                success = false,
                error = new { message = "User ID claim is missing" }
            });
        }

        if (!int.TryParse(userIdClaim.Value, out var userId))
        {
            return BadRequest(new
            {
                success = false,
                error = new { message = "Invalid user ID format" }
            });
        }

        return userId;
    }

    [HttpPost]
    public async Task<ActionResult<dynamic>> CreateResponse(CreateQuestionnaireResponseDTO request)
    {
        try
        {
            var userIdResult = GetUserId();
            if (userIdResult.Result is ObjectResult)
            {
                return userIdResult.Result;
            }

            var userId = userIdResult.Value;
            var response = await _responseService.CreateResponseAsync(userId, request);
            return Ok(new
            {
                success = true,
                data = new { response },
                message = "Response created successfully"
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

    [HttpPost("admin/{userId}")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<dynamic>> CreateResponseForUser(int userId, CreateQuestionnaireResponseDTO request)
    {
        try
        {
            var response = await _responseService.CreateResponseAsync(userId, request);
            return Ok(new
            {
                success = true,
                data = new { response },
                message = "Response created successfully"
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

    [HttpPut("{responseId}")]
    [Authorize]
    public async Task<ActionResult<dynamic>> UpdateResponse(int responseId, UpdateQuestionnaireResponseDTO request)
    {
        try
        {
            var userIdResult = GetUserId();
            if (userIdResult.Result is ObjectResult)
            {
                return userIdResult.Result;
            }

            var userId = userIdResult.Value;
            var response = await _responseService.UpdateResponseAsync(userId, responseId, request);
            return Ok(new
            {
                success = true,
                data = new { response },
                message = "Response updated successfully"
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

    [HttpPut("admin/{userId}/responses/{responseId}")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<dynamic>> UpdateResponseForUser(int userId, int responseId, UpdateQuestionnaireResponseDTO request)
    {
        try
        {
            var response = await _responseService.UpdateResponseAsync(userId, responseId, request);
            return Ok(new
            {
                success = true,
                data = new { response },
                message = "Response updated successfully"
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

    [HttpDelete("{responseId}")]
    [Authorize]
    public async Task<ActionResult<dynamic>> DeleteResponse(int responseId)
    {
        try
        {
            var userIdResult = GetUserId();
            if (userIdResult.Result is ObjectResult)
            {
                return userIdResult.Result;
            }

            var userId = userIdResult.Value;
            await _responseService.DeleteResponseAsync(userId, responseId);
            return Ok(new
            {
                success = true,
                message = "Response deleted successfully"
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

    [HttpDelete("admin/{userId}/responses/{responseId}")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<dynamic>> DeleteResponseForUser(int userId, int responseId)
    {
        try
        {
            await _responseService.DeleteResponseAsync(userId, responseId);
            return Ok(new
            {
                success = true,
                message = "Response deleted successfully"
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

    [HttpGet("{responseId}")]
    [Authorize]
    public async Task<ActionResult<dynamic>> GetResponseById(int responseId)
    {
        try
        {
            var userIdResult = GetUserId();
            if (userIdResult.Result is ObjectResult)
            {
                return userIdResult.Result;
            }

            var userId = userIdResult.Value;
            var response = await _responseService.GetResponseByIdAsync(userId, responseId);
            return Ok(new
            {
                success = true,
                data = new { response }
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

    [HttpGet("admin/{userId}/responses/{responseId}")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<dynamic>> GetResponseByIdForUser(int userId, int responseId)
    {
        try
        {
            var response = await _responseService.GetResponseByIdAsync(userId, responseId);
            return Ok(new
            {
                success = true,
                data = new { response }
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

    [HttpGet("my")]
    [Authorize]
    public async Task<ActionResult<dynamic>> GetMyResponses()
    {
        try
        {
            var userIdResult = GetUserId();
            if (userIdResult.Result is ObjectResult)
            {
                return userIdResult.Result;
            }

            var userId = userIdResult.Value;
            var responses = await _responseService.GetUserResponsesAsync(userId);
            return Ok(new
            {
                success = true,
                data = new { responses }
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

    [HttpGet("admin/{userId}/responses")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<dynamic>> GetUserResponses(int userId)
    {
        try
        {
            var responses = await _responseService.GetUserResponsesAsync(userId);
            return Ok(new
            {
                success = true,
                data = new { responses }
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

    [HttpGet("my/questionnaire")]
    [Authorize]
    public async Task<ActionResult<dynamic>> GetMyQuestionnaire()
    {
        try
        {
            var userIdResult = GetUserId();
            if (userIdResult.Result is ObjectResult)
            {
                return userIdResult.Result;
            }

            var userId = userIdResult.Value;
            var questionnaire = await _responseService.GetUserQuestionnaireAsync(userId);
            return Ok(new
            {
                success = true,
                data = new { questionnaire }
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

    [HttpGet("admin/{userId}/questionnaire")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<dynamic>> GetUserQuestionnaire(int userId)
    {
        try
        {
            var questionnaire = await _responseService.GetUserQuestionnaireAsync(userId);
            return Ok(new
            {
                success = true,
                data = new { questionnaire }
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