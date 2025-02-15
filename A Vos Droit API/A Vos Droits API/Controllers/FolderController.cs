using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using AVosDroitsAPI.Models.Entities;
using AVosDroitsAPI.Data;
using System.Security.Claims;

namespace AVosDroitsAPI.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class FolderController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly IConfiguration _configuration;

    public FolderController(ApplicationDbContext context, IConfiguration configuration)
    {
        _context = context;
        _configuration = configuration;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<UserFolder>>> GetUserFolders()
    {
        var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "0");
        var folders = await _context.UserFolders
            .Where(f => f.UserId == userId)
            .OrderBy(f => f.Name)
            .ToListAsync();
        
        return Ok(folders);
    }

    [HttpPost]
    public async Task<ActionResult<UserFolder>> CreateFolder(string folderName)
    {
        var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "0");
        
        // Validate folder name
        if (string.IsNullOrWhiteSpace(folderName))
        {
            return BadRequest("Folder name cannot be empty");
        }

        // Check if folder already exists for this user
        var existingFolder = await _context.UserFolders
            .FirstOrDefaultAsync(f => f.UserId == userId && f.Name == folderName);
            
        if (existingFolder != null)
        {
            return BadRequest("A folder with this name already exists");
        }

        // Create physical folder
        var basePath = _configuration["Storage:BasePath"] ?? "Uploads";
        var userPath = Path.Combine(basePath, userId.ToString());
        var folderPath = Path.Combine(userPath, folderName);
        
        if (!Directory.Exists(userPath))
        {
            Directory.CreateDirectory(userPath);
        }
        
        if (!Directory.Exists(folderPath))
        {
            Directory.CreateDirectory(folderPath);
        }

        // Create folder in database
        var folder = new UserFolder
        {
            Name = folderName,
            Path = folderPath,
            UserId = userId,
            CreatedAt = DateTime.UtcNow
        };

        _context.UserFolders.Add(folder);
        await _context.SaveChangesAsync();

        return Ok(folder);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteFolder(int id)
    {
        var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "0");
        var folder = await _context.UserFolders
            .FirstOrDefaultAsync(f => f.Id == id && f.UserId == userId);

        if (folder == null)
        {
            return NotFound();
        }

        // Check if folder has files
        var hasFiles = await _context.Documents
            .AnyAsync(d => d.FolderId == id);
            
        if (hasFiles)
        {
            return BadRequest("Cannot delete folder that contains files");
        }

        // Delete physical folder if it exists
        if (Directory.Exists(folder.Path))
        {
            Directory.Delete(folder.Path, false);
        }

        _context.UserFolders.Remove(folder);
        await _context.SaveChangesAsync();

        return NoContent();
    }
} 