# Implementation Plan

## Phase 1: Bug Condition Exploration Tests

- [ ] 1. Write bug condition exploration tests for all 9 compilation issues
  - **Property 1: Bug Condition** - Compilation Failures on Unfixed Code
  - **CRITICAL**: These tests MUST FAIL on unfixed code - failure confirms the bugs exist
  - **DO NOT attempt to fix the tests or the code when they fail**
  - **NOTE**: These tests encode the expected behavior - they will validate the fixes when they pass after implementation
  - **GOAL**: Surface counterexamples that demonstrate each bug exists
  - Test 1.1: Verify compilation fails with "Cannot find module './auth.service'" in auth.controller.ts
  - Test 1.2: Verify compilation fails with "Cannot find module './auth/auth.module'" in app.module.ts
  - Test 1.3: Verify compilation fails due to missing packages (@nestjs/typeorm, @nestjs/passport, @nestjs/jwt, @nestjs/config, typeorm, pg, passport, passport-jwt, passport-local, bcryptjs, class-validator, class-transformer)
  - Test 1.4: Verify compilation fails with "Cannot find module './schudules.service'" in schedules.module.ts
  - Test 1.5: Verify compilation fails with "Cannot find module './irrigatio.controller'" in irrigation.module.ts
  - Test 1.6: Verify compilation fails with "Cannot find module './irrigation-zone.entity'" and "Cannot find module './irrigation-event.entity'"
  - Test 1.7: Verify compilation fails with "Cannot find module './users/users.module'" in app.module.ts
  - Test 1.8: Verify duplicate local.strategy.ts files exist in both src/auth/ and src/auth/strategies/
  - Test 1.9: Verify TypeScript warnings about missing @types packages for bcryptjs, passport-jwt, passport-local
  - Run tests on UNFIXED code
  - **EXPECTED OUTCOME**: Tests FAIL (this is correct - it proves the bugs exist)
  - Document counterexamples found to understand root causes
  - Mark task complete when tests are written, run, and failures are documented
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9_

## Phase 2: Preservation Property Tests

- [ ] 2. Write preservation property tests (BEFORE implementing fixes)
  - **Property 2: Preservation** - Existing Functionality Unchanged
  - **IMPORTANT**: Follow observation-first methodology
  - Since unfixed code doesn't compile, preservation will be verified by:
    - Documenting all existing files that should NOT be modified (except the 9 specific fixes)
    - Creating checksums or snapshots of unaffected files
    - Preparing tests to run after fixes are applied
  - Test 2.1: Verify all existing module files (fields, crops, fertilizers, inventory, alerts, activities, treatments, schedules, analytics) remain unchanged
  - Test 2.2: Verify all existing entity definitions remain unchanged (User, Field, Crop, etc.)
  - Test 2.3: Verify main.ts configuration (validation pipe, CORS, API prefix) remains unchanged
  - Test 2.4: Verify database configuration in data-source.ts remains unchanged
  - Test 2.5: Verify users.service.ts password hashing logic remains unchanged
  - Test 2.6: Verify existing strategy files (jwt.strategy.ts, jwt-auth.guard.ts) remain unchanged
  - Test 2.7: Verify TypeScript configurations (tsconfig.json, tsconfig.build.json) remain unchanged
  - Test 2.8: Verify linting rules (eslint.config.mjs) remain unchanged
  - Document baseline state of all unaffected files
  - **EXPECTED OUTCOME**: Baseline documented for comparison after fixes
  - Mark task complete when preservation tests are prepared
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 3.8_

## Phase 3: Implementation

### Fix 1: Create AuthService

