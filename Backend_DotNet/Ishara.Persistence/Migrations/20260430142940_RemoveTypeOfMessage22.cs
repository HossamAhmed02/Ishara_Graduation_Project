using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Ishara.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class RemoveTypeOfMessage22 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "Type",
                table: "MessageChats",
                type: "int",
                nullable: false,
                defaultValue: 0);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Type",
                table: "MessageChats");
        }
    }
}
