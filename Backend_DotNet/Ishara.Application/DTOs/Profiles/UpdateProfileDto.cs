using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Ishara.Application.DTOs.Profiles
{
    public class UpdateProfileDto
    {
        [Required(ErrorMessage = "First name is required and cannot be empty.")]
        [MaxLength(20, ErrorMessage = "First name cannot exceed 20 characters.")]
        public string FirstName { get; set; }

        [Required(ErrorMessage = "Last name is required and cannot be empty.")]
        [MaxLength(20, ErrorMessage = "Last name cannot exceed 20 characters.")]
        public string LastName { get; set; }

        [MinLength(0, ErrorMessage = "Password must be at least 6 characters long.")]
        public string? NewPassword { get; set; }
    }
}
