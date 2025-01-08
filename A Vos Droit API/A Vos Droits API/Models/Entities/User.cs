using System.ComponentModel.DataAnnotations;

namespace AVosDroitsAPI.Models.Entities;

public class User
{
    [Key]
    public int Id { get; set; }
    
    [Required]
    public string Name { get; set; } = string.Empty;
    
    [Required]
    public string Email { get; set; } = string.Empty;
    
    [Required]
    public string PasswordHash { get; set; } = string.Empty;
    
    public string? Phone { get; set; }
    public string? Address { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
    public string? Provider { get; set; }
    public string? ProviderId { get; set; }
} 