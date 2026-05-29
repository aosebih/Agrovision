import {
  Controller,
  Post,
  Get,
  UploadedFile,
  UseInterceptors,
  Body,
  BadRequestException,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { memoryStorage } from 'multer';
import { ModelService } from './model.service';

@Controller('model')
export class ModelController {
  constructor(private readonly modelService: ModelService) {}

  /**
   * POST /model/analyze
   * Form-data:
   *   image    : File   (required) JPEG / PNG / WebP
   *   cropType : string (optional)
   */
  @Post('analyze')
  @HttpCode(HttpStatus.OK)
  @UseInterceptors(
    FileInterceptor('image', {
      storage: memoryStorage(),
      limits: { fileSize: 10 * 1024 * 1024 }, // 10 MB
      fileFilter: (_req, file, cb) => {
        const allowed = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'];
        if (allowed.includes(file.mimetype)) {
          cb(null, true);
        } else {
          cb(
            new BadRequestException(
              'Only JPEG, PNG and WebP images are accepted',
            ),
            false,
          );
        }
      },
    }),
  )
  async analyze(
    @UploadedFile() file: Express.Multer.File,
    @Body('cropType') cropType?: string,
  ) {
    if (!file) {
      throw new BadRequestException(
        'No image provided. Send form-data with key "image".',
      );
    }

    const result = await this.modelService.analyzeImage(file.buffer, cropType);

    return { success: true, data: result };
  }

  /** GET /model/health — quick ping */
  @Get('health')
  health() {
    return { status: 'ok', timestamp: new Date().toISOString() };
  }
}
