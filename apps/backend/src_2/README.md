# Farmer Helper Backend API

A comprehensive NestJS backend application for managing farm operations, built with PostgreSQL and TypeORM.

## Features

- **User Management**: Authentication and authorization with JWT
- **Field Management**: Track and manage agricultural fields
- **Crop Management**: Monitor crop lifecycle, health, and growth stages
- **Irrigation System**: Control irrigation zones and track water usage
- **Fertilizer Management**: Track fertilizers and application records
- **Treatment Tracking**: Manage pesticides, herbicides, and other treatments
- **Inventory Management**: Track supplies, equipment, and stock levels
- **Activity Logging**: Record all farm activities
- **Alert System**: Receive notifications for important events
- **Scheduling**: Plan and schedule farm operations
- **Analytics Dashboard**: Get insights into farm operations

## Tech Stack

- **Framework**: NestJS
- **Database**: PostgreSQL
- **ORM**: TypeORM
- **Authentication**: JWT with Passport
- **Validation**: class-validator & class-transformer
- **Password Hashing**: bcryptjs

## Prerequisites

- Node.js (v16 or higher)
- PostgreSQL (v12 or higher)
- npm or yarn

## Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   npm install
   ```

3. Copy `.env.example` to `.env` and configure your environment variables:
   ```bash
   cp .env.example .env
   ```

4. Create the PostgreSQL database:
   ```sql
   CREATE DATABASE agri_db;
   ```

5. Run migrations:
   ```bash
   npm run migration:run
   ```

6. (Optional) Seed the database:
   ```bash
   npm run seed
   ```

## Running the Application

### Development
```bash
npm run start:dev
```

### Production
```bash
npm run build
npm run start:prod
```

The API will be available at `http://localhost:3000/api/v1`

## API Endpoints

### Authentication
- `POST /api/v1/auth/register` - Register new user
- `POST /api/v1/auth/login` - Login user

### Users
- `GET /api/v1/users/profile` - Get user profile
- `PUT /api/v1/users/profile` - Update user profile

### Fields
- `POST /api/v1/fields` - Create field
- `GET /api/v1/fields` - List all fields
- `GET /api/v1/fields/:id` - Get field details
- `PUT /api/v1/fields/:id` - Update field
- `DELETE /api/v1/fields/:id` - Delete field

### Crops
- `POST /api/v1/crops` - Create crop
- `GET /api/v1/crops` - List all crops
- `GET /api/v1/crops/:id` - Get crop details
- `PUT /api/v1/crops/:id` - Update crop
- `DELETE /api/v1/crops/:id` - Delete crop

### Irrigation
- `POST /api/v1/irrigation/zones` - Create irrigation zone
- `GET /api/v1/irrigation/zones` - List zones
- `POST /api/v1/irrigation/zones/:id/activate` - Activate zone
- `POST /api/v1/irrigation/zones/:id/stop` - Stop zone
- `POST /api/v1/irrigation/stop-all` - Stop all zones
- `GET /api/v1/irrigation/events` - List irrigation events

### Fertilizers
- `POST /api/v1/fertilizers` - Create fertilizer
- `GET /api/v1/fertilizers` - List fertilizers
- `POST /api/v1/fertilizers/applications` - Record application
- `GET /api/v1/fertilizers/applications/list` - List applications

### Treatments
- `POST /api/v1/treatments` - Create treatment
- `GET /api/v1/treatments` - List treatments
- `PUT /api/v1/treatments/:id` - Update treatment
- `DELETE /api/v1/treatments/:id` - Delete treatment

### Inventory
- `POST /api/v1/inventory` - Add inventory item
- `GET /api/v1/inventory` - List inventory
- `GET /api/v1/inventory/low-stock` - Get low stock items
- `PUT /api/v1/inventory/:id/adjust` - Adjust stock level

### Activities
- `POST /api/v1/activities` - Log activity
- `GET /api/v1/activities` - List activities
- `PUT /api/v1/activities/:id` - Update activity
- `DELETE /api/v1/activities/:id` - Delete activity

### Alerts
- `GET /api/v1/alerts` - List alerts
- `GET /api/v1/alerts/unread-count` - Get unread count
- `PUT /api/v1/alerts/:id/read` - Mark as read
- `PUT /api/v1/alerts/:id/acknowledge` - Acknowledge alert
- `PUT /api/v1/alerts/mark-all-read` - Mark all as read

### Schedules
- `POST /api/v1/schedules` - Create schedule
- `GET /api/v1/schedules` - List schedules
- `GET /api/v1/schedules/upcoming` - Get upcoming schedules
- `PUT /api/v1/schedules/:id` - Update schedule
- `DELETE /api/v1/schedules/:id` - Delete schedule

### Analytics
- `GET /api/v1/analytics/dashboard` - Get dashboard stats
- `GET /api/v1/analytics/fields/:fieldId/stats` - Get field statistics
- `GET /api/v1/analytics/crop-health` - Get crop health overview

## Database Migrations

### Create a new migration
```bash
npm run migration:generate -- src/database/migrations/MigrationName
```

### Run migrations
```bash
npm run migration:run
```

### Revert last migration
```bash
npm run migration:revert
```

## Project Structure

```
src/
├── activities/          # Activity logging module
├── alerts/             # Alert system module
├── analytics/          # Analytics and reporting
├── auth/               # Authentication & authorization
├── common/             # Shared utilities, DTOs, entities
├── crops/              # Crop management
├── database/           # Database config, migrations, seeds
├── fertilizers/        # Fertilizer management
├── fields/             # Field management
├── inventory/          # Inventory tracking
├── irrigation/         # Irrigation system
├── schedules/          # Scheduling system
├── treatments/         # Treatment tracking
├── users/              # User management
├── app.module.ts       # Root module
└── main.ts            # Application entry point
```

## Security Features

- JWT-based authentication
- Password hashing with bcrypt
- Input validation and sanitization
- CORS configuration
- Soft deletes for data recovery
- User-scoped data access

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

MIT
