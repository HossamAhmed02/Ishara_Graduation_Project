using Ishara.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace Ishara.Api.Controllers
{
    [Authorize]
    [Route("api/[controller]")]
    [ApiController]
    public class ContactsController : ControllerBase
    {
        private readonly IContactService _contactService;
        public ContactsController(IContactService contactService)
        {
            _contactService = contactService;
        }
        [HttpGet("GetMyContacts")]
        public async Task<IActionResult> GetMyContacts()
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            var contacts = await _contactService.GetContactAsync(userId);
            return Ok(contacts);
        }

        [HttpGet("search")]
        public async Task<IActionResult> SearchUser([FromQuery] string user, [FromQuery] int pageNumber = 1, [FromQuery] int pageSize = 5)
        {
            if (string.IsNullOrWhiteSpace(user))
            {
                return BadRequest("Please Enter name or email");
            }
            var currentId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            var result = await _contactService.SearchUsersAsync(currentId ,user, pageNumber, pageSize);
            if (!result.Any())
            {
                return NotFound(new { message = "No Result" });
            }
            return Ok(result);
        }

        [HttpPost("AddContact")]
        public async Task<IActionResult> AddContact(string contactId)
        {
            var currentId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            await _contactService.AddContactAsync(currentId, contactId);
            return Ok(new { message = "User Added Successfully" });
        }
        [HttpDelete("DeleteContact")]
        public async Task<IActionResult> DeleteContacts(string contactId)
        {
            var currentId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            await _contactService.DeleteContactAsync(currentId, contactId);
            return Ok(new { Message = "Contact Removed Successfully" });
        }
    }
}
