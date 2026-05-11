using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Ishara.Domain.Models;
using Ishara.Domain.Repository_Interfaces;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace Ishara.Application.BackgroundServices
{
    public class UnconfirmedAccountCleanupService : BackgroundService
    {
        private readonly IServiceProvider _serviceProvider;
        private readonly ILogger<UnconfirmedAccountCleanupService> _logger;

        public UnconfirmedAccountCleanupService(IServiceProvider serviceProvider, ILogger<UnconfirmedAccountCleanupService> logger)
        {
            _serviceProvider = serviceProvider;
            _logger = logger;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            _logger.LogInformation("========== Cleanup Service Started ==========");

            while (!stoppingToken.IsCancellationRequested)
            {
                try
                {
                    using (var scope = _serviceProvider.CreateScope())
                    {
                        var userManager = scope.ServiceProvider.GetRequiredService<UserManager<User>>();
                        var userRepo = scope.ServiceProvider.GetRequiredService<IUserRepository>();

                        var thresholdTime = DateTime.UtcNow.AddHours(-2);

                        var unconfirmedUsers = userManager.Users
                            .Where(u => !u.EmailConfirmed && u.CreatedAt <= thresholdTime)
                            .ToList();

                        if (unconfirmedUsers.Any())
                        {
                            _logger.LogInformation($"---> Found {unconfirmedUsers.Count} unconfirmed users.");

                            foreach (var user in unconfirmedUsers)
                            {
                                try
                                {
                                    var roles = await userManager.GetRolesAsync(user);
                                    if (roles.Any())
                                    {
                                        await userManager.RemoveFromRolesAsync(user, roles);
                                    }

                                    await userRepo.RemoveAllUserContactsAsync(user.Id);
                                    var result = await userManager.DeleteAsync(user);

                                    if (result.Succeeded)
                                    {
                                        _logger.LogInformation($"[SUCCESS] Deleted user: {user.Email}");
                                    }
                                    else
                                    {
                                        _logger.LogError($"[FAILED] Cannot delete {user.Email}: {string.Join(", ", result.Errors.Select(e => e.Description))}");
                                    }
                                }
                                catch (Exception ex)
                                {
                                    _logger.LogError($"Error deleting user {user.Email}: {ex.Message}");
                                }
                            }
                        }
                        else
                        {
                            _logger.LogInformation("---> No unconfirmed accounts found to delete.");
                        }
                    }
                }
                catch (Exception ex)
                {
                    _logger.LogError($"[CRITICAL ERROR]: {ex.Message}");
                }

                await Task.Delay(TimeSpan.FromHours(1), stoppingToken);
            }
        }
    }
}