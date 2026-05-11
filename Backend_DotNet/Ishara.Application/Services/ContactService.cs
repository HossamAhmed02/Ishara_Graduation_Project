using Ishara.Application.DTOs;
using Ishara.Application.DTOs.Contacts;
using Ishara.Application.DTOs.Messages;
using Ishara.Application.Interfaces;
using Ishara.Domain.Exceptions;
using Ishara.Domain.Models;
using Ishara.Domain.Repository_Interfaces;
using Microsoft.Extensions.Caching.Memory;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Cache;
using System.Text;
using System.Threading.Tasks;

namespace Ishara.Application.Services
{
    public class ContactService : IContactService
    {
        private readonly IContactRepository _repo;
        private readonly IMemoryCache _cache;
        public ContactService(IContactRepository repo, IMemoryCache cache)
        {
            _repo = repo;
            _cache = cache;
        }
        public async Task<IEnumerable<ContactResponseDto>> GetContactAsync(string Id)
        {
            string cacheKey = $"Contacts_{Id}";

            if (!_cache.TryGetValue(cacheKey, out IEnumerable<ContactResponseDto> contacts))
            {
                var dbContacts = await _repo.GetContactsAsync(Id);
                contacts = dbContacts.Select(c => new ContactResponseDto
                {
                    ContactId = c.Id,
                    FullName = c.FirstName + " " + c.LastName,
                    Email = c.Email
                });
                var cacheOptions = new MemoryCacheEntryOptions()
                    .SetAbsoluteExpiration(TimeSpan.FromDays(1));
                _cache.Set(cacheKey, contacts, cacheOptions);
            }
            return contacts;
        }
        public async Task<IEnumerable<UserSearchDto>> SearchUsersAsync(string currentId, string user, int pageNumber, int pageSize)
        {
            var users = await _repo.SearchUsersAsync(currentId, user, pageNumber, pageSize);

            return users.Select(u => new UserSearchDto
            {
                Id = u.Id,
                FullName = u.FirstName + " " + u.LastName,
                Email = u.Email
            });
        }

        public async Task AddContactAsync(string currentId, string contactId)
        {
            if(currentId == contactId)
                throw new BadRequestCustomException("Can't Add Yourself");

            if (await _repo.ContactExistsAsync(currentId, contactId))
                throw new BadRequestCustomException("This user is already in your contacts list");

            var NewContact = new UserContact
            {
                UserId = currentId,
                ContactId = contactId
            };
            await _repo.AddContactAsync(NewContact);
            await _repo.SaveChangeAsync();
            _cache.Remove($"Contacts_{currentId}");
        }

        public async Task DeleteContactAsync(string currentId, string contactId)
        {
            if(currentId == contactId)
                throw new BadRequestCustomException("Can't Delete Yourself");

            if (!await _repo.ContactExistsAsync(currentId, contactId))
                throw new NotFoundCustomException("This user is not in your contacts list");

            await _repo.DeleteContactAsync(currentId, contactId);
            _cache.Remove($"Contacts_{currentId}");
        }
    }
}
