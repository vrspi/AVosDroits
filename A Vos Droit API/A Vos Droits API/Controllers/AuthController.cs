using AVosDroitsAPI.Models.DTOs;
using AVosDroitsAPI.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace AVosDroitsAPI.Controllers;

[ApiController]
[Route("api/auth")]
public class AuthController : ControllerBase
{
    private readonly IAuthService _authService;

    public AuthController(IAuthService authService)
    {
        _authService = authService;
    }

    [HttpPost("register")]
    public async Task<ActionResult<dynamic>> Register(RegisterRequestDTO request)
    {
        try
        {
            var response = await _authService.RegisterAsync(request);
            return Ok(new
            {
                success = true,
                data = response,
                message = "Registration successful"
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

    [HttpPost("login")]
    public async Task<ActionResult<dynamic>> Login(LoginRequestDTO request)
    {
        try
        {
            var response = await _authService.LoginAsync(request);
            return Ok(new
            {
                success = true,
                data = response,
                message = "Login successful"
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

    [HttpPost("social-login")]
    public async Task<ActionResult<dynamic>> SocialLogin(SocialLoginRequestDTO request)
    {
        try
        {
            var response = await _authService.SocialLoginAsync(request);
            return Ok(new
            {
                success = true,
                data = response,
                message = "Social login successful"
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

    [HttpPost("forgot-password")]
    public async Task<ActionResult<dynamic>> ForgotPassword(ForgotPasswordRequestDTO request)
    {
        var result = await _authService.ForgotPasswordAsync(request.Email);
        
        return Ok(new
        {
            success = true,
            message = "Password reset link sent to email"
        });
    }
} 