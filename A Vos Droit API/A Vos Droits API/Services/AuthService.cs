using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using AVosDroitsAPI.Data;
using AVosDroitsAPI.Models.DTOs;
using AVosDroitsAPI.Models.Entities;
using AVosDroitsAPI.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;

namespace AVosDroitsAPI.Services;

public class AuthService : IAuthService
{
    private readonly ApplicationDbContext _context;
    private readonly IConfiguration _configuration;

    public AuthService(ApplicationDbContext context, IConfiguration configuration)
    {
        _context = context;
        _configuration = configuration;
    }

    public async Task<AuthResponseDTO> RegisterAsync(RegisterRequestDTO request)
    {
        if (await _context.Users.AnyAsync(u => u.Email == request.Email))
        {
            throw new InvalidOperationException("Email already registered");
        }

        var user = new User
        {
            Name = request.Name,
            Email = request.Email,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password),
            CreatedAt = DateTime.UtcNow
        };

        _context.Users.Add(user);
        await _context.SaveChangesAsync();

        var userDto = new UserDTO
        {
            Id = user.Id,
            Name = user.Name,
            Email = user.Email,
            CreatedAt = user.CreatedAt
        };

        return new AuthResponseDTO
        {
            User = userDto,
            AccessToken = await GenerateJwtToken(userDto)
        };
    }

    public async Task<AuthResponseDTO> LoginAsync(LoginRequestDTO request)
    {
        var user = await _context.Users
            .FirstOrDefaultAsync(u => u.Email == request.Email);

        if (user == null || !BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash))
        {
            throw new InvalidOperationException("Invalid credentials");
        }

        var userDto = new UserDTO
        {
            Id = user.Id,
            Name = user.Name,
            Email = user.Email,
            CreatedAt = user.CreatedAt
        };

        return new AuthResponseDTO
        {
            User = userDto,
            AccessToken = await GenerateJwtToken(userDto)
        };
    }

    public async Task<AuthResponseDTO> SocialLoginAsync(SocialLoginRequestDTO request)
    {
        var user = await _context.Users
            .FirstOrDefaultAsync(u => u.Provider == request.Provider && u.ProviderId == request.AccessToken);

        if (user == null)
        {
            user = new User
            {
                Name = "Social User",
                Email = "social@example.com",
                Provider = request.Provider,
                ProviderId = request.AccessToken,
                CreatedAt = DateTime.UtcNow
            };

            _context.Users.Add(user);
            await _context.SaveChangesAsync();
        }

        var userDto = new UserDTO
        {
            Id = user.Id,
            Name = user.Name,
            Email = user.Email,
            CreatedAt = user.CreatedAt
        };

        return new AuthResponseDTO
        {
            User = userDto,
            AccessToken = await GenerateJwtToken(userDto)
        };
    }

    public async Task<bool> ForgotPasswordAsync(string email)
    {
        var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == email);
        
        if (user == null)
        {
            return false;
        }
        
        return true;
    }

    public async Task<string> GenerateJwtToken(UserDTO user)
    {
        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_configuration["Jwt:Key"] ?? throw new InvalidOperationException("JWT Key not configured")));
        var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var claims = new List<Claim>
        {
            new Claim(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
            new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
            new Claim(ClaimTypes.Email, user.Email),
            new Claim(ClaimTypes.Name, user.Name),
            new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
            new Claim(JwtRegisteredClaimNames.Iat, DateTimeOffset.UtcNow.ToUnixTimeSeconds().ToString())
        };

        var token = new JwtSecurityToken(
            issuer: _configuration["Jwt:Issuer"],
            audience: _configuration["Jwt:Audience"],
            claims: claims,
            expires: DateTime.UtcNow.AddDays(7),
            signingCredentials: credentials
        );

        await Task.CompletedTask; // Just to keep the method async
        return new JwtSecurityTokenHandler().WriteToken(token);
    }
} 