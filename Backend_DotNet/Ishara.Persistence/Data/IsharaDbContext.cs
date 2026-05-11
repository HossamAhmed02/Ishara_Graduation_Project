using Ishara.Domain.Models;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;

namespace Ishara.Persistence
{
    public class IsharaDbContext : IdentityDbContext<User>
    {
        public IsharaDbContext(DbContextOptions<IsharaDbContext> options)
               : base(options)
        {
        }

        public DbSet<Word> Words { get; set; }
        public DbSet<TranslationRecord> TranslationRecords { get; set; }
        public DbSet<MessageChat> Messages { get; set; }
        public DbSet<UserContact> UserContacts { get; set; }

        protected override void OnModelCreating(ModelBuilder builder)
        {
            base.OnModelCreating(builder);

            builder.ApplyConfigurationsFromAssembly(typeof(IsharaDbContext).Assembly);

            builder.Entity<User>().ToTable("Users");
            builder.Entity<IdentityRole>().ToTable("Roles");
            builder.Entity<IdentityUserRole<string>>().ToTable("UserRoles");
        }
    }
}
