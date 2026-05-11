using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Ishara.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class MLModel : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_TranslationRecords_Words_WordId",
                table: "TranslationRecords");

            migrationBuilder.DropIndex(
                name: "IX_TranslationRecords_WordId",
                table: "TranslationRecords");

            migrationBuilder.DropColumn(
                name: "WordId",
                table: "TranslationRecords");

            migrationBuilder.AddColumn<double>(
                name: "Confidence",
                table: "TranslationRecords",
                type: "float",
                nullable: false,
                defaultValue: 0.0);

            migrationBuilder.AddColumn<string>(
                name: "FinalSentence",
                table: "TranslationRecords",
                type: "nvarchar(500)",
                maxLength: 500,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "TranslatedWord",
                table: "TranslationRecords",
                type: "nvarchar(100)",
                maxLength: 100,
                nullable: false,
                defaultValue: "");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Confidence",
                table: "TranslationRecords");

            migrationBuilder.DropColumn(
                name: "FinalSentence",
                table: "TranslationRecords");

            migrationBuilder.DropColumn(
                name: "TranslatedWord",
                table: "TranslationRecords");

            migrationBuilder.AddColumn<int>(
                name: "WordId",
                table: "TranslationRecords",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.CreateIndex(
                name: "IX_TranslationRecords_WordId",
                table: "TranslationRecords",
                column: "WordId");

            migrationBuilder.AddForeignKey(
                name: "FK_TranslationRecords_Words_WordId",
                table: "TranslationRecords",
                column: "WordId",
                principalTable: "Words",
                principalColumn: "WordId",
                onDelete: ReferentialAction.Restrict);
        }
    }
}
