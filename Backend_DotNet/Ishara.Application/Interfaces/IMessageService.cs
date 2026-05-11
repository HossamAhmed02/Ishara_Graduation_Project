using Ishara.Application.DTOs;
using Ishara.Application.DTOs.Messages;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Ishara.Application.Interfaces
{
    public interface IMessageService
    {
        public Task<MessageResponseDto> SendMessageAsync(SendMessageRequestDto request, string senderId);
        Task<IEnumerable<MessageResponseDto>> GetChatHistoryAsync(string user1Id, string user2Id, int pageNumber, int pageSize);
        Task<IEnumerable<RecentChatDto>> GetRecentChatsAsync(string userId);
        Task MarkMessagesAsReadAsync(string currentUserId, string senderId);
    }
}
