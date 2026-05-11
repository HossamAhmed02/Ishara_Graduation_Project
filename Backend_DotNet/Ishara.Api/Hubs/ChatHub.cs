using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;

namespace Ishara.Api.Hubs
{
    [Authorize]
    public class ChatHub : Hub
    {
        public static readonly Dictionary<string, string> OnlineUsers = new();
        public override async Task OnConnectedAsync()
        {
            var userId = Context.UserIdentifier;

            if (userId != null)
            {
                lock (OnlineUsers)
                {
                    OnlineUsers[userId] = Context.ConnectionId;
                }
                await Clients.All.SendAsync("UserOnline", userId);
            }

            await base.OnConnectedAsync();
        }
        public override async Task OnDisconnectedAsync(Exception? exception)
        {
            var userId = Context.UserIdentifier;

            if (userId != null)
            {
                lock (OnlineUsers)
                {
                    OnlineUsers.Remove(userId);
                }

                await Clients.All.SendAsync("UserOffline", userId);
            }

            await base.OnDisconnectedAsync(exception);
        }
        public async Task UserIsTyping(string receiverId)
        {
            var senderId = Context.UserIdentifier;

            if (senderId != null)
            {
                await Clients.User(receiverId).SendAsync("ReceiveTypingStatus", senderId);
            }
        }
    }
}
