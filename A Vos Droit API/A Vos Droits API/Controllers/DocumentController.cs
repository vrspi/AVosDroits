using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using AVosDroitsAPI.Models.DTOs;
using AVosDroitsAPI.Models.Entities;
using AVosDroitsAPI.Data;
using System.Security.Claims;

namespace AVosDroitsAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class DocumentController : ControllerBase
    {
        private readonly IConfiguration _configuration;
        private readonly ILogger<DocumentController> _logger;
        private readonly ApplicationDbContext _context;
        private readonly string _uploadDirectory;

        public DocumentController(
            IConfiguration configuration,
            ILogger<DocumentController> logger,
            ApplicationDbContext context)
        {
            _configuration = configuration;
            _logger = logger;
            _context = context;
            _uploadDirectory = _configuration["DocumentStorage:Path"] ?? "Uploads/Documents";
            
            // Ensure upload directory exists
            if (!Directory.Exists(_uploadDirectory))
            {
                Directory.CreateDirectory(_uploadDirectory);
            }
        }

        [HttpPost("upload")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<ActionResult<DocumentResponse>> UploadDocument([FromForm] IFormFile file, [FromForm] DocumentUploadRequest request)
        {
            try
            {
                if (file == null || file.Length == 0)
                    return BadRequest(new DocumentResponse { Success = false, Message = "No file uploaded" });

                var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "0");
                if (userId == 0)
                    return Unauthorized(new DocumentResponse { Success = false, Message = "User not authenticated" });

                // Validate folder if provided
                UserFolder? folder = null;
                if (request.FolderId.HasValue)
                {
                    folder = await _context.UserFolders
                        .FirstOrDefaultAsync(f => f.Id == request.FolderId && f.UserId == userId);
                        
                    if (folder == null)
                        return BadRequest(new DocumentResponse { Success = false, Message = "Invalid folder selected" });
                }

                // Determine save path
                string filePath;
                if (folder != null)
                {
                    filePath = Path.Combine(folder.Path, $"{Guid.NewGuid()}_{Path.GetFileName(file.FileName)}");
                }
                else
                {
                    var userDirectory = Path.Combine(_uploadDirectory, userId.ToString());
                    if (!Directory.Exists(userDirectory))
                        Directory.CreateDirectory(userDirectory);
                    filePath = Path.Combine(userDirectory, $"{Guid.NewGuid()}_{Path.GetFileName(file.FileName)}");
                }

                // Save file
                using (var stream = new FileStream(filePath, FileMode.Create))
                {
                    await file.CopyToAsync(stream);
                }

                var document = new Document
                {
                    Id = Guid.NewGuid(),
                    FileName = file.FileName,
                    ContentType = file.ContentType,
                    FilePath = filePath,
                    FileSize = file.Length,
                    UploadDate = DateTime.UtcNow,
                    UserId = userId,
                    FolderId = folder?.Id,
                    Description = request.Description,
                    Category = request.Category
                };

                _context.Documents.Add(document);
                await _context.SaveChangesAsync();

                var documentDto = new DocumentDTO
                {
                    Id = document.Id,
                    FileName = document.FileName,
                    ContentType = document.ContentType,
                    FileSize = document.FileSize,
                    UploadDate = document.UploadDate,
                    Description = document.Description,
                    Category = document.Category,
                    FolderId = document.FolderId,
                    FolderName = folder?.Name
                };

                return Ok(new DocumentResponse 
                { 
                    Success = true, 
                    Message = "File uploaded successfully",
                    Document = documentDto
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error uploading document");
                return StatusCode(500, new DocumentResponse 
                { 
                    Success = false, 
                    Message = "Internal server error occurred while uploading the document" 
                });
            }
        }

        [HttpGet("{id}")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<IActionResult> DownloadDocument(Guid id)
        {
            try
            {
                var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "0");
                if (userId == 0)
                    return Unauthorized();

                var document = await _context.Documents
                    .FirstOrDefaultAsync(d => d.Id == id && d.UserId == userId);

                if (document == null)
                    return NotFound();

                if (!System.IO.File.Exists(document.FilePath))
                    return NotFound("File not found on server");

                var memory = new MemoryStream();
                using (var stream = new FileStream(document.FilePath, FileMode.Open))
                {
                    await stream.CopyToAsync(memory);
                }
                memory.Position = 0;

                return File(memory, document.ContentType, document.FileName);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error downloading document");
                return StatusCode(500);
            }
        }

        [HttpGet("list")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<ActionResult<IEnumerable<DocumentDTO>>> GetUserDocuments([FromQuery] int? folderId = null)
        {
            try
            {
                var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "0");
                if (userId == 0)
                    return Unauthorized();

                var query = _context.Documents
                    .Include(d => d.Folder)
                    .Where(d => d.UserId == userId);

                if (folderId.HasValue)
                {
                    query = query.Where(d => d.FolderId == folderId);
                }

                var documents = await query
                    .OrderByDescending(d => d.UploadDate)
                    .Select(d => new DocumentDTO
                    {
                        Id = d.Id,
                        FileName = d.FileName,
                        ContentType = d.ContentType,
                        FileSize = d.FileSize,
                        UploadDate = d.UploadDate,
                        Description = d.Description,
                        Category = d.Category,
                        FolderId = d.FolderId,
                        FolderName = d.Folder != null ? d.Folder.Name : null
                    })
                    .ToListAsync();

                return Ok(documents);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving user documents");
                return StatusCode(500);
            }
        }

        [HttpDelete("{id}")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<IActionResult> DeleteDocument(Guid id)
        {
            try
            {
                var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "0");
                if (userId == 0)
                    return Unauthorized();

                var document = await _context.Documents
                    .FirstOrDefaultAsync(d => d.Id == id && d.UserId == userId);

                if (document == null)
                    return NotFound();

                // Delete physical file
                if (System.IO.File.Exists(document.FilePath))
                {
                    System.IO.File.Delete(document.FilePath);
                }

                _context.Documents.Remove(document);
                await _context.SaveChangesAsync();

                return Ok(new { success = true, message = "Document deleted successfully" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deleting document");
                return StatusCode(500);
            }
        }
    }
} 