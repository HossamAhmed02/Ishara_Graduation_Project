using Ishara.Application.Interfaces;
using Ishara.Application.Interfaces.MLModel;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System;
using System.IO;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;

namespace Ishara.Application.Controllers
{
    [Authorize]
    [Route("api/[controller]")]
    [ApiController]
    public class TranslationController : ControllerBase
    {
        private readonly ITranslationService _translationService;

        public TranslationController(ITranslationService translationService)
        {
            _translationService = translationService;
        }

        [HttpPost("process")]
        public async Task<IActionResult> ProcessVideo(IFormFile video)
        {
            if (video == null || video.Length == 0)
                return BadRequest(new { IsSuccess = false, Message = "Please provide a valid video file" });

            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);

            if (string.IsNullOrEmpty(userId))
                return Unauthorized(new { IsSuccess = false, Message = "Invalid or expired token" });

                var result = await _translationService.ProcessAndSaveTranslationAsync(video, userId);
                return Ok(new
                {
                    IsSuccess = true,
                    Message = "Translation successful",
                    Data = result
                });
        }
    }
}