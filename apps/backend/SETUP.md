# Farmer's Helper Backend - Setup Guide

## Prerequisites

- Node.js (v18 or higher)
- PostgreSQL (v14 or higher) OR Docker
- npm or pnpm

## Option 1: Setup with PostgreSQL (Native Installation)

### 1. Install PostgreSQL

**Windows:**
- Download from: https://www.postgresql.org/download/windows/
- Run the installer and remember your postgres user password
- Default port: 5432

**macOS:**
```bash
brew install postgresql@14
brew services start postgresql@14
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
sudo systemctl start postgresql
```

### 2. Create Database

```bash
# Connect to PostgreSQL
psql -U postgres

# In psql prompt:
CREATE DATABASE farmers_helper;
\q
```

### 3. Configure Environment

Update `.env` file with your PostgreSQL credentials:
```env
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=your_postgres_password
DB_NAME=farmers_helper
JWT_SECRET=your_secure_jwt_secret
```

### 4. Run Migrations

```bash
npm run migration:run
```

### 5. Start the Application

```bash
# Development mode
npm run start:dev

# Production mode
npm run build
npm run start:prod
```

## Option 2: Setup with Docker (Recommended for Development)

### 1. Install Docker

- Download from: https://www.docker.com/products/docker-desktop

### 2. Start PostgreSQL Container

```bash
docker run --name farmers-helper-db \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=farmers_helper \
  -p 5432:5432 \
  -d postgres:14-alpine
```

**Windows PowerShell:**
```powershell
docker run --name farmers-helper-db `
  -e POSTGRES_PASSWORD=postgres `
  -e POSTGRES_DB=farmers_helper `
  -p 5432:5432 `
  -d postgres:14-alpine
```

### 3. Verify Database is Running

```bash
docker ps
```

### 4. Run Migrations

```bash
npm run migration:run
```

### 5. Start the Application

```bash
npm run start:dev
```

## Option 3: Quick Start with Docker Compose

### 1. Create docker-compose.yml

Already created in the project root.

### 2. Start Everything

```bash
docker-compose up -d
```

This will:
- Start PostgreSQL database
- Run migrations automatically
- Start the backend application

### 3. Access the Application

- API: http://localhost:3000/api/v1
- Database: localhost:5432

### 4. Stop Everything

```bash
docker-compose down
```

## Database Management

### Run Migrations
```bash
npm run migration:run
```

### Revert Last Migration
```bash
npm run migration:revert
```

### Generate New Migration
```bash
npm run migration:generate -- src/database/migrations/MigrationName
```

### Drop All Tables (CAUTION!)
```bash
npm run schema:drop
```

## Seeding Sample Data (Optional)

```bash
npm run seed
```

## Testing the API

### Register a User
```bash
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "farmer@example.com",
    "name": "John Farmer",
    "password": "password123",
    "farmName": "Green Valley Farm"
  }'
```

### Login
```bash
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "farmer@example.com",
    "password": "password123"
  }'
```

## Troubleshooting

### Database Connection Issues

1. **Check PostgreSQL is running:**
   ```bash
   # Native installation
   pg_isready
   
   # Docker
   docker ps | grep farmers-helper-db
   ```

2. **Check credentials in .env file**

3. **Check PostgreSQL logs:**
   ```bash
   # Docker
   docker logs farmers-helper-db
   ```

### Migration Issues

1. **Check database exists:**
   ```bash
   psql -U postgres -l
   ```

2. **Manually create database if needed:**
   ```bash
   psql -U postgres -c "CREATE DATABASE farmers_helper;"
   ```

### Port Already in Use

If port 3000 or 5432 is already in use:

1. **Change application port in .env:**
   ```env
   PORT=3001
   ```

2. **Change database port:**
   ```env
   DB_PORT=5433
   ```
   
   And update Docker command:
   ```bash
   docker run -p 5433:5432 ...
   ```

## Next Steps

1. ✅ Database setup complete
2. ✅ Migrations run successfully
3. ✅ Application running
4. 📝 Test API endpoints
5. 📝 Set up frontend connection
6. 📝 Deploy to production

## Production Deployment

### Environment Variables

Ensure these are set in production:

```env
NODE_ENV=production
DB_HOST=your_production_db_host
DB_PORT=5432
DB_USERNAME=your_production_db_user
DB_PASSWORD=your_secure_password
DB_NAME=farmers_helper_prod
JWT_SECRET=your_very_secure_jwt_secret_min_32_chars
PORT=3000
```

### Security Checklist

- [ ] Change JWT_SECRET to a strong random string
- [ ] Use strong database password
- [ ] Enable HTTPS/SSL
- [ ] Set up database backups
- [ ] Configure CORS for specific origins
- [ ] Enable rate limiting
- [ ] Set up monitoring and logging
- [ ] Use environment-specific .env files

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review NestJS documentation: https://docs.nestjs.com
3. Review TypeORM documentation: https://typeorm.io
