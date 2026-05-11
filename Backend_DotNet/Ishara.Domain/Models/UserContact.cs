using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Ishara.Domain.Models
{
    public class UserContact
    {
        public string UserId { get; set; }
        public User User { get; set; }
        public string ContactId { get; set; }
        public User Contact { get; set; }
        public DateTime AddedAt { get; set; } = DateTime.UtcNow;

    }
}
