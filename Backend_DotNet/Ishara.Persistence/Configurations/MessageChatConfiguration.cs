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
    public class MessageChatConfiguration : IEntityTypeConfiguration<MessageChat>
    {
        public void Configure(EntityTypeBuilder<MessageChat> builder)
        {
            builder.ToTable("MessageChats");

            builder.HasKey(x => x.MessageChatId);

            builder.Property(m => m.Content)
                .HasMaxLength(2000)
                .IsRequired();


            builder.HasOne(m => m.Sender)
              .WithMany()
              .HasForeignKey(m => m.SenderId)
              .OnDelete(DeleteBehavior.Restrict);
            
            builder.HasOne(m => m.Receiver)
              .WithMany()
              .HasForeignKey(m => m.ReceiverId)
              .OnDelete(DeleteBehavior.Restrict);

        }
    }
}
