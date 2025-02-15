using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
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
                var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "0");
                if (userId == 0)
                    return Unauthorized();

                // Get user's documents for context
                var documents = await _context.Documents
                    .Where(d => d.UserId == userId)
                    .Select(d => new
                    {
                        d.FileName,
                        d.Description,
                        d.Category,
                        FolderName = d.Folder.Name
                    })
                    .ToListAsync();

                // Create document context
                var documentContext = "Documents de l'utilisateur:\n";
                foreach (var doc in documents)
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
                var systemContext = @"Vous êtes un assistant juridique ultra-concis spécialisé dans le droit français. 
                Format de réponse:
                1. Une phrase de réponse directe (maximum 15 mots)
                2. Si nécessaire, une phrase d'action concrète à entreprendre
                3. Si besoin, proposer une question de suivi

                Règles strictes:
                - Jamais plus de 3 phrases au total
                - Pas d'introduction ni de formules de politesse
                - Uniquement des informations essentielles et actionnables
                - Utiliser des verbes d'action
                - Pour les procédures: donner uniquement la première action à faire
                - Pour les documents: répondre uniquement avec les informations visibles dans le contexte

                Questions de suivi suggérées:
                - Pour plus de détails sur une procédure: 'Quelle est l'étape suivante?'
                - Pour approfondir un sujet: 'Voulez-vous plus d'informations sur [aspect spécifique]?'

                Contexte des documents de l'utilisateur:
                " + documentContext;

                // Get response from LLM service
                var response = await _llmService.GetChatResponseAsync(
                    request.Message,
                    systemContext,
                    request.History ?? new List<ChatMessageDTO>()
                );

                return Ok(new
                {
                    success = true,
                    response = response,
                    systemContext = systemContext
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error processing chat request");
                return StatusCode(500, new { success = false, message = "Internal server error" });
            }
        }
    }
}