- [ ] 3. Implement AuthService
  
  - [ ] 3.1 Create src/auth/auth.service.ts
    - Create AuthService class with @Injectable() decorator
    - Inject UsersService and JwtService in constructor
    - Implement register(createUserDto: CreateUserDto) method:
      - Delegate to UsersService.create()
      - Return user object without password field
    - Implement login(loginDto: LoginDto) method:
      - Validate credentials using validateUser()
      - Generate JWT token with payload { sub: user.id, email: user.email }
      - Return { access_token: string }
    - Implement validateUser(email: string, password: string) method:
      - Use UsersService.findByEmail()
      - Compare password with bcrypt.compare()
      - Return user without password if valid, null otherwise
    - _Bug_Condition: isBugCondition(input) where input.type == 'import' AND input.targetFile == 'auth.service.ts' NOT EXISTS_
    - _Expected_Behavior: AuthService exists and provides register(), login(), validateUser() methods_
    - _Preservation: All existing service implementations remain unchanged_
    - _Requirements: 1.1, 2.1, 3.1_

  - [ ] 3.2 Verify bug condition exploration test 1.1 now passes
    - **Property 1: Expected Behavior** - AuthService Import Resolves
    - **IMPORTANT**: Re-run the SAME test from task 1 - do NOT write a new test
    - Run compilation test for auth.controller.ts importing AuthService
    - **EXPECTED OUTCOME**: Test PASSES (confirms AuthService is found)
    - _Requirements: 2.1_

### Fix 2: Create AuthModule

- [ ] 4. Implement AuthModule

  - [ ] 4.1 Create src/auth/auth.module.ts
    - Create AuthModule class with @Module() decorator
    - Import UsersModule
    - Import PassportModule
    - Import JwtModule.registerAsync() with ConfigService:
      - Inject ConfigService
      - Use JWT_SECRET from environment
      - Set expiresIn to '1d'
    - Declare providers: [AuthService, LocalStrategy, JwtStrategy]
    - Declare controllers: [AuthController]
    - Export AuthService
    - _Bug_Condition: isBugCondition(input) where input.type == 'import' AND input.targetFile == 'auth.module.ts' NOT EXISTS_
    - _Expected_Behavior: AuthModule exists and configures authentication with Passport and JWT_
    - _Preservation: All existing module configurations remain unchanged_
    - _Requirements: 1.2, 2.2, 3.1_

  - [ ] 4.2 Verify bug condition exploration test 1.2 now passes
    - **Property 1: Expected Behavior** - AuthModule Import Resolves
    - **IMPORTANT**: Re-run the SAME test from task 1 - do NOT write a new test
    - Run compilation test for app.module.ts importing AuthModule
    - **EXPECTED OUTCOME**: Test PASSES (confirms AuthModule is found)
    - _Requirements: 2.2_

### Fix 3: Add Missing Dependencies

- [ ] 5. Add missing dependencies to package.json

  - [ ] 5.1 Update package.json with runtime dependencies
    - Add to dependencies:
      - "@nestjs/typeorm": "^10.0.1"
      - "@nestjs/passport": "^10.0.3"
      - "@nestjs/jwt": "^10.2.0"
      - "@nestjs/config": "^3.1.1"
      - "typeorm": "^0.3.19"
      - "pg": "^8.11.3"
      - "passport": "^0.7.0"
      - "passport-jwt": "^4.0.1"
      - "passport-local": "^1.0.0"
      - "bcryptjs": "^2.4.3"
      - "class-validator": "^0.14.0"
      - "class-transformer": "^0.5.1"
    - Add to devDependencies:
      - "@types/bcryptjs": "^2.4.6"
      - "@types/passport-jwt": "^4.0.0"
      - "@types/passport-local": "^1.0.38"
    - Run npm install to install packages
    - _Bug_Condition: isBugCondition(input) where input.type == 'dependency' AND input.package NOT IN package.json_
    - _Expected_Behavior: All required packages present in package.json and installed_
    - _Preservation: All existing dependencies remain unchanged_
    - _Requirements: 1.3, 2.3, 2.9, 3.1_

  - [ ] 5.2 Verify bug condition exploration test 1.3 and 1.9 now pass
    - **Property 1: Expected Behavior** - All Dependencies Available
    - **IMPORTANT**: Re-run the SAME tests from task 1 - do NOT write new tests
    - Run npm install and verify no missing package errors
    - Run compilation and verify no missing dependency errors
    - Verify TypeScript recognizes types for bcryptjs, passport-jwt, passport-local
    - **EXPECTED OUTCOME**: Tests PASS (confirms all dependencies installed)
    - _Requirements: 2.3, 2.9_

### Fix 4: Rename Schedules Service

