import { MigrationInterface, QueryRunner } from 'typeorm';

export class AddLatLngToFields1790000000000 implements MigrationInterface {
  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE "fields" ADD COLUMN IF NOT EXISTS "latitude" DECIMAL(10,7)`,
    );
    await queryRunner.query(
      `ALTER TABLE "fields" ADD COLUMN IF NOT EXISTS "longitude" DECIMAL(10,7)`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE "fields" DROP COLUMN IF EXISTS "latitude"`);
    await queryRunner.query(`ALTER TABLE "fields" DROP COLUMN IF EXISTS "longitude"`);
  }
}
