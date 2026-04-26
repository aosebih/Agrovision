# Quick Start Guide - Windows Users

## 🎯 Goal
Get the Farmer's Helper Backend running on your Windows machine in under 10 minutes.

## ⚡ Fastest Method: Install PostgreSQL

### Step 1: Download PostgreSQL

1. Go to: https://www.postgresql.org/download/windows/
2. Click "Download the installer"
3. Download the latest version (PostgreSQL 14 or higher)

### Step 2: Install PostgreSQL

1. Run the downloaded installer
2. Click "Next" through the setup wizard
3. **IMPORTANT**: Remember the password you set for the `postgres` user
4. Keep the default port: `5432`
5. Complete the installation

### Step 3: Create the Database

**Option A: Using pgAdmin (GUI - Easier)**

1. Open pgAdmin (installed with PostgreSQL)
2. Connect to PostgreSQL (use the password you set)
3. Right-click "Databases" → "Create" → "Database"
4. Name: `farmers_helper`
5. Click "Save"

**Option B: Using Command Line**

1. Open Command Prompt or PowerShell
2. Run:
   ```cmd
   "C:\Program Files\PostgreSQL\14\bin\psql.exe" -U postgres
   ```
3. Enter your postgres password
4. Type:
   ```sql
   CREATE DATABASE farmers_helper;
   \q
   ```

### Step 4: Update .env File

Open the `.env` file in the project root and update:

```env
DB_PASSWORD=your_postgres_password_here
```

Replace `your_postgres_password_here` with the password you set during PostgreSQL installation.

### Step 5: Run Migrations

Open Command Prompt or PowerShell in the project directory:

```bash
npm run migration:run
```

You should see:
```
✅ Migration InitialSchema1700000000000 has been executed successfully.
```

### Step 6: (Optional) Add Sample Data

```bash
npm run seed
```

This creates a demo user and sample data.

### Step 7: Start the Application

```bash
npm run start:dev
```

You should see:
```
🚀 Server running on http://localhost:3000/api/v1
```

### Step 8: Test the API

Open a new Command Prompt/PowerShell and test:

```bash
curl -X POST http://localhost:3000/api/v1/auth/register -H "Content-Type: application/json" -d "{\"email\":\"test@example.com\",\"name\":\"Test User\",\"password\":\"password123\",\"farmName\":\"Test Farm\"}"
```

Or use a tool like:
- **Postman**: https://www.postman.com/downloads/
- **Insomnia**: https://insomnia.rest/download
- **Thunder Client** (VS Code extension)

## 🐳 Alternative: Using Docker (If You Have It)

If you have Docker Desktop installed:

### Step 1: Start PostgreSQL Container

```powershell
docker run --name farmers-helper-db `
  -e POSTGRES_PASSWORD=postgres `
  -e POSTGRES_DB=farmers_helper `
  -p 5432:5432 `
  -d postgres:14-alpine
```

### Step 2: Run Migrations

```bash
npm run migration:run
```

### Step 3: Start the Application

```bash
npm run start:dev
```

## 🔧 Troubleshooting

### Issue: "psql: command not found"

**Solution**: Add PostgreSQL to your PATH:

1. Open System Properties → Environment Variables
2. Edit "Path" in System Variables
3. Add: `C:\Program Files\PostgreSQL\14\bin`
4. Restart Command Prompt/PowerShell

### Issue: "Connection refused" or "ECONNREFUSED"

**Solutions**:
1. Check PostgreSQL is running:
   - Open Services (Win + R → `services.msc`)
   - Find "postgresql-x64-14" service
   - Make sure it's "Running"

2. Check the port:
   - Default is 5432
   - Make sure `.env` has `DB_PORT=5432`

3. Check credentials:
   - Username: `postgres`
   - Password: (the one you set during installation)
   - Database: `farmers_helper`

### Issue: "Migration failed"

**Solution**: Make sure the database exists:

```bash
"C:\Program Files\PostgreSQL\14\bin\psql.exe" -U postgres -c "CREATE DATABASE farmers_helper;"
```

### Issue: "Port 3000 already in use"

**Solution**: Change the port in `.env`:

```env
PORT=3001
```

Then access the API at `http://localhost:3001/api/v1`

### Issue: "npm install" fails

**Solution**: Use the legacy peer deps flag:

```bash
npm install --legacy-peer-deps
```

## 📱 Testing the API

### Using PowerShell

```powershell
# Register a user
Invoke-RestMethod -Uri "http://localhost:3000/api/v1/auth/register" `
  -Method POST `
  -ContentType "application/json" `
  -Body '{"email":"farmer@test.com","name":"John Farmer","password":"password123","farmName":"Test Farm"}'

# Login
$response = Invoke-RestMethod -Uri "http://localhost:3000/api/v1/auth/login" `
  -Method POST `
  -ContentType "application/json" `
  -Body '{"email":"farmer@test.com","password":"password123"}'

$token = $response.access_token
Write-Host "Token: $token"

# Get fields (authenticated)
Invoke-RestMethod -Uri "http://localhost:3000/api/v1/fields" `
  -Method GET `
  -Headers @{Authorization="Bearer $token"}
```

### Using Postman

1. **Register User**
   - Method: POST
   - URL: `http://localhost:3000/api/v1/auth/register`
   - Body (JSON):
     ```json
     {
       "email": "farmer@test.com",
       "name": "John Farmer",
       "password": "password123",
       "farmName": "Test Farm"
     }
     ```

2. **Login**
   - Method: POST
   - URL: `http://localhost:3000/api/v1/auth/login`
   - Body (JSON):
     ```json
     {
       "email": "farmer@test.com",
       "password": "password123"
     }
     ```
   - Copy the `access_token` from the response

3. **Get Fields**
   - Method: GET
   - URL: `http://localhost:3000/api/v1/fields`
   - Headers:
     - Key: `Authorization`
     - Value: `Bearer <your_access_token>`

## ✅ Success Checklist

- [ ] PostgreSQL installed and running
- [ ] Database `farmers_helper` created
- [ ] `.env` file updated with correct password
- [ ] Dependencies installed (`npm install`)
- [ ] Migrations run successfully (`npm run migration:run`)
- [ ] Application starts without errors (`npm run start:dev`)
- [ ] Can register a user via API
- [ ] Can login and receive JWT token

## 🎉 Next Steps

1. Explore the API endpoints (see README.md)
2. Connect a frontend application
3. Customize the database schema
4. Add your own features

## 📞 Need Help?

1. Check the main [README.md](./README.md)
2. Check the detailed [SETUP.md](./SETUP.md)
3. Review error messages carefully
4. Check PostgreSQL logs in pgAdmin

---

**You're all set! Happy farming! 🌾**
