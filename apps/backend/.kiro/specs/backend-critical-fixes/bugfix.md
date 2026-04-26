# Bugfix Requirements Document

## Introduction

This document addresses multiple critical issues preventing the NestJS-based farmer's helper backend application from compiling and running. The application manages fields, crops, irrigation, fertilizers, inventory, alerts, activities, treatments, schedules, and analytics. The issues include missing service and module files, missing dependencies, file naming typos, and missing entity files.

## Bug Analysis

### Current Behavior (Defect)

1.1 WHEN the application attempts to compile THEN the build fails because auth.controller.ts imports AuthService from a non-existent auth.service.ts file

1.2 WHEN the application attempts to compile THEN the build fails because app.module.ts imports AuthModule from a non-existent auth.module.ts file

1.3 WHEN the application attempts to install dependencies THEN critical packages are missing from package.json: @nestjs/typeorm, @nestjs/passport, @nestjs/jwt, @nestjs/config, typeorm, pg, passport, passport-jwt, passport-local, bcryptjs, class-validator, class-transformer

1.4 WHEN the application attempts to compile THEN the build fails because schedules.module.ts imports from schudules.service.ts (typo) instead of schedules.service.ts

1.5 WHEN the application attempts to compile THEN the build fails because irrigation.module.ts imports from irrigatio.controller.ts (typo) instead of irrigation.controller.ts

1.6 WHEN the application attempts to compile THEN the build fails because irrigation module imports non-existent irrigation-zone.entity.ts and irrigation-event.entity.ts files

1.7 WHEN the application attempts to compile THEN the build fails because app.module.ts imports UsersModule from a non-existent users.module.ts file

1.8 WHEN the application attempts to compile THEN there are duplicate local.strategy.ts files in both src/auth/ and src/auth/strategies/ causing potential conflicts

1.9 WHEN the application attempts to install TypeScript dependencies THEN @types packages are missing for bcryptjs, passport-jwt, and passport-local

### Expected Behavior (Correct)

2.1 WHEN the application attempts to compile THEN auth.service.ts SHALL exist and provide authentication methods (register, login, validateUser)

2.2 WHEN the application attempts to compile THEN auth.module.ts SHALL exist and properly configure the AuthModule with required imports and providers

2.3 WHEN the application attempts to install dependencies THEN package.json SHALL include all required packages: @nestjs/typeorm, @nestjs/passport, @nestjs/jwt, @nestjs/config, typeorm, pg, passport, passport-jwt, passport-local, bcryptjs, class-validator, class-transformer

2.4 WHEN the application attempts to compile THEN src/schedules/schudules.service.ts SHALL be renamed to src/schedules/schedules.service.ts

2.5 WHEN the application attempts to compile THEN src/irrigation/irrigatio.controller.ts SHALL be renamed to src/irrigation/irrigation.controller.ts

2.6 WHEN the application attempts to compile THEN irrigation-zone.entity.ts and irrigation-event.entity.ts SHALL exist in src/irrigation/ directory

2.7 WHEN the application attempts to compile THEN users.module.ts SHALL exist and properly configure the UsersModule

2.8 WHEN the application attempts to compile THEN the duplicate local.strategy.ts file in src/auth/ SHALL be removed, keeping only the one in src/auth/strategies/

2.9 WHEN the application attempts to install TypeScript dependencies THEN package.json SHALL include @types/bcryptjs, @types/passport-jwt, and @types/passport-local in devDependencies

### Unchanged Behavior (Regression Prevention)

3.1 WHEN the application runs THEN all existing module functionality (fields, crops, fertilizers, irrigation, inventory, alerts, activities, treatments, schedules, analytics) SHALL CONTINUE TO work as before

3.2 WHEN the application compiles THEN all existing entity definitions SHALL CONTINUE TO be recognized by TypeORM

3.3 WHEN the application starts THEN the global validation pipe and CORS configuration SHALL CONTINUE TO be applied

3.4 WHEN the application connects to the database THEN the TypeORM configuration SHALL CONTINUE TO use environment variables for connection settings

3.5 WHEN users are created THEN password hashing with bcryptjs SHALL CONTINUE TO work as implemented in users.service.ts

3.6 WHEN authentication guards are applied THEN JWT and local strategies SHALL CONTINUE TO protect routes as intended

3.7 WHEN the application runs THEN the API prefix 'api/v1' SHALL CONTINUE TO be applied to all routes

3.8 WHEN the application builds THEN all existing TypeScript configurations and linting rules SHALL CONTINUE TO be respected
