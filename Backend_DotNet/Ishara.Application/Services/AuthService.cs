using Ishara.Application.DTOs;
using Ishara.Application.DTOs.Auth;
using Ishara.Application.DTOs.Profiles;
using Ishara.Application.Interfaces;
using Ishara.Domain.Enums;
using Ishara.Domain.Exceptions;
using Ishara.Domain.Models;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;
using System;
using System.Collections;
using System.Collections.Generic;
using System.IdentityModel.Tokens.Jwt;
using System.Linq;
using System.Reflection;
using System.Security.Claims;
using System.Text;
using System.Threading.Tasks;


namespace Ishara.Application.Services
{
    public class AuthService : IAuthService
    {
        private readonly UserManager<User> _userManager;
        private readonly IConfiguration _config;
        private readonly IEmailService _emailService;
        private readonly ITokenService _tokenService;
        private readonly IMemoryCache _cache;
        public AuthService(UserManager<User> userManager, IConfiguration config, IEmailService emailService, ITokenService tokenService, IMemoryCache cache)
        {
            _userManager = userManager;
            _config = config;
            _emailService = emailService;
            _tokenService = tokenService;
            _cache = cache;
        }
        public async Task<AuthDto> RegisterAsync(RegisterDto dto)
        {
            var exist = await _userManager.FindByEmailAsync(dto.Email);
            if (exist != null)
            {
                if (exist.EmailConfirmed)
                {
                    throw new BadRequestCustomException("Email already exists and is active.");
                }

                string newOtp = new Random().Next(100000, 999999).ToString();
                exist.Otp = newOtp;
                exist.OtpExpiry = DateTime.UtcNow.AddMinutes(10);

                var token = await _userManager.GeneratePasswordResetTokenAsync(exist);
                await _userManager.ResetPasswordAsync(exist, token, dto.Password);

                await _userManager.UpdateAsync(exist);

                string newUseremailBody = $"<h3>Welcome</h3><p>Code Verification: <strong>{newOtp}</strong></p>";
                await _emailService.SendEmailAsync(exist.Email, "Verification Code of Ishara Account", newUseremailBody);

                return new AuthDto { IsAuthenticated = false, Message = "Verification code send again" }; //Middleware here
            }
            var otp = new Random().Next(100000, 999999).ToString();

            var user = new User
            {
                FirstName = dto.FirstName,
                LastName = dto.LastName,
                Email = dto.Email,
                UserName = dto.Email,
                Role = Domain.Enums.UserRole.User,
                Otp = otp,
                OtpExpiry = DateTime.UtcNow.AddMinutes(10)
            };
            var result = await _userManager.CreateAsync(user, dto.Password);

            if (!result.Succeeded)
            {
                throw new BadRequestCustomException(string.Join(", ", result.Errors.Select(e => e.Description)));
            }
            await _userManager.AddToRoleAsync(user, user.Role.ToString());

            string emailBody = $"<h3>Welcome</h3><p>Code Verification: <strong>{otp}</strong></p>";
            await _emailService.SendEmailAsync(user.Email, "Verification Code of Ishara Account", emailBody);

            return new AuthDto { IsAuthenticated = false, Message = "Registered successfully" }; //Middleware here>>>
        }

        public async Task<AuthDto> LoginAsync(LoginDto dto)
        {
            var user = await _userManager.FindByEmailAsync(dto.Email);

            if (user == null || !await _userManager.CheckPasswordAsync(user, dto.Password))
            {
                throw new BadRequestCustomException("Invalid Email or Password!");
            }
            if (!user.EmailConfirmed)
            {
                throw new BadRequestCustomException("Your Account not verified");
            }

            var roles = await _userManager.GetRolesAsync(user);

            var AccessToken = _tokenService.GenerateAccessToken(user, roles);
            var refreshToken = _tokenService.GenerateRefreshToken();

            user.RefreshToken = refreshToken;
            user.RefreshTokenExpiryTime = DateTime.UtcNow.AddDays(30);

            await _userManager.UpdateAsync(user);

            return new AuthDto
            {
                IsAuthenticated = true,
                Token = AccessToken,
                RefreshToken = refreshToken,
                RefreshTokenExpiration = user.RefreshTokenExpiryTime.Value,
                Email = user.Email,
            };
        }

