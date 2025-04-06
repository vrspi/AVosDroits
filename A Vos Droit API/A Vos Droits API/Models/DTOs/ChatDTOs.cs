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

    public class ChatResponseDTO
    {
        public string Message { get; set; } = string.Empty;
        public List<ChatOptionDTO>? Options { get; set; } = new();
        public string? Context { get; set; }
        public bool ExpectingChoice { get; set; }
    }

    public class ChatOptionDTO
    {
        public string Id { get; set; } = string.Empty;
        public string Text { get; set; } = string.Empty;
        public string? Icon { get; set; }
        public string? Description { get; set; }
    }
} 