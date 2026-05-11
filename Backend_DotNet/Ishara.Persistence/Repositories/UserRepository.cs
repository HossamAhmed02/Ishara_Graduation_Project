using Ishara.Application.Interfaces;
using Ishara.Domain.Models;
using Ishara.Domain.Repository_Interfaces;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Ishara.Persistence.Repositories
{
    public class UserRepository : IUserRepository
    {
        private readonly IsharaDbContext _context;

        public UserRepository(IsharaDbContext context)
        {
            _context = context;
        }

        public async Task RemoveAllUserContactsAsync(string userId)
        {
            var contacts = await _context.UserContacts
                .Where(c => c.UserId == userId || c.ContactId == userId)
                .ToListAsync();

            if (contacts.Any())
            {
                _context.UserContacts.RemoveRange(contacts);
                await _context.SaveChangesAsync();
            }
        }
    }
}