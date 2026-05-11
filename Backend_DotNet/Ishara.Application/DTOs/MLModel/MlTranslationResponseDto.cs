using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Ishara.Application.DTOs.MLModel
{
    public class MlTranslationResponseDto
    {
        public string Prediction { get; set; }
        public double Confidence { get; set; }
        public string Final_Sentence { get; set; }
    }
}
