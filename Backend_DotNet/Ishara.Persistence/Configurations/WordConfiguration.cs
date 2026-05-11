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
    public class WordConfiguration : IEntityTypeConfiguration<Word>
    {
        public void Configure(EntityTypeBuilder<Word> builder)
        {
            builder.ToTable("Words");

            builder.HasKey(x => x.WordId);

            builder.Property(x => x.WordOfSignLanguage)
                .HasMaxLength(50)
                .IsRequired();

            builder.HasIndex(x => x.WordOfSignLanguage)
                .IsUnique();

            builder.Property(x => x.SignLanguageMovement)
                .HasMaxLength(500)
                .IsRequired();
        }
    }
}
