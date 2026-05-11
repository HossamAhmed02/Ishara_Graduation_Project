using Ishara.Domain.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Ishara.Domain.Repository_Interfaces
{
    public interface IUserRepository
    {
        Task RemoveAllUserContactsAsync(string userId);
    }
}