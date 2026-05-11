using Ishara.Domain.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Ishara.Domain.Models
{
    public class TranslationRecord
    {
        public int TranslationRecordId { get; set; }
        public DateTime TranslatedAt { get; set; } = DateTime.UtcNow;

        public string TranslatedWord { get; set; }
        public string FinalSentence { get; set; }
        public double Confidence { get; set; }

        public string UserId { get; set; }
        public User? User { get; set; }
    }
}