        public async Task<AuthDto> GoogleLoginAsync(string email, string firstName, string lastName)
        {
            var user = await _userManager.FindByEmailAsync(email);

            if (user == null)
            {
                user = new User
                {
                    FirstName = firstName ?? "Google User",
                    LastName = lastName ?? "",
                    Email = email,
                    UserName = email,
                    Role = Domain.Enums.UserRole.User,
                    EmailConfirmed = true
                };

                var randomPassword = Guid.NewGuid().ToString() + "aA1@";
                var result = await _userManager.CreateAsync(user, randomPassword);

                if (!result.Succeeded)
                    throw new BadRequestCustomException("Failed to create user from Google account");
                await _userManager.AddToRoleAsync(user, user.Role.ToString());
            }

            var roles = await _userManager.GetRolesAsync(user);
            var accessToken = _tokenService.GenerateAccessToken(user, roles);
            var refreshToken = _tokenService.GenerateRefreshToken();

            user.RefreshToken = refreshToken;
            user.RefreshTokenExpiryTime = DateTime.UtcNow.AddDays(30);
            await _userManager.UpdateAsync(user);

            return new AuthDto
            {
                IsAuthenticated = true,
                Token = accessToken,
                RefreshToken = refreshToken,
                RefreshTokenExpiration = user.RefreshTokenExpiryTime.Value,
                Email = user.Email,
                Message = "Logged in successfully via Google"
            };
        }

        public async Task<AuthDto> RefreshTokenAsync(string token, string refreshToken)
        {
            var principal = _tokenService.GetPrincipalFromExpiredToken(token);
            var userEmail = principal.Claims.FirstOrDefault(c => c.Type == ClaimTypes.Email)?.Value;

            var user = await _userManager.FindByEmailAsync(userEmail);

            if (user == null || user.RefreshToken != refreshToken || user.RefreshTokenExpiryTime <= DateTime.UtcNow)
            {
                throw new BadRequestCustomException("Invalid or expired refresh token");
            }

            var roles = await _userManager.GetRolesAsync(user);

            var newAccessToken = _tokenService.GenerateAccessToken(user, roles);
            var newRefreshToken = _tokenService.GenerateRefreshToken();

            user.RefreshToken = newRefreshToken;
            await _userManager.UpdateAsync(user);

            return new AuthDto
            {
                IsAuthenticated = true,
                Token = newAccessToken,
                RefreshToken = newRefreshToken,
                RefreshTokenExpiration = user.RefreshTokenExpiryTime.Value,
                Email = user.Email
            };
        }

        public async Task<AuthDto> VerifyOtpAsync(string email, string otp)
        {
            var user = await _userManager.FindByEmailAsync(email);

            if (user == null)
                throw new NotFoundCustomException("User not found");

            if (user.Otp != otp || user.OtpExpiry < DateTime.UtcNow)
                throw new BadRequestCustomException("Not correct");

            user.EmailConfirmed = true;
            user.Otp = null;
            user.OtpExpiry = null;

            var roles = await _userManager.GetRolesAsync(user);
            var token = _tokenService.GenerateAccessToken(user, roles);
            var refreshToken = _tokenService.GenerateRefreshToken();

            user.RefreshToken = refreshToken;
            user.RefreshTokenExpiryTime = DateTime.UtcNow.AddDays(30);

            await _userManager.UpdateAsync(user);

            return new AuthDto
            {
                IsAuthenticated = true,
                Token = token,
                RefreshToken = refreshToken,
                RefreshTokenExpiration = user.RefreshTokenExpiryTime.Value,
                Email = user.Email,
                Message = "Account verified successfully"
            };
        }

        public async Task<AuthDto> ForgotPasswordAsync(string email)
        {
            var user = await _userManager.FindByEmailAsync(email);

            if (user == null)
            {
                throw new NotFoundCustomException("Your email doesn't Registered");
            }

            string otpCode = new Random().Next(100000, 999999).ToString();
            user.Otp = otpCode;
            user.OtpExpiry = DateTime.UtcNow.AddMinutes(10);

            await _userManager.UpdateAsync(user);

            string emailBody = $@"<h3>Change your password</h3>
            <p>Your code verification:</p>
            <h2 style='color: red; letter-spacing: 5px;'>{otpCode}</h2>
            <p>Expiry date of code is 10 minutes</p>
            </div>";

            await _emailService.SendEmailAsync(user.Email, "Reset Password", emailBody);

            return new AuthDto { IsAuthenticated = false, Message = "If your email exists, an OTP has been sent to it." };
        }

