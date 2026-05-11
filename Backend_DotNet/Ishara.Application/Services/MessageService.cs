using Ishara.Application.DTOs;
using Ishara.Application.DTOs.Messages;
using Ishara.Application.Interfaces;
using Ishara.Domain.Models;
using Ishara.Domain.Repository_Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Ishara.Application.Services
{
    public class MessageService : IMessageService
    {
        private readonly IMessageRepository _repo;

        public MessageService(IMessageRepository repo)
        {
            _repo = repo;
        }
        public async Task<MessageResponseDto> SendMessageAsync(SendMessageRequestDto request, string senderId)
        {
            var message = new MessageChat
            {
                SenderId = senderId,
                ReceiverId = request.ReceiverId,
                Content = request.Content,
                SentAt = DateTime.UtcNow
            };
            await _repo.AddMessageAsync(message);
            await _repo.SaveChangesAsync();

            return new MessageResponseDto
            {
                Id = message.MessageChatId,
                SenderId = message.SenderId,
                Content = message.Content,
                SentAt = message.SentAt,
                IsRead = message.IsRead,
            };
        }
        public async Task<IEnumerable<MessageResponseDto>> GetChatHistoryAsync(string user1Id, string user2Id, int pageNumber, int pageSize)
        {
            var messages = await _repo.GetChatHistoryAsync(user1Id, user2Id, pageNumber, pageSize);
            return messages.OrderBy(m => m.SentAt).Select(m => new MessageResponseDto 
            {
                Id = m.MessageChatId,
                SenderId = m.SenderId,
                Content = m.Content,
                SentAt = m.SentAt,
                IsRead = m.IsRead,
            });
        }
        public async Task<IEnumerable<RecentChatDto>> GetRecentChatsAsync(string userId)
        {
            var res = await _repo.GetRecentChatsAsync(userId);

            return res.Select(r => new RecentChatDto
            {
                ContactId = r.ContactId,
                FullName = r.FullName,
                LastMessage = r.LastMessage,
                LastMessageTime = r.LastMessageTime,
                UnreadCount = r.UnreadCount
            });
        }
        public async Task MarkMessagesAsReadAsync(string currentUserId, string senderId)
        {
            await _repo.MarkMessagesAsReadAsync(currentUserId, senderId);
        }
    }
}
