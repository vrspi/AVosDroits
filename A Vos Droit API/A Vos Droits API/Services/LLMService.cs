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
                if (history != null)
                {
                    foreach (var msg in history)
                    {
                        if (!string.IsNullOrEmpty(msg.Role) && !string.IsNullOrEmpty(msg.Content))
                        {
                            messages.Add(new { role = msg.Role.ToLower(), content = msg.Content });
                        }
                    }
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

                _logger.LogInformation($"Sending request to OpenAI: {requestBody}");

                var response = await _httpClient.PostAsync(_apiUrl,
                    new StringContent(requestBody, Encoding.UTF8, "application/json"));

                var responseContent = await response.Content.ReadAsStringAsync();
                _logger.LogInformation($"OpenAI API response: {responseContent}");

                if (!response.IsSuccessStatusCode)
                {
                    _logger.LogError($"OpenAI API error: {response.StatusCode} - {responseContent}");
                    throw new Exception($"OpenAI API error: {response.StatusCode}");
                }

                var responseData = JsonSerializer.Deserialize<JsonElement>(responseContent);
                
                if (!responseData.TryGetProperty("choices", out var choices) || 
                    choices.GetArrayLength() == 0 ||
                    !choices[0].TryGetProperty("message", out var messageObj) ||
                    !messageObj.TryGetProperty("content", out var content))
                {
                    _logger.LogError($"Invalid response format from OpenAI API: {responseContent}");
                    throw new Exception("Invalid response format from OpenAI API");
                }

                var aiResponse = content.GetString();
                if (string.IsNullOrEmpty(aiResponse))
                {
                    throw new Exception("Empty response from OpenAI API");
                }

                _logger.LogInformation($"Processed AI response: {aiResponse}");

                // Try to parse the response as JSON first
                try
                {
                    var jsonResponse = JsonSerializer.Deserialize<JsonElement>(aiResponse);
                    return aiResponse;
                }
                catch (JsonException)
                {
                    // If not valid JSON, create a simple JSON response
                    return JsonSerializer.Serialize(new
                    {
                        message = aiResponse,
                        options = new List<object>(),
                        context = string.Empty,
                        expectingChoice = false
                    });
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting chat response from OpenAI");
                throw;
            }
        }
    }
} 