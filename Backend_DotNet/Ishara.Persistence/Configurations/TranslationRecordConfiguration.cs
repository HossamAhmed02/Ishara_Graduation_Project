using Ishara.Domain.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Ishara.Persistence.Configurations
{
    public class TranslationRecordConfiguration : IEntityTypeConfiguration<TranslationRecord>
    {
        public void Configure(EntityTypeBuilder<TranslationRecord> builder)
        {
            builder.ToTable("TranslationRecords");


            builder.HasKey(x => x.TranslationRecordId);

            builder.Property(x => x.TranslatedAt)
                .IsRequired();
            
            builder.Property(x => x.TranslatedWord)
                .HasMaxLength(100)
                .IsRequired();

            builder.Property(x => x.FinalSentence)
                .HasMaxLength(500);

            builder.HasOne(x => x.User)
                .WithMany()
                .HasForeignKey(x => x.UserId)
                .OnDelete(DeleteBehavior.Cascade);


            builder.HasIndex(x => x.UserId);
        }
    }
}