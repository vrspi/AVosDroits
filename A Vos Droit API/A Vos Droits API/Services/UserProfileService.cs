using AVosDroitsAPI.Data;
using AVosDroitsAPI.Models.DTOs;
using AVosDroitsAPI.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace AVosDroitsAPI.Services;

public class UserProfileService : IUserProfileService
{
    private readonly ApplicationDbContext _context;

    public UserProfileService(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<UserProfileDTO> GetProfileAsync(int userId)
    {
        var user = await _context.Users
            .FirstOrDefaultAsync(u => u.Id == userId);

        if (user == null)
        {
            throw new InvalidOperationException("User not found");
        }

        return new UserProfileDTO
        {
            Id = user.Id,
            Name = user.Name,
            Email = user.Email,
            Phone = user.Phone,
            Address = user.Address,
            CreatedAt = user.CreatedAt
        };
    }

    public async Task<UserProfileDTO> UpdateProfileAsync(int userId, UpdateProfileRequestDTO request)
    {
        var user = await _context.Users
            .FirstOrDefaultAsync(u => u.Id == userId);

        if (user == null)
        {
            throw new InvalidOperationException("User not found");
        }

        user.Name = request.Name;
        user.Phone = request.Phone;
        user.Address = request.Address;
        user.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();

        return new UserProfileDTO
        {
            Id = user.Id,
            Name = user.Name,
            Email = user.Email,
            Phone = user.Phone,
            Address = user.Address,
            CreatedAt = user.CreatedAt
        };
    }
} 