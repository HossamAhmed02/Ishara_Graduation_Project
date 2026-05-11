# Backend Development - Ishara Project

This section of the repository contains the BackEnd code for the Ishara project.

Ishara.Api: The Presentation Layer. Contains API Controllers, application configuration (Program.cs), and SignalR Hubs.

Ishara.Application: The Application Logic Layer. Contains Services, DTOs, Interfaces, and Background Services (e.g., unconfirmed account cleanup).

Ishara.Domain: The Core Domain Layer. Contains Entities, Enums, and Custom Exceptions.

Ishara.Persistence: The Data Access Layer. Contains the DbContext, Fluent API configurations, Repositories, and EF Core Migrations.

## Technology
* Framework: ASP.NET Core
* Architecture: Clean Architecture (Onion Architecture)
* Database: SQL Server
* Real-time Communication: SignalR
* Security: JWT Authentication and ASP.NET Core Identity

## Technical Implementation Details
* Implemented structural design patterns, including the Repository Pattern.
* Developed a secure Authentication and Authorization system to manage user access and protect data.
* Designed and exposed RESTful APIs to integrate with the Flutter frontend application and the Machine Learning model.
* Integrated SignalR to establish and manage the centralized real-time chat system.

# Ishara Project - Backend API

This is the backend service for the "Ishara" project, built using **Clean Architecture** to ensure scalability, maintainability, and a clear separation of concerns.

## Tech Stack & Versions
This project is built using the latest Microsoft technologies:
* **Framework:** ASP.NET Core Web API `v8.0`
* **ORM:** Entity Framework Core `v8.0.0`
* **Database:** SQL Server
* **Authentication:** * JWT Bearer Token `v8.0.0`
  * Google Authentication `v8.0.0`
* **Real-time Communication:** SignalR (for instant messaging)
* **Machine Learning Integration:** `HttpClient` (to communicate with the project's AI engine)
* **API Documentation:** Swashbuckle.AspNetCore (Swagger) `v6.6.2`

---

## Configuration & Setup
For privacy and security reasons, the original `appsettings.json` file is not included in this repository. To run the project locally, please follow these steps:

1. Create a copy of the `appsettings.Example.json` file and rename it to `appsettings.json`.
2. Open the new file and fill in your specific credentials:
   * **`ConnectionStrings:IsharaDB`**: Provide your SQL Server connection string.
   * **`Jwt:Key`**: Provide a strong secret key (minimum of 32 characters).
   * **`Authentication:Google`**: (Optional) Add your Google `ClientId` and `ClientSecret`.
   * **`EmailSettings`**: Provide your email and App Password to enable OTP email verification.
   * **`MLSettings:ModelPath`**: The URL of the AI translation service.

> ** Note for Local ML Execution:**
> If the Machine Learning engineer is running the translation server locally on their machine, make sure to update the model URL in `appsettings.json` to match the local port (usually, it looks like this):
> `"ModelPath": "http://127.0.0.1:8000/"`

---

## Getting Started
To run the server on your local machine:

1. Open a Terminal/Command Prompt inside the `Ishara.Api` folder.
2. Ensure you have the **.NET 8 SDK** installed on your machine.
3. Update and build the database (make sure your Connection String is already set in `appsettings.json`):
   ```bash
   dotnet ef database update --project ../Ishara.Persistence
