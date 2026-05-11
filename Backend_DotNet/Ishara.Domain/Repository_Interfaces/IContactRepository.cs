using Ishara.Domain.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Ishara.Domain.Repository_Interfaces
{
    public interface IContactRepository
    {
        public Task<IEnumerable<User>> GetContactsAsync(string Id);
        public Task AddContactAsync(UserContact user);
        public Task DeleteContactAsync(string userId, string contactId);
        public Task<IEnumerable<User>> SearchUsersAsync(string currentId, string user, int pageNumber, int pageSize);
        public Task<bool> ContactExistsAsync(string userId, string contactId);
        public Task SaveChangeAsync();
    }
}
