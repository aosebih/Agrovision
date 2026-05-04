import { MigrationInterface, QueryRunner } from "typeorm";

export class AddSettingsColumnsToUsers1777855909182 implements MigrationInterface {
    name = 'AddSettingsColumnsToUsers1777855909182'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "users" ADD "notificationsEnabled" boolean NOT NULL DEFAULT true`);
        await queryRunner.query(`ALTER TABLE "users" ADD "weatherAlerts" boolean NOT NULL DEFAULT true`);
        await queryRunner.query(`ALTER TABLE "users" ADD "storageAlerts" boolean NOT NULL DEFAULT false`);
        await queryRunner.query(`ALTER TABLE "users" ADD "darkMode" boolean NOT NULL DEFAULT false`);
        await queryRunner.query(`ALTER TABLE "users" ADD "language" character varying NOT NULL DEFAULT 'ar'`);
        await queryRunner.query(`ALTER TABLE "users" ADD "location" character varying`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "location"`);
        await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "language"`);
        await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "darkMode"`);
        await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "storageAlerts"`);
        await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "weatherAlerts"`);
        await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "notificationsEnabled"`);
    }

}
