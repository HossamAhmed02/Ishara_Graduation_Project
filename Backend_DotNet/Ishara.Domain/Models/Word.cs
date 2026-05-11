using Ishara.Domain.Models;

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Ishara.Domain.Models
{
    public class Word
    {
        public int WordId { get; set; }
        public string SignLanguageMovement { get; set; }
        public string WordOfSignLanguage { get; set; }

    }
}
