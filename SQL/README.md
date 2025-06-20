---
⚡ Temp Table Setup

- Use `temp_table_setup.sql` to spin up temp sandbox tables directly in your company’s DB.
- Safe: they do not persist — they disappear when your session ends.
- Includes: `#employees`, `#departments`, `#sales` + example joins & window functions.
- Works best for SQL Server (`#tables`); for PostgreSQL use `CREATE TEMP TABLE`.

---

🔑 Usage

1️⃣ Open SSMS (SQL Server) or psql/pgAdmin (PostgreSQL)  
2️⃣ Run `temp_table_setup.sql`  
3️⃣ Test any queries from `RealWorldScenarios.sql` on these tables  
4️⃣ Close session — everything is clean!

---

✅ Goal

✔️ Practice real scenarios safely.  
✔️ Impress interviewers by testing advanced queries like a pro.  
✔️ Show your sandbox mastery on GitHub!

---
