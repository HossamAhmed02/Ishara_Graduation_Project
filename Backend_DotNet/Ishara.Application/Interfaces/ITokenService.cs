using Ishara.Domain.Enums;
using Ishara.Domain.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Text;
using System.Threading.Tasks;

namespace Ishara.Application.Interfaces
{
    public interface ITokenService
    {
        string GenerateAccessToken (User user , IList<string> roles);
        string GenerateRefreshToken();
        ClaimsPrincipal GetPrincipalFromExpiredToken(string token);
    }
}
