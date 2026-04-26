# Farmer's Helper Backend API

A comprehensive NestJS-based backend API for managing farm operations including fields, crops, irrigation, fertilizers, inventory, alerts, activities, treatments, and schedules.

## 🚀 Features

- **User Authentication** - JWT-based authentication with secure password hashing
- **Field Management** - Track and manage farm fields with location and soil data
- **Crop Management** - Monitor crop growth stages, health scores, and harvest dates
- **Irrigation System** - Control irrigation zones and track water usage events
- **Fertilizer Management** - Track fertilizers and application records
- **Inventory System** - Manage farm supplies with low-stock alerts
- **Alert System** - Weather, crop health, and system notifications
- **Activity Tracking** - Log farm activities and inspections
- **Treatment Records** - Track pesticide and herbicide applications
- **Scheduling** - Plan and automate recurring farm tasks
- **Analytics** - Dashboard statistics and insights

## 📋 Prerequisites

Choose ONE of the following options:

### Option A: Native PostgreSQL (Recommended for Production)
- Node.js v18+ ([Download](https://nodejs.org/))
- PostgreSQL v14+ ([Download](https://www.postgresql.org/download/))
- npm or pnpm

### Option B: Docker (Recommended for Development)
- Node.js v18+ ([Download](https://nodejs.org/))
- Docker Desktop ([Download](https://www.docker.com/products/docker-desktop))

## 🛠️ Installation

### 1. Clone and Install Dependencies

```bash
# Install dependencies
npm install --legacy-peer-deps
```

### 2. Environment Configuration

The `.env` file has been created with default values. Update it with your credentials:

```env
# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=your_password_here  # ⚠️ CHANGE THIS
DB_NAME=farmers_helper

# JWT Configuration
JWT_SECRET=your_jwt_secret_key_here_change_in_production  # ⚠️ CHANGE THIS

# Application
NODE_ENV=development
PORT=3000
```

### 3. Database Setup

#### Option A: Using Docker (Easiest)

```bash
# Start PostgreSQL in Docker
docker run --name farmers-helper-db \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=farmers_helper \
  -p 5432:5432 \
  -d postgres:14-alpine

# Or use Docker Compose (starts everything)
docker-compose up -d
```

#### Option B: Using Native PostgreSQL

1. **Install PostgreSQL** from https://www.postgresql.org/download/

2. **Create Database:**
   ```bash
   # Windows (Command Prompt or PowerShell)
   psql -U postgres
   
   # In psql prompt:
   CREATE DATABASE farmers_helper;
   \q
   ```

3. **Update .env** with your PostgreSQL password

### 4. Run Database Migrations

```bash
npm run migration:run
```

### 5. (Optional) Seed Sample Data

```bash
npm run seed
```

This creates:
- Demo user: `demo@agriapp.com` / `password123`
- Sample fields, crops, fertilizers, and inventory items

## 🚀 Running the Application

### Development Mode
```bash
npm run start:dev
```

### Production Mode
```bash
npm run build
npm run start:prod
```

### Using Docker Compose (All-in-One)
```bash
docker-compose up
```

The API will be available at: **http://localhost:3000/api/v1**

## 📚 API Documentation

### Authentication Endpoints

#### Register User
```bash
POST /api/v1/auth/register
Content-Type: application/json

{
  "email": "farmer@example.com",
  "name": "John Farmer",
  "password": "password123",
  "farmName": "Green Valley Farm"
}
```

#### Login
```bash
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "farmer@example.com",
  "password": "password123"
}

Response:
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

### Protected Endpoints

All other endpoints require JWT authentication. Include the token in the Authorization header:

```bash
Authorization: Bearer <your_access_token>
```

### Main Resource Endpoints

- **Fields**: `/api/v1/fields`
- **Crops**: `/api/v1/crops`
- **Irrigation**: `/api/v1/irrigation`
- **Fertilizers**: `/api/v1/fertilizers`
- **Inventory**: `/api/v1/inventory`
- **Alerts**: `/api/v1/alerts`
- **Activities**: `/api/v1/activities`
- **Treatments**: `/api/v1/treatments`
- **Schedules**: `/api/v1/schedules`
- **Analytics**: `/api/v1/analytics`

## 🗄️ Database Management

### Migrations

```bash
# Run pending migrations
npm run migration:run

# Revert last migration
npm run migration:revert

# Generate new migration from entity changes
npm run migration:generate -- src/database/migrations/MigrationName

# Create empty migration
npm run migration:create -- src/database/migrations/MigrationName
```

### Schema Operations

```bash
# Sync schema (development only - dangerous!)
npm run schema:sync

# Drop all tables (CAUTION!)
npm run schema:drop
```

## 🧪 Testing

```bash
# Unit tests
npm run test

# E2E tests
npm run test:e2e

# Test coverage
npm run test:cov

# Watch mode
npm run test:watch
```

## 📦 Project Structure

```
src/
├── activities/          # Farm activity tracking
├── alerts/             # Alert and notification system
├── analytics/          # Dashboard analytics
├── auth/               # Authentication (JWT, Passport)
│   ├── strategies/     # JWT and Local strategies
│   ├── guards/         # Auth guards
│   └── dto/           # Login DTOs
├── common/             # Shared utilities
│   ├── decorators/     # Custom decorators
│   ├── dto/           # Pagination DTOs
│   └── entities/      # Base entity
├── crops/              # Crop management
├── database/           # Database configuration
│   ├── migrations/     # TypeORM migrations
│   └── seeds/         # Database seeders
├── fertilizers/        # Fertilizer management
├── fields/             # Field management
├── inventory/          # Inventory system
├── irrigation/         # Irrigation control
├── schedules/          # Task scheduling
├── treatments/         # Treatment records
└── users/              # User management
```

## 🔧 Development

### Code Quality

```bash
# Lint code
npm run lint

# Format code
npm run format
```

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `DB_HOST` | PostgreSQL host | `localhost` |
| `DB_PORT` | PostgreSQL port | `5432` |
| `DB_USERNAME` | Database username | `postgres` |
| `DB_PASSWORD` | Database password | `postgres` |
| `DB_NAME` | Database name | `farmers_helper` |
| `JWT_SECRET` | JWT signing secret | (required) |
| `NODE_ENV` | Environment | `development` |
| `PORT` | Application port | `3000` |

## 🐳 Docker Support

### Using Docker Compose (Recommended)

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop all services
docker-compose down

# Rebuild and start
docker-compose up -d --build
```

### Manual Docker Commands

```bash
# Build image
docker build -t farmers-helper-backend .

# Run container
docker run -p 3000:3000 \
  -e DB_HOST=host.docker.internal \
  -e DB_PASSWORD=postgres \
  farmers-helper-backend
```

## 🚀 Deployment

### Production Checklist

- [ ] Set strong `JWT_SECRET` (min 32 characters)
- [ ] Use secure database password
- [ ] Set `NODE_ENV=production`
- [ ] Enable HTTPS/SSL
- [ ] Configure CORS for specific origins
- [ ] Set up database backups
- [ ] Enable rate limiting
- [ ] Set up monitoring (PM2, New Relic, etc.)
- [ ] Configure logging (Winston, Pino)
- [ ] Set up CI/CD pipeline

### Deployment Platforms

- **Heroku**: Use Heroku Postgres add-on
- **AWS**: Use RDS for PostgreSQL + EC2/ECS
- **DigitalOcean**: Use Managed PostgreSQL + App Platform
- **Railway**: Automatic PostgreSQL provisioning
- **Render**: Built-in PostgreSQL support

## 🔒 Security

- Passwords hashed with bcryptjs (10 salt rounds)
- JWT token-based authentication
- Input validation with class-validator
- SQL injection protection via TypeORM
- CORS enabled (configure for production)
- Helmet.js recommended for production

## 📝 License

This project is licensed under the UNLICENSED license.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 📞 Support

For detailed setup instructions, see [SETUP.md](./SETUP.md)

## 🎯 Roadmap

- [ ] API documentation with Swagger/OpenAPI
- [ ] Real-time updates with WebSockets
- [ ] File upload for field images
- [ ] Weather API integration
- [ ] Mobile app support
- [ ] Multi-language support
- [ ] Advanced analytics and reporting
- [ ] IoT sensor integration

---

**Built with ❤️ using NestJS, TypeORM, and PostgreSQL**
