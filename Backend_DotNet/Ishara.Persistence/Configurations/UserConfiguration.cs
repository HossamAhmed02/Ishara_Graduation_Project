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
    public class UserConfiguration : IEntityTypeConfiguration<User>
    {
        public void Configure(EntityTypeBuilder<User> builder)
        {
            builder.ToTable("Users");

            builder.Property(x => x.FirstName)
                   .HasMaxLength(50)
                   .IsRequired();

            builder.Property(x => x.LastName)
                   .HasMaxLength(50)
                   .IsRequired();

            builder.Property(x => x.Role)
                   .HasConversion<string>()
                   .HasMaxLength(20);

            builder.Property(x => x.Otp)
                .HasMaxLength(6);

            builder.Property(x => x.OtpExpiry)
                .IsRequired(false);

            builder.Property(x => x.RefreshToken)
                .IsRequired(false)
                .HasMaxLength(250);

            builder.Property(x => x.RefreshTokenExpiryTime)
                .IsRequired(false);
        }
    }
}
