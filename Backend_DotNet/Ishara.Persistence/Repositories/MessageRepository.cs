using Ishara.Domain.Models;
using Ishara.Domain.ReadModels;
using Ishara.Domain.Repository_Interfaces;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Ishara.Persistence.Repositories
{
    public class MessageRepository : IMessageRepository
    {
        private readonly IsharaDbContext _context;

        public MessageRepository(IsharaDbContext context)
        {
            _context = context;
        }
        public async Task AddMessageAsync(MessageChat message)
        {
            await _context.Messages.AddAsync(message);
        }

        public async Task<IEnumerable<MessageChat>> GetChatHistoryAsync(string user1Id, string user2Id, int pageNumber, int pageSize)
        {
            return await _context.Messages
            .Where(m => (m.SenderId == user1Id && m.ReceiverId == user2Id) ||
                        (m.SenderId == user2Id && m.ReceiverId == user1Id))
            .OrderByDescending(m => m.SentAt)
            .Skip((pageNumber - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync();
        }
        public async Task<IEnumerable<RecentChatResult>> GetRecentChatsAsync(string userId)
        {
            var recentChats = await _context.Messages
                .Where(m => m.SenderId == userId || m.ReceiverId == userId)
                .GroupBy(m => m.SenderId == userId ? m.ReceiverId : m.SenderId)
                .Select(g => new RecentChatResult
                {
                    ContactId = g.Key,
                    LastMessage = g.OrderByDescending(m => m.SentAt).Select(m => m.Content).FirstOrDefault(),
                    LastMessageTime = g.OrderByDescending(m => m.SentAt).Select(m => m.SentAt).FirstOrDefault(),
                    UnreadCount = g.Count(m => m.ReceiverId == userId && !m.IsRead)
                })
                .OrderByDescending(c => c.LastMessageTime)
                .ToListAsync();
            foreach (var chat in recentChats)
            {
                var user = await _context.Users.FindAsync(chat.ContactId);
                if (user != null)
                {
                    chat.FullName = user.FirstName + " " + user.LastName;
                }
            }
            return recentChats;
        }
        public async Task MarkMessagesAsReadAsync(string currentUserId, string senderId)
        {
            var unreadMessages = await _context.Messages
                .Where(m => m.ReceiverId == currentUserId && m.SenderId == senderId && !m.IsRead)
                .ToListAsync();

            if (unreadMessages.Any())
            {
                foreach (var msg in unreadMessages)
                {
                    msg.IsRead = true;
                }
                await SaveChangesAsync();
            }
        }

        public async Task SaveChangesAsync()
        {
            await _context.SaveChangesAsync();
        }
    }
}
