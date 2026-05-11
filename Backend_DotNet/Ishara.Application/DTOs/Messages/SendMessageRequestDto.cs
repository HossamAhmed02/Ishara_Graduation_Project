using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Ishara.Application.DTOs.Messages
{
    public class SendMessageRequestDto
    {
        [Required]
        public string ReceiverId { get; set; }

        [Required(ErrorMessage = "Message Empty")]
        [MinLength(1, ErrorMessage = "Message Empty")]
        public string Content { get; set; }
    }
}
