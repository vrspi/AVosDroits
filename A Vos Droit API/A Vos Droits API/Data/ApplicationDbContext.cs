using AVosDroitsAPI.Models.Entities;
using Microsoft.EntityFrameworkCore;

namespace AVosDroitsAPI.Data;

public class ApplicationDbContext : DbContext
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options)
    {
    }

    public DbSet<User> Users { get; set; } = null!;
    public DbSet<Questionnaire> Questionnaires { get; set; } = null!;
    public DbSet<QuestionnaireSection> QuestionnaireSections { get; set; } = null!;
    public DbSet<QuestionnaireResponse> QuestionnaireResponses { get; set; } = null!;
    public DbSet<QuestionnaireQuestion> QuestionnaireQuestions { get; set; } = null!;
    public DbSet<QuestionOption> QuestionOptions { get; set; } = null!;

    protected override void OnModelCreating(ModelBuilder builder)
    {
        base.OnModelCreating(builder);

        builder.Entity<User>(entity =>
        {
            entity.HasIndex(e => e.Email).IsUnique();
            entity.Property(e => e.CreatedAt).HasDefaultValueSql("GETUTCDATE()");
        });

        builder.Entity<Questionnaire>(entity =>
        {
            entity.HasOne(q => q.User)
                .WithMany()
                .HasForeignKey(q => q.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            entity.Property(e => e.CreatedAt).HasDefaultValueSql("GETUTCDATE()");
        });

        builder.Entity<QuestionnaireSection>(entity =>
        {
            entity.HasOne(s => s.Questionnaire)
                .WithMany(q => q.Sections)
                .HasForeignKey(s => s.QuestionnaireId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        builder.Entity<QuestionnaireResponse>(entity =>
        {
            entity.HasOne(r => r.User)
                .WithMany()
                .HasForeignKey(r => r.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            entity.Property(e => e.CreatedAt).HasDefaultValueSql("GETUTCDATE()");

            entity.HasIndex(r => new { r.UserId, r.QuestionId, r.SessionId })
                .IsUnique()
                .HasDatabaseName("IX_QuestionnaireResponse_UserQuestion");
        });

        builder.Entity<QuestionnaireQuestion>(entity =>
        {
            entity.HasKey(q => q.Id);
            entity.Property(q => q.Id).ValueGeneratedNever();
            entity.HasIndex(q => new { q.SectionId, q.Order }).IsUnique();
            entity.HasMany(q => q.Options)
                .WithOne()
                .HasForeignKey(o => o.QuestionId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        builder.Entity<QuestionOption>(entity =>
        {
            entity.HasKey(o => o.Id);
            entity.Property(o => o.Id).UseIdentityColumn();
        });
    }
} 