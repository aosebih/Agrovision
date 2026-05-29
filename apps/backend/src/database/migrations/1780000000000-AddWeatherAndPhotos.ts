import { MigrationInterface, QueryRunner } from 'typeorm';

export class AddWeatherAndPhotos1780000000000 implements MigrationInterface {
  public async up(queryRunner: QueryRunner): Promise<void> {
    // field_photos table
    await queryRunner.query(`
      CREATE TABLE IF NOT EXISTS "field_photos" (
        "id"          UUID        NOT NULL DEFAULT uuid_generate_v4(),
        "created_at"  TIMESTAMPTZ NOT NULL DEFAULT now(),
        "updated_at"  TIMESTAMPTZ NOT NULL DEFAULT now(),
        "deleted_at"  TIMESTAMPTZ,
        "field_id"    UUID        NOT NULL,
        "user_id"     UUID        NOT NULL,
        "url"         TEXT        NOT NULL,
        "caption"     TEXT,
        "captured_at" TIMESTAMPTZ NOT NULL DEFAULT now(),
        CONSTRAINT "PK_field_photos" PRIMARY KEY ("id")
      )
    `);
    // language column if not present
    await queryRunner.query(
      `ALTER TABLE "users" ADD COLUMN IF NOT EXISTS "language" VARCHAR(5) NOT NULL DEFAULT 'ar'`,
    );
    await queryRunner.query(
      `ALTER TABLE "users" ADD COLUMN IF NOT EXISTS "location" VARCHAR(255)`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP TABLE IF EXISTS "field_photos"`);
  }
}
