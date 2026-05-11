using Ishara.Application.DTOs.MLModel;
using Ishara.Application.Interfaces.MLModel;
using Ishara.Domain.Exceptions;
using Ishara.Domain.Models;
using Ishara.Domain.Repository_Interfaces;
using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Ishara.Application.Services.MLModel
{
    public class TranslationService : ITranslationService
    {
        private readonly ITranslationRecordRepository _repo;
        private readonly IMlTranslationService _mlService;

        public TranslationService(ITranslationRecordRepository repo, IMlTranslationService mlService)
        {
            _repo = repo;
            _mlService = mlService;
        }

        public async Task<MlTranslationResponseDto> ProcessAndSaveTranslationAsync(IFormFile videoFile, string userId)
        {
            var mlResult = await _mlService.TranslateVideoAsync(videoFile);

            if (mlResult == null || string.IsNullOrEmpty(mlResult.Prediction))
                throw new BadRequestCustomException("Failed to retrieve translation from AI servers");

            var translationRecord = new TranslationRecord
            {
                UserId = userId,
                TranslatedWord = mlResult.Prediction,
                FinalSentence = mlResult.Final_Sentence,
                Confidence = mlResult.Confidence,
                TranslatedAt = DateTime.UtcNow
            };

            await _repo.AddTranslationRecordAsync(translationRecord);
            await _repo.SaveChangesAsync();

            return mlResult;
        }
    }
}
