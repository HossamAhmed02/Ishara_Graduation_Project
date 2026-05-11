using Ishara.Application.DTOs;
using Ishara.Application.DTOs.Contacts;
using Ishara.Application.DTOs.Messages;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Ishara.Application.Interfaces
{
    public interface IContactService
    {
        public Task<IEnumerable<ContactResponseDto>> GetContactAsync(string Id);
        public Task AddContactAsync(string currentId, string contactId);
        public Task DeleteContactAsync(string currentId, string contactId);
        public Task<IEnumerable<UserSearchDto>> SearchUsersAsync(string currentId, string user, int pageNumber, int pageSize);
    }
}
