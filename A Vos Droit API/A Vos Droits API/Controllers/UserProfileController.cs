using AVosDroitsAPI.Models.DTOs;
using AVosDroitsAPI.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace AVosDroitsAPI.Controllers;

[Authorize]
[ApiController]
[Route("api/user")]
public class UserProfileController : ControllerBase
{
    private readonly IUserProfileService _userProfileService;

    public UserProfileController(IUserProfileService userProfileService)
    {
        _userProfileService = userProfileService;
    }

    [HttpGet("profile")]
    public async Task<ActionResult<dynamic>> GetProfile()
    {
        try
        {
            var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? 
                throw new InvalidOperationException("User ID not found in token"));

            var profile = await _userProfileService.GetProfileAsync(userId);
            
            return Ok(new
            {
                success = true,
                data = new { user = profile }
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

    [HttpPut("profile")]
    public async Task<ActionResult<dynamic>> UpdateProfile(UpdateProfileRequestDTO request)
    {
        try
        {
            var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? 
                throw new InvalidOperationException("User ID not found in token"));

            var profile = await _userProfileService.UpdateProfileAsync(userId, request);
            
            return Ok(new
            {
                success = true,
                data = new { user = profile },
                message = "Profile updated successfully"
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