        public async Task<AuthDto> VerifyResetPasswordOtpAsync(VerifyOtpDto dto)
        {
            var user = await _userManager.FindByEmailAsync(dto.Email);

            if (user == null)
            {
                throw new NotFoundCustomException("User not found");
            }

            if (user.Otp != dto.Otp || user.OtpExpiry < DateTime.UtcNow)
            {
                throw new BadRequestCustomException("Invalid or expired OTP");
            }
            var resetToken = await _userManager.GeneratePasswordResetTokenAsync(user);
            return new AuthDto
            {
                RefreshToken = resetToken,
                Message = "OTP is valid",
            };
        }
        public async Task<AuthDto> ResetPasswordAsync(ResetPasswordDto dto)
        {
            var user = await _userManager.FindByEmailAsync(dto.Email);

            if (user == null)
            {
                throw new NotFoundCustomException("User not found");
            }
            var result = await _userManager.ResetPasswordAsync(user, dto.Token, dto.NewPassword);

            if (!result.Succeeded)
            {
                throw new BadRequestCustomException(string.Join(", ", result.Errors.Select(e => e.Description)));
            }
            user.Otp = null;
            user.OtpExpiry = null;
            user.EmailConfirmed = true;

            var roles = await _userManager.GetRolesAsync(user);
            var token = _tokenService.GenerateAccessToken(user, roles);
            var refreshToken = _tokenService.GenerateRefreshToken();

            user.RefreshToken = refreshToken;
            user.RefreshTokenExpiryTime = DateTime.UtcNow.AddDays(30);

            await _userManager.UpdateAsync(user);
            return new AuthDto
            {
                IsAuthenticated = true,
                Token = token,
                RefreshToken = refreshToken,
                RefreshTokenExpiration = user.RefreshTokenExpiryTime.Value,
                Email = user.Email,
                Message = "Password has been reset successfully"
            };
        }
        public async Task<bool> LogoutAsync(string userId)
        {
            var user = await _userManager.FindByIdAsync(userId);
            if (user == null)
                throw new NotFoundCustomException("User not found.");

            user.RefreshToken = null;
            user.RefreshTokenExpiryTime = null;

            var result = await _userManager.UpdateAsync(user);
            return result.Succeeded;
        }

        public async Task<UserProfileDto> GetProfileAsync(string userId)
        {
            string cacheKey = $"Profile_{userId}";

            if (!_cache.TryGetValue(cacheKey, out UserProfileDto profile))
            {
                var user = await _userManager.FindByIdAsync(userId);
                if (user == null) throw new NotFoundCustomException("User not found");

                profile = new UserProfileDto
                {
                    FirstName = user.FirstName,
                    LastName = user.LastName,
                    Email = user.Email
                };
                var cacheOptions = new MemoryCacheEntryOptions().SetAbsoluteExpiration(TimeSpan.FromDays(1));
                _cache.Set(cacheKey, profile, cacheOptions);
            }
            return profile;
        }

        public async Task<string> UpdateProfileAsync(string userId, UpdateProfileDto dto)
        {
            var user = await _userManager.FindByIdAsync(userId);
            if (user == null) throw new NotFoundCustomException("User not found");

            if (!string.IsNullOrEmpty(dto.NewPassword))
            {
                var resetToken = await _userManager.GeneratePasswordResetTokenAsync(user);
                var passwordResult = await _userManager.ResetPasswordAsync(user, resetToken, dto.NewPassword);

                if (!passwordResult.Succeeded)
                    throw new BadRequestCustomException(string.Join(", ", passwordResult.Errors.Select(e => e.Description)));
            }
            user.FirstName = dto.FirstName;
            user.LastName = dto.LastName;

            var updateResult = await _userManager.UpdateAsync(user);
            if (!updateResult.Succeeded)
            {
                throw new BadRequestCustomException(string.Join(", ", updateResult.Errors.Select(e => e.Description)));
            }
            else
            {
                _cache.Remove($"Profile_{userId}");
            }

                return "Profile updated successfully";
        }
    }
}
