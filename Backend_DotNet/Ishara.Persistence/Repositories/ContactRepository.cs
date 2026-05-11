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
    public class ContactRepository : IContactRepository
    {
        private readonly IsharaDbContext _context;
        public ContactRepository(IsharaDbContext context)
        {
            _context = context;
        }
        public async Task<IEnumerable<User>> GetContactsAsync(string id)
        {
            return await _context.UserContacts.Where(u => u.UserId == id)
                .Include(u => u.Contact)
                .Select(u => u.Contact)
                .OrderBy(u => u.FirstName)
                .ThenBy(u => u.LastName)
                .ToListAsync();
        }
        public async Task<bool> ContactExistsAsync(string userId, string contactId)
        {
            return await _context.UserContacts.AnyAsync(c => c.UserId == userId && c.ContactId == contactId);
        }
        public async Task<IEnumerable<User>> SearchUsersAsync(string currentId, string user, int pageNumber, int pageSize)
        {
            var existingContactIds = await _context.UserContacts
                .Where(uc => uc.UserId == currentId)
                .Select(uc => uc.ContactId)
                .ToListAsync();

            var query = _context.Users.AsQueryable();
            query = query.Where(u => u.Id != currentId && !existingContactIds.Contains(u.Id) && u.EmailConfirmed == true);


            if (!string.IsNullOrWhiteSpace(user))
            {
                user = user.ToLower();
                query = query.Where(u => u.Email.ToLower().Contains(user) ||
                                         u.FirstName.ToLower().Contains(user) ||
                                         u.LastName.ToLower().Contains(user) ||
                                         (u.FirstName.ToLower() + " " + u.LastName.ToLower()).Contains(user));
            }

            return await query
                .OrderBy(u => u.FirstName)
                .Skip((pageNumber - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();
        }
        public async Task AddContactAsync(UserContact user)
        {
            await _context.UserContacts.AddAsync(user);
        }
        public async Task DeleteContactAsync(string userId, string contactId)
        {
            var contactRecord = await _context.UserContacts
                .FirstOrDefaultAsync(c => c.UserId == userId && c.ContactId == contactId);
            if(contactRecord != null)
            {
                _context.UserContacts.Remove(contactRecord);
                await SaveChangeAsync();
            }
        }
        public async Task SaveChangeAsync()
        {
            await _context.SaveChangesAsync();
        }
    }
}
