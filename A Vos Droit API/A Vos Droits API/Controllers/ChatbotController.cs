using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using System.Text.Json;
using AVosDroitsAPI.Data;
using AVosDroitsAPI.Models.DTOs;
using AVosDroitsAPI.Services;

namespace AVosDroitsAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class ChatbotController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        private readonly ILogger<ChatbotController> _logger;
        private readonly ILLMService _llmService;

        public ChatbotController(
            ApplicationDbContext context,
            ILogger<ChatbotController> logger,
            ILLMService llmService)
        {
            _context = context;
            _logger = logger;
            _llmService = llmService;
        }

        [HttpPost("chat")]
        public async Task<IActionResult> Chat([FromBody] ChatRequestDTO request)
        {
            try
            {
                if (request == null || string.IsNullOrEmpty(request.Message))
                {
                    _logger.LogWarning("Invalid chat request: Request or message is null");
                    return BadRequest(new { success = false, message = "Invalid request format" });
                }

                var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "0");
                if (userId == 0)
                {
                    _logger.LogWarning("Unauthorized chat request: User ID not found in claims");
                    return Unauthorized(new { success = false, message = "User not authenticated" });
                }

                // Get user's documents for context
                var documents = new List<object>();
                try
                {
                    var userDocs = await _context.Documents
                        .Where(d => d.UserId == userId)
                        .Select(d => new
                        {
                            d.FileName,
                            d.Description,
                            d.Category,
                            FolderName = d.Folder.Name
                        })
                        .ToListAsync();
                    documents.AddRange(userDocs);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error retrieving user documents for chat context");
                }

                // Create document context
                var documentContext = "Documents de l'utilisateur:\n";
                foreach (dynamic doc in documents)
                {
                    documentContext += $"- {doc.FileName}";
                    if (!string.IsNullOrEmpty(doc.Description))
                        documentContext += $" ({doc.Description})";
                    if (!string.IsNullOrEmpty(doc.Category))
                        documentContext += $" [Catégorie: {doc.Category}]";
                    if (!string.IsNullOrEmpty(doc.FolderName))
                        documentContext += $" [Dossier: {doc.FolderName}]";
                    documentContext += "\n";
                }

                // Process the chat message with document context
                var systemContext = @"Vous êtes un assistant juridique spécialisé dans le droit français.
                Format de réponse JSON attendu:
                {
                    ""message"": ""Message principal de réponse"",
                    ""options"": [
                        {
                            ""id"": ""1"",
                            ""text"": ""Option 1"",
                            ""icon"": ""emoji ou icône"",
                            ""description"": ""Description détaillée""
                        }
                    ],
                    ""context"": ""Contexte actuel de la conversation"",
                    ""expectingChoice"": true/false
                }

                Règles:
                1. Toujours structurer la réponse comme un dialogue avec des options
                2. Limiter les options à 6 choix maximum
                3. Utiliser des émojis pertinents pour les icônes
                4. Inclure une description courte pour chaque option
                5. Garder le contexte de la conversation
                6. Indiquer si une réponse est attendue (expectingChoice)

                Contexte des documents de l'utilisateur:
                " + documentContext;

                string llmResponse;
                try
                {
                    // Get response from LLM service
                    llmResponse = await _llmService.GetChatResponseAsync(
                        request.Message,
                        systemContext,
                        request.History ?? new List<ChatMessageDTO>()
                    );

                    if (string.IsNullOrEmpty(llmResponse))
                    {
                        _logger.LogError("LLM service returned empty response");
                        return StatusCode(500, new { success = false, message = "Empty response from language model" });
                    }

                    // Parse the JSON response
                    try
                    {
                        _logger.LogInformation($"Attempting to parse response: {llmResponse}");
                        var chatResponse = JsonSerializer.Deserialize<ChatResponseDTO>(llmResponse, new JsonSerializerOptions
                        {
                            PropertyNameCaseInsensitive = true
                        });

                        if (chatResponse == null)
                        {
                            _logger.LogError("Failed to deserialize LLM response to ChatResponseDTO");
                            return StatusCode(500, new { success = false, message = "Invalid response format from language model" });
                        }

                        // Ensure Options is not null
                        chatResponse.Options ??= new List<ChatOptionDTO>();

                        return Ok(new { success = true, response = chatResponse });
                    }
                    catch (JsonException ex)
                    {
                        _logger.LogError(ex, "Error parsing LLM response as JSON. Response: {Response}", llmResponse);
                        // Create a simple response for non-JSON responses
                        var simpleResponse = new ChatResponseDTO
                        {
                            Message = llmResponse,
                            ExpectingChoice = false,
                            Options = new List<ChatOptionDTO>()
                        };
                        return Ok(new { success = true, response = simpleResponse });
                    }
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error getting response from LLM service");
                    return StatusCode(500, new { success = false, message = "Error processing chat request with language model" });
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unhandled error in chat request");
                return StatusCode(500, new { success = false, message = "Une erreur inattendue s'est produite. Veuillez réessayer." });
            }
        }
    }
}