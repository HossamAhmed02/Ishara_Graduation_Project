using Ishara.Application.DTOs;
using Ishara.Application.DTOs.Auth;
using Ishara.Application.DTOs.Profiles;
using Ishara.Application.Interfaces;
using Ishara.Domain.Exceptions;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Google;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace Ishara.Api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;
        public AuthController(IAuthService authService)
        {
            _authService = authService;
        }

        [HttpPost("Register")]
        public async Task<IActionResult> Register(RegisterDto dto)
        {
            var result = await _authService.RegisterAsync(dto);
            return Ok(result);
        }

        [HttpPost("Login")]
        public async Task<IActionResult> Login(LoginDto dto)
        {
            var result = await _authService.LoginAsync(dto);
            if (!result.IsAuthenticated) 
            {
                return Unauthorized(result.Message);
            }
            return Ok(result);
        }
        [HttpPost("logout")]
        [Authorize]
        public async Task<IActionResult> Logout()
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(userId))
                return Unauthorized("User is not authenticated.");
            var result = await _authService.LogoutAsync(userId);

            if (!result)
                throw new BadRequestCustomException("Logout failed.");
            return Ok(new { message = "Logged out successfully." });
        }

        [HttpPost("RefreshToken")]
        public async Task<IActionResult> RefreshToken(TokenRequestDto model)
        {
            var res = await _authService.RefreshTokenAsync(model.Token, model.RefreshToken);
            if (!res.IsAuthenticated) return BadRequest(res.Message);
            return Ok(res);
        }

        [HttpPost("ForgotPassword")]
        public async Task<IActionResult> ForgotPassword([FromBody] ForgotPasswordDto dto)
        {
            if (string.IsNullOrEmpty(dto.Email))
                return BadRequest("Email is required.");

            var result = await _authService.ForgotPasswordAsync(dto.Email);
            return Ok(result);
        }

        [HttpPost("VerifyResetPasswordOTP")]
        public async Task<IActionResult> VerifyResetPasswordOtp([FromBody] VerifyOtpDto dto)
        {
            var result = await _authService.VerifyResetPasswordOtpAsync(dto);
            return Ok(result);
        }

        [HttpPost("ResetPassword")]
        public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordDto dto)
        {
            var result = await _authService.ResetPasswordAsync(dto);
            if (!result.IsAuthenticated)
                return BadRequest(result.Message);
            return Ok(result);
        }

        //Otp
        [HttpPost("VerifyRegisterOtp")]
        public async Task<IActionResult> VerifyRegisterOtp([FromBody] VerifyOtpDto dto)
        {
            var result = await _authService.VerifyOtpAsync(dto.Email, dto.Otp);
            if (!result.IsAuthenticated) return BadRequest(result.Message);
            return Ok(result);
        }

        //Google auth
        [HttpGet("Login-Google")]
        public IActionResult LoginWithGoogle()
        {
            var properties = new AuthenticationProperties { RedirectUri = Url.Action("GoogleResponse") };
            return Challenge(properties, GoogleDefaults.AuthenticationScheme);
        }

        [HttpGet("Google-Response")]
        public async Task<IActionResult> GoogleResponse()
        {
            var result = await HttpContext.AuthenticateAsync("ExternalCookies");

            if (!result.Succeeded)
            {
                return BadRequest("Google authentication failed");
            }
            var claims = result.Principal.Identities.FirstOrDefault()?.Claims;
            var email = claims?.FirstOrDefault(x => x.Type == ClaimTypes.Email)?.Value;
            var firstName = claims?.FirstOrDefault(x => x.Type == ClaimTypes.GivenName)?.Value;
            var lastName = claims?.FirstOrDefault(x => x.Type == ClaimTypes.Surname)?.Value;

            if (string.IsNullOrEmpty(email))
                return BadRequest("Could not retrieve email from Google.");

            var authResult = await _authService.GoogleLoginAsync(email, firstName, lastName);

            await HttpContext.SignOutAsync("ExternalCookies");

            if (!authResult.IsAuthenticated)
                return BadRequest(authResult.Message);

            return Ok(authResult);
        }

        //Edit Profile
        [Authorize]
        [HttpGet("Profile")]
        public async Task<IActionResult> GetProfile()
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            var result = await _authService.GetProfileAsync(userId);
            return Ok(result);
        }

        [Authorize]
        [HttpPut("UpdateProfile")]
        public async Task<IActionResult> UpdateProfile([FromBody] UpdateProfileDto dto)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            var message = await _authService.UpdateProfileAsync(userId, dto);
            return Ok(new { Message = message });
        }

    }
}
