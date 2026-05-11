using Ishara.Domain.Models;
using Ishara.Domain.ReadModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Ishara.Domain.Repository_Interfaces
{
    public interface IMessageRepository
    {
        Task AddMessageAsync(MessageChat message);
        Task<IEnumerable<MessageChat>> GetChatHistoryAsync(string user1Id, string user2Id, int pageNumber, int pageSize);
        Task<IEnumerable<RecentChatResult>> GetRecentChatsAsync(string userId);
        Task MarkMessagesAsReadAsync(string currentUserId, string senderId);
        //Task GetChatHistoryAsync(string user1Id, string user2Id);
        public Task SaveChangesAsync();
    }
}
