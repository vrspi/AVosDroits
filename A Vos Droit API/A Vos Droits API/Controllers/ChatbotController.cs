using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Net.Http.Headers;
using System.Text;

namespace AVosDroitsAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class ChatbotController : ControllerBase
    {
        private readonly IConfiguration _configuration;
        private readonly ILogger<ChatbotController> _logger;
        private readonly HttpClient _httpClient;
        private const string OpenAIEndpoint = "https://api.openai.com/v1/chat/completions";

        public ChatbotController(
            IConfiguration configuration,
            ILogger<ChatbotController> logger,
            IHttpClientFactory httpClientFactory)
        {
            _configuration = configuration;
            _logger = logger;
            _httpClient = httpClientFactory.CreateClient();
            
            var apiKey = _configuration["OpenAI:ApiKey"] ?? 
                throw new InvalidOperationException("OpenAI API key not configured");
            _httpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", apiKey);
        }

        [HttpPost("message")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        public async Task<IActionResult> SendMessage([FromBody] ChatMessageRequest request)
        {
            try
            {
                _logger.LogInformation("Received chat message request");

                if (request is null || string.IsNullOrEmpty(request.Message))
                {
                    _logger.LogWarning("Empty message received");
                    return BadRequest(new { error = "Le message ne peut pas être vide" });
                }

                // Prepare the system message for legal context
                var systemMessage = @"Tu es un assistant juridique pour l'application À Vos Droits.
                    Tu aides les utilisateurs à comprendre leurs droits et fournir des conseils sur les procédures juridiques en France.
                    Tu communiques en français et maintiens un ton professionnel et utile.
                    Tes réponses doivent être claires, concises et axées sur le droit français et les procédures juridiques.VOS REPONSES DOIVENT ETRE EN 2 LIGNES MAXIMUM";

                try
                {
                    _logger.LogInformation("Sending request to OpenAI");

                    var chatRequest = new
                    {
                        model = "gpt-4o",
                        messages = new[]
                        {
                            new { role = "system", content = systemMessage },
                            new { role = "user", content = request.Message }
                        },
                        temperature = 0.7
                    };

                    var jsonContent = JsonSerializer.Serialize(chatRequest);
                    _logger.LogInformation($"Request payload: {jsonContent}");

                    var content = new StringContent(jsonContent, Encoding.UTF8, "application/json");
                    var response = await _httpClient.PostAsync(OpenAIEndpoint, content);

                    var responseContent = await response.Content.ReadAsStringAsync();
                    _logger.LogInformation($"OpenAI API Response: {responseContent}");

                    response.EnsureSuccessStatusCode();

                    var completion = JsonSerializer.Deserialize<ChatCompletionResponse>(responseContent);

                    if (completion?.Choices?.Count > 0 && completion.Choices[0].Message?.Content is not null)
                    {
                        var aiResponse = completion.Choices[0].Message.Content;
                        _logger.LogInformation("Received response from OpenAI");
                        return Ok(new { response = aiResponse });
                    }
                    
                    _logger.LogWarning("No valid response content found in the AI response");
                    return StatusCode(500, new { error = "Aucune réponse valide n'a été reçue de l'IA" });
                }
                catch (HttpRequestException ex)
                {
                    _logger.LogError(ex, "HTTP error from OpenAI API");
                    var statusCode = ex.StatusCode.HasValue ? (int)ex.StatusCode.Value : 500;
                    return StatusCode(statusCode, new { error = $"Erreur de l'API OpenAI: {ex.Message}" });
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error from OpenAI API");
                    return StatusCode(500, new { error = $"Erreur de l'API OpenAI: {ex.Message}" });
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error processing chat message");
                return StatusCode(500, new { error = "Une erreur interne s'est produite" });
            }
        }
    }

    public class ChatMessageRequest
    {
        [JsonPropertyName("message")]
        public string? Message { get; set; }
    }

    public class ChatCompletionResponse
    {
        [JsonPropertyName("id")]
        public string? Id { get; set; }

        [JsonPropertyName("object")]
        public string? Object { get; set; }

        [JsonPropertyName("created")]
        public long Created { get; set; }

        [JsonPropertyName("model")]
        public string? Model { get; set; }

        [JsonPropertyName("choices")]
        public List<Choice>? Choices { get; set; }

        [JsonPropertyName("usage")]
        public Usage? Usage { get; set; }
    }

    public class Choice
    {
        [JsonPropertyName("index")]
        public int Index { get; set; }

        [JsonPropertyName("message")]
        public Message? Message { get; set; }

        [JsonPropertyName("finish_reason")]
        public string? FinishReason { get; set; }
    }

    public class Message
    {
        [JsonPropertyName("role")]
        public string? Role { get; set; }

        [JsonPropertyName("content")]
        public string? Content { get; set; }
    }

    public class Usage
    {
        [JsonPropertyName("prompt_tokens")]
        public int PromptTokens { get; set; }

        [JsonPropertyName("completion_tokens")]
        public int CompletionTokens { get; set; }

        [JsonPropertyName("total_tokens")]
        public int TotalTokens { get; set; }
    }
} 