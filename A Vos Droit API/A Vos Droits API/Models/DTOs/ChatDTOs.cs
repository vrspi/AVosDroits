namespace AVosDroitsAPI.Models.DTOs
{
    public class ChatRequestDTO
    {
        public string Message { get; set; } = string.Empty;
        public List<ChatMessageDTO>? History { get; set; }
    }

    public class ChatMessageDTO
    {
        public string Role { get; set; } = string.Empty;
        public string Content { get; set; } = string.Empty;
        public DateTime Timestamp { get; set; }
    }
} 