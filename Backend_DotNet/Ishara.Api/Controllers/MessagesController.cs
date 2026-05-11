using Ishara.Api.Hubs;
using Ishara.Application.DTOs;
using Ishara.Application.DTOs.Messages;
using Ishara.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;
using System.Security.Claims;

namespace Ishara.Api.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class MessagesController : ControllerBase
    {
        private readonly IMessageService _messageService;
        private readonly IHubContext<ChatHub> _hub;
        public MessagesController(IMessageService messageService, IHubContext<ChatHub> hub)
        {
            _messageService = messageService;
            _hub = hub;
        }

        [HttpPost("send")]
        public async Task<IActionResult> SendMessage([FromBody] SendMessageRequestDto request)
        {
            var senderId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(request.Content)) return BadRequest("Message is empty");

            var result = await _messageService.SendMessageAsync(request, senderId);

            await _hub.Clients.User(request.ReceiverId)
                .SendAsync("ReceiveMessage", result);

            var usersToUpdate = new List<string> { senderId, request.ReceiverId };
            await _hub.Clients.Users(usersToUpdate).SendAsync("UpdateRecentChats");

            return Ok(result);
        }

        [HttpGet("chat/{receiverId}")]
        public async Task<IActionResult> GetChatHistory(string receiverId, [FromQuery] int pageNumber = 1, [FromQuery] int pageSize = 20)
        {
            var currentUserId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            var history = await _messageService.GetChatHistoryAsync(currentUserId, receiverId, pageNumber, pageSize);
            return Ok(history);
        }

        [HttpGet("RecentChats")]
        public async Task<IActionResult> GetRecentChats()
        {
            var currentUserId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            var recentChats = await _messageService.GetRecentChatsAsync(currentUserId);
            return Ok(recentChats);
        }

        [HttpPost("MarkMessageAsRead/{senderId}")]
        public async Task<IActionResult> MarkAsRead(string senderId)
        {
            var currentUserId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            await _messageService.MarkMessagesAsReadAsync(currentUserId, senderId);

            await _hub.Clients.User(senderId).SendAsync("MessagesSeen", currentUserId);

            return Ok(new { Message = "Messages marked as read." });
        }

        [HttpGet("OnlineUsers")]
        public IActionResult GetOnlineUsers()
        {
            var onlineUserIds = ChatHub.OnlineUsers.Keys.ToList();
            return Ok(onlineUserIds);
        }
    }
}
