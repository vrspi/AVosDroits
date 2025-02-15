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
                    model = "gpt-4o",
                    messages = messages,
                    temperature = 0.7,
                    max_tokens = 1000
                });

                var response = await _httpClient.PostAsync(_apiUrl,
                    new StringContent(requestBody, Encoding.UTF8, "application/json"));

                if (!response.IsSuccessStatusCode)
                {
                    _logger.LogError($"LLM API error: {response.StatusCode} - {await response.Content.ReadAsStringAsync()}");
                    throw new Exception("Failed to get response from LLM service");
                }

                var responseContent = await response.Content.ReadAsStringAsync();
                var responseData = JsonSerializer.Deserialize<JsonElement>(responseContent);
                
                return responseData.GetProperty("choices")[0]
                    .GetProperty("message")
                    .GetProperty("content")
                    .GetString() ?? "Désolé, je n'ai pas pu générer une réponse.";
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting chat response from LLM");
                throw;
            }
        }
    }
} 