using Ishara.Application.DTOs;
using Ishara.Application.DTOs.Auth;
using Ishara.Application.DTOs.Profiles;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Ishara.Application.Interfaces
{
    public interface IAuthService
    {
        Task<AuthDto> RegisterAsync(RegisterDto dto);
        Task<AuthDto> LoginAsync(LoginDto dto);
        Task<bool> LogoutAsync(string userId);
        Task<AuthDto> GoogleLoginAsync(string email, string firstName, string lastName);

        Task<AuthDto> VerifyOtpAsync(string email, string otp);

        Task<AuthDto> ForgotPasswordAsync(string email);
        Task<AuthDto> VerifyResetPasswordOtpAsync(VerifyOtpDto dto);
        Task<AuthDto> ResetPasswordAsync(ResetPasswordDto dto);
        Task<AuthDto> RefreshTokenAsync(string token, string refreshToken);
        
        //Profile
        Task<UserProfileDto> GetProfileAsync(string userId);
        Task<string> UpdateProfileAsync(string userId, UpdateProfileDto dto);
    }
}
