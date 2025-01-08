using System.ComponentModel.DataAnnotations;

namespace AVosDroitsAPI.Models.DTOs;

public class UserProfileDTO
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string? Phone { get; set; }
    public string? Address { get; set; }
    public DateTime CreatedAt { get; set; }
}

public class UpdateProfileRequestDTO
{
    [Required]
    public string Name { get; set; } = string.Empty;
    
    [Phone]
    public string? Phone { get; set; }
    
    public string? Address { get; set; }
} 