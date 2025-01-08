using AVosDroitsAPI.Models.DTOs;

namespace AVosDroitsAPI.Services.Interfaces;

public interface IUserProfileService
{
    Task<UserProfileDTO> GetProfileAsync(int userId);
    Task<UserProfileDTO> UpdateProfileAsync(int userId, UpdateProfileRequestDTO request);
} 