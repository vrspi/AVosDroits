using System.Text;
using System.Text.Json;
using System.Net.Http;
using Microsoft.Extensions.Configuration;
using AVosDroitsAPI.Models.DTOs;

namespace AVosDroitsAPI.Services
{
    public interface ILLMService
    {
        Task<string> GetChatResponseAsync(string message, string systemContext, List<ChatMessageDTO> history);
    }

    public class LLMService : ILLMService
    {
        private readonly HttpClient _httpClient;
        private readonly string _apiKey;
        private readonly string _apiUrl = "https://api.openai.com/v1/chat/completions";
        private readonly ILogger<LLMService> _logger;

        public LLMService(IConfiguration configuration, ILogger<LLMService> logger)
        {
            _httpClient = new HttpClient();
            _apiKey = configuration["OpenAI:ApiKey"] ?? throw new ArgumentNullException("OpenAI:ApiKey configuration is missing");
            _logger = logger;
            
            _httpClient.DefaultRequestHeaders.Add("Authorization", $"Bearer {_apiKey}");
        }

        public async Task<string> GetChatResponseAsync(string message, string systemContext, List<ChatMessageDTO> history)
        {
            try
            {
                var messages = new List<object>
                {
                    new { role = "system", content = systemContext }
                };

                // Add chat history
                foreach (var msg in history)
                {
                    messages.Add(new { role = msg.Role.ToLower(), content = msg.Content });
                }

                // Add current message
                messages.Add(new { role = "user", content = message });

                var requestBody = JsonSerializer.Serialize(new
                {
                    model = "gpt-4",
                    messages = messages,
                    temperature = 0.7,
                    max_tokens = 1000
                });

                var response = await _httpClient.PostAsync(_apiUrl,
                    new StringContent(requestBody, Encoding.UTF8, "application/json"));

                if (!response.IsSuccessStatusCode)
                {
                    var errorContent = await response.Content.ReadAsStringAsync();
                    _logger.LogError($"LLM API error: {response.StatusCode} - {errorContent}");
                    throw new Exception($"OpenAI API error: {response.StatusCode} - {errorContent}");
                }

                var responseContent = await response.Content.ReadAsStringAsync();
                _logger.LogInformation($"LLM API response: {responseContent}");
                
                var responseData = JsonSerializer.Deserialize<JsonElement>(responseContent);
                
                if (!responseData.TryGetProperty("choices", out var choices) || 
                    choices.GetArrayLength() == 0 ||
                    !choices[0].TryGetProperty("message", out var messageObj) ||
                    !messageObj.TryGetProperty("content", out var content))
                {
                    _logger.LogError($"Invalid response format from LLM API: {responseContent}");
                    throw new Exception("Invalid response format from LLM service");
                }

                return content.GetString() ?? "Désolé, je n'ai pas pu générer une réponse.";
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting chat response from LLM");
                throw;
            }
        }
    }
} 