- [ ] 6. Fix schedules service filename typo

  - [ ] 6.1 Rename src/schedules/schudules.service.ts to schedules.service.ts
    - Use file system rename operation or smartRelocate tool
    - Verify schedules.module.ts imports from './schedules.service'
    - _Bug_Condition: isBugCondition(input) where input.type == 'import' AND input.targetFile HAS_TYPO_
    - _Expected_Behavior: File named schedules.service.ts matches import statement_
    - _Preservation: Service implementation remains unchanged_
    - _Requirements: 1.4, 2.4, 3.1_

  - [ ] 6.2 Verify bug condition exploration test 1.4 now passes
    - **Property 1: Expected Behavior** - Schedules Service Import Resolves
    - **IMPORTANT**: Re-run the SAME test from task 1 - do NOT write a new test
    - Run compilation test for schedules.module.ts importing SchedulesService
    - **EXPECTED OUTCOME**: Test PASSES (confirms schedules.service.ts is found)
    - _Requirements: 2.4_

### Fix 5: Rename Irrigation Controller

- [ ] 7. Fix irrigation controller filename typo

  - [ ] 7.1 Rename src/irrigation/irrigatio.controller.ts to irrigation.controller.ts
    - Use file system rename operation or smartRelocate tool
    - Verify irrigation.module.ts imports from './irrigation.controller'
    - _Bug_Condition: isBugCondition(input) where input.type == 'import' AND input.targetFile HAS_TYPO_
    - _Expected_Behavior: File named irrigation.controller.ts matches import statement_
    - _Preservation: Controller implementation remains unchanged_
    - _Requirements: 1.5, 2.5, 3.1_

  - [ ] 7.2 Verify bug condition exploration test 1.5 now passes
    - **Property 1: Expected Behavior** - Irrigation Controller Import Resolves
    - **IMPORTANT**: Re-run the SAME test from task 1 - do NOT write a new test
    - Run compilation test for irrigation.module.ts importing IrrigationController
    - **EXPECTED OUTCOME**: Test PASSES (confirms irrigation.controller.ts is found)
    - _Requirements: 2.5_

### Fix 6: Create Irrigation Entities

- [ ] 8. Create missing irrigation entities

  - [ ] 8.1 Create src/irrigation/irrigation-zone.entity.ts
    - Create IrrigationZone class extending BaseEntity
    - Add @Entity('irrigation_zones') decorator
    - Add columns:
      - @PrimaryGeneratedColumn('uuid') id: string
      - @Column() name: string
      - @Column() fieldId: string
      - @Column('decimal') flowRate: number (liters per minute)
      - @Column() schedule: string (cron expression or description)
      - @Column({ default: true }) isActive: boolean
    - Add @ManyToOne relation to Field entity if needed
    - _Bug_Condition: isBugCondition(input) where input.type == 'import' AND input.targetFile == 'irrigation-zone.entity.ts' NOT EXISTS_
    - _Expected_Behavior: IrrigationZone entity exists with proper TypeORM decorators_
    - _Preservation: All existing entity definitions remain unchanged_
    - _Requirements: 1.6, 2.6, 3.2_

  - [ ] 8.2 Create src/irrigation/irrigation-event.entity.ts
    - Create IrrigationEvent class extending BaseEntity
    - Add @Entity('irrigation_events') decorator
    - Add columns:
      - @PrimaryGeneratedColumn('uuid') id: string
      - @Column() zoneId: string
      - @Column() startTime: Date
      - @Column({ nullable: true }) endTime: Date
      - @Column() duration: number (minutes)
      - @Column('decimal') waterUsed: number (liters)
      - @Column() status: string (enum: scheduled, in_progress, completed, failed)
    - Add @ManyToOne relation to IrrigationZone entity
    - _Bug_Condition: isBugCondition(input) where input.type == 'import' AND input.targetFile == 'irrigation-event.entity.ts' NOT EXISTS_
    - _Expected_Behavior: IrrigationEvent entity exists with proper TypeORM decorators_
    - _Preservation: All existing entity definitions remain unchanged_
    - _Requirements: 1.6, 2.6, 3.2_

  - [ ] 8.3 Verify bug condition exploration test 1.6 now passes
    - **Property 1: Expected Behavior** - Irrigation Entity Imports Resolve
    - **IMPORTANT**: Re-run the SAME test from task 1 - do NOT write a new test
    - Run compilation test for irrigation.module.ts importing IrrigationZone and IrrigationEvent
    - **EXPECTED OUTCOME**: Test PASSES (confirms both entities are found)
    - _Requirements: 2.6_

