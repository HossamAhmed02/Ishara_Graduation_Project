using Ishara.Domain.Models;
using Ishara.Domain.Repository_Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Ishara.Persistence.Repositories
{
    public class TranslationRecordRepository : ITranslationRecordRepository
    {
        private readonly IsharaDbContext _context;

        public TranslationRecordRepository(IsharaDbContext context)
        {
            _context = context;
        }

        public async Task AddTranslationRecordAsync(TranslationRecord record)
        {
            await _context.TranslationRecords.AddAsync(record);
        }

        public async Task SaveChangesAsync()
        {
            await _context.SaveChangesAsync();
        }
    }
}
