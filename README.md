# CloudPhoria — Setup Instructions

CloudPhoria is an ASP.NET Web Forms (.NET Framework 4.7.2) application using SQL Server for data storage. Follow these steps to run it on a new machine (e.g. for marking/demo purposes).

## Requirements

- Visual Studio 2019 or later (with ASP.NET and web development workload)
- SQL Server (any edition — Express, Developer, or a full instance) **or** SQL Server Express LocalDB
- SQL Server Management Studio (SSMS) — optional, but useful for running the setup scripts

## 1. Create the database

1. Open SQL Server Management Studio (or use `sqlcmd`/Visual Studio's SQL Server Object Explorer).
2. Run the scripts in the `Database/` folder **in this order** (see `CloudPhoria_DataSchema.md` Section 2/13 for the full authoritative order if you need more detail):
   - The core table-creation script first (creates all 57 tables, constraints, and indexes)
   - Then the seed/data scripts that populate sample users, pathways, modules, questions, etc.
   - Then any `fix_*`/`add_*` scripts in `Database/` that add later features (classroom chat, extra boss fights, etc.)
3. Confirm the database was created by running `SELECT COUNT(*) FROM sys.tables;` — it should return 57.

## 2. Point the app at your SQL Server

Open `connectionStrings.config` in the project root. It already defaults to:

```xml
<add name="CloudPhoria"
     connectionString="Data Source=.;Initial Catalog=CloudPhoria;Integrated Security=True;TrustServerCertificate=True"
     providerName="System.Data.SqlClient" />
```

`Data Source=.` means "the default SQL Server instance on this machine" — **this should work without any changes** if you installed SQL Server normally and the database is on your local machine.

**If your SQL Server uses a named instance** (common with SQL Server Express, e.g. installed via the SSMS installer with a default name), change `Data Source=.` to `Data Source=.\SQLEXPRESS` (or whatever your instance is actually named — check in SSMS's "Connect to Server" dialog, the instance name is shown there).

## 3. Open and run the project

1. Open `CloudPhoria.slnx` (or the `.csproj`) in Visual Studio.
2. Let NuGet restore packages if prompted (Build → Restore NuGet Packages).
3. Press F5 / Start to run — this launches the site via IIS Express.
4. You should land on the public homepage (`Default.aspx`). Log in with one of the seeded demo accounts (see `Database/admin_setup.sql` or `CloudPhoria_ProjectRules.md` for seeded account credentials), or register a new Student account directly.

## Troubleshooting

- **"Cannot open database CloudPhoria" / "network-related or instance-specific error"** — the connection string's `Data Source` doesn't match your SQL Server instance name. See step 2 above.
- **Login page loads but every other page errors** — the database tables likely weren't created yet, or were created in the wrong order. Re-run the scripts in `Database/` starting from the table-creation script.
- **Build errors about missing packages** — run `Restore NuGet Packages` from the Solution Explorer right-click menu, or `nuget restore` from a command line in this folder.

## Project documentation

This project includes several supporting documentation files (not required for the app to run, but useful for understanding the system):

- `CloudPhoria_ProjectRules.md` — feature rules and business logic decisions
- `CloudPhoria_DataSchema.md` — full database schema (57 tables, columns, foreign keys)
- `CloudPhoria_UseCases_Student.md` / `_Instructor.md` / `_Admin.md` — use case specifications per role
- `CloudPhoria_ERD_UsedTables.md` — which tables are actually used by the app vs. seeded-but-unused