### Fix 7: Create UsersModule

- [ ] 9. Implement UsersModule

  - [ ] 9.1 Create src/users/users.module.ts
    - Create UsersModule class with @Module() decorator
    - Import TypeOrmModule.forFeature([User])
    - Declare providers: [UsersService]
    - Export UsersService
    - _Bug_Condition: isBugCondition(input) where input.type == 'import' AND input.targetFile == 'users.module.ts' NOT EXISTS_
    - _Expected_Behavior: UsersModule exists and exports UsersService_
    - _Preservation: UsersService implementation remains unchanged_
    - _Requirements: 1.7, 2.7, 3.1_

  - [ ] 9.2 Verify bug condition exploration test 1.7 now passes
    - **Property 1: Expected Behavior** - UsersModule Import Resolves
    - **IMPORTANT**: Re-run the SAME test from task 1 - do NOT write a new test
    - Run compilation test for app.module.ts importing UsersModule
    - **EXPECTED OUTCOME**: Test PASSES (confirms UsersModule is found)
    - _Requirements: 2.7_

### Fix 8: Remove Duplicate LocalStrategy

- [ ] 10. Remove duplicate LocalStrategy file

  - [ ] 10.1 Delete src/auth/local.strategy.ts
    - Delete the duplicate file in src/auth/ directory
    - Keep only src/auth/strategies/local.strategy.ts
    - Verify auth.module.ts imports LocalStrategy from './strategies/local.strategy'
    - _Bug_Condition: isBugCondition(input) where input.type == 'file' AND input.hasDuplicate == true_
    - _Expected_Behavior: Only one LocalStrategy file exists in src/auth/strategies/_
    - _Preservation: LocalStrategy implementation remains unchanged_
    - _Requirements: 1.8, 2.8, 3.6_

  - [ ] 10.2 Verify bug condition exploration test 1.8 now passes
    - **Property 1: Expected Behavior** - No Duplicate LocalStrategy
    - **IMPORTANT**: Re-run the SAME test from task 1 - do NOT write a new test
    - Verify only one local.strategy.ts exists in src/auth/strategies/
    - Verify no local.strategy.ts exists in src/auth/
    - **EXPECTED OUTCOME**: Test PASSES (confirms no duplicate)
    - _Requirements: 2.8_

### Fix 9: Verify All Fixes Together

- [ ] 11. Verify all fixes work together

  - [ ] 11.1 Run full compilation test
    - Run npm install to ensure all dependencies are installed
    - Run npm run build to compile the entire application
    - Verify compilation succeeds with no errors
    - **EXPECTED OUTCOME**: Application compiles successfully
    - _Requirements: All 2.x requirements_

  - [ ] 11.2 Verify preservation tests still pass
    - **Property 2: Preservation** - Existing Functionality Unchanged
    - **IMPORTANT**: Re-run the SAME tests from task 2 - do NOT write new tests
    - Compare all unaffected files to baseline snapshots
    - Verify no modifications to existing modules, entities, configurations
    - Run existing unit tests if available
    - Test that main.ts configuration (validation, CORS, API prefix) is unchanged
    - Test that database configuration uses environment variables
    - Test that password hashing in users.service.ts is unchanged
    - **EXPECTED OUTCOME**: All preservation tests PASS (confirms no regressions)
    - _Requirements: All 3.x requirements_

## Phase 4: Final Checkpoint

- [ ] 12. Final verification and cleanup
  - Run npm run lint to verify linting rules are respected
  - Run npm run test if unit tests exist
  - Attempt to start the application with npm run start:dev
  - Verify all modules load correctly
  - Verify database connection works (if database is available)
  - Document any remaining issues or warnings
  - Ask user if any questions arise or if manual testing is needed
