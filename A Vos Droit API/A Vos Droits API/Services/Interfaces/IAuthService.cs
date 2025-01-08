using AVosDroitsAPI.Models.DTOs;

namespace AVosDroitsAPI.Services.Interfaces;

public interface IAuthService
{
    Task<AuthResponseDTO> RegisterAsync(RegisterRequestDTO request);
    Task<AuthResponseDTO> LoginAsync(LoginRequestDTO request);
    Task<AuthResponseDTO> SocialLoginAsync(SocialLoginRequestDTO request);
    Task<bool> ForgotPasswordAsync(string email);
    Task<string> GenerateJwtToken(UserDTO user);
} 