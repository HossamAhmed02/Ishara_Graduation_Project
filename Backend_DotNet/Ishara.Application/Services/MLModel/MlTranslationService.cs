using Ishara.Application.DTOs.MLModel;
using Ishara.Application.Interfaces.MLModel;
using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

namespace Ishara.Application.Services
{
    public class MlTranslationService : IMlTranslationService
    {
        private readonly HttpClient _httpClient;
        public MlTranslationService(HttpClient httpClient)
        {
            _httpClient = httpClient;
        }
        public async Task<MlTranslationResponseDto> TranslateVideoAsync(IFormFile videoFile)
        {
            using var content = new MultipartFormDataContent();

            var stream = videoFile.OpenReadStream();
            var streamContent = new StreamContent(stream);
            streamContent.Headers.ContentType = new MediaTypeHeaderValue(videoFile.ContentType);

            content.Add(streamContent, "video", videoFile.FileName);

            var response = await _httpClient.PostAsync("translate", content);

            var responseString = await response.Content.ReadAsStringAsync();
            if (!response.IsSuccessStatusCode)
            {
                throw new Exception($"ML API Error: {response.StatusCode} - {responseString}");
            }

            var options = new JsonSerializerOptions { PropertyNameCaseInsensitive = true };
            return JsonSerializer.Deserialize<MlTranslationResponseDto>(responseString, options);
        }
    }
}