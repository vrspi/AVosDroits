using System.ComponentModel.DataAnnotations;

namespace AVosDroitsAPI.Models.DTOs;

public class RegisterRequestDTO
{
    [Required]
    public string Name { get; set; } = string.Empty;
    
    [Required]
    [EmailAddress]
    public string Email { get; set; } = string.Empty;
    
    [Required]
    [MinLength(6)]
    public string Password { get; set; } = string.Empty;
    
    [Required]
    [Compare("Password")]
    public string PasswordConfirmation { get; set; } = string.Empty;
}

public class LoginRequestDTO
{
    [Required]
    [EmailAddress]
    public string Email { get; set; } = string.Empty;
    
    [Required]
    public string Password { get; set; } = string.Empty;
}

public class SocialLoginRequestDTO
{
    [Required]
    public string Provider { get; set; } = string.Empty;
    
    [Required]
    public string AccessToken { get; set; } = string.Empty;
}

public class ForgotPasswordRequestDTO
{
    [Required]
    [EmailAddress]
    public string Email { get; set; } = string.Empty;
}

public class AuthResponseDTO
{
    public UserDTO User { get; set; } = null!;
    public string AccessToken { get; set; } = string.Empty;
}

public class UserDTO
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
} 