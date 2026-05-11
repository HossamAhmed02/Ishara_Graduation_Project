using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Ishara.Application.DTOs.Auth
{
    public class TokenRequestDto
    {
        public string Token { get; set; }
        public string RefreshToken { get; set; }
    }
}
