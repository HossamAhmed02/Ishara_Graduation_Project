using Ishara.Application.DTOs.MLModel;
using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Ishara.Application.Interfaces.MLModel
{
    public interface IMlTranslationService
    {
        Task<MlTranslationResponseDto> TranslateVideoAsync(IFormFile videoFile);
    }
}
