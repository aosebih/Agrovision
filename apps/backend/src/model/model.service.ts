// model.service.ts
import {
  Injectable,
  OnModuleInit,
  Logger,
  InternalServerErrorException,
} from '@nestjs/common';
import * as tf from '@tensorflow/tfjs-node';
import * as path from 'path';
import * as fs from 'fs';
import sharp from 'sharp';

const CLASSES = ['angular_leaf_spot', 'bean_rust', 'healthy'] as const;
type BeanClass = (typeof CLASSES)[number];
const INPUT_SIZE = 224;

export interface InferenceResult {
  label: BeanClass;
  confidence: number;
  probabilities: Record<BeanClass, number>;
}

const DISEASE_INFO = {
  healthy: {
    nameAr: 'سليم',
    nameEn: 'Healthy',
    isHealthy: true,
    severity: 'none',
    description:
      'The bean plant appears healthy with no visible signs of disease or pest damage.',
    symptoms: [],
    causes: [],
    treatments: ['No treatment required.'],
    prevention: [
      'Rotate crops every season',
      'Use certified disease-free seeds',
      'Maintain adequate plant spacing for airflow',
    ],
    economicImpact: 'No yield loss expected.',
  },
  bean_rust: {
    nameAr: 'صدأ الفاصولياء',
    nameEn: 'Bean Rust',
    isHealthy: false,
    severity: 'severe',
    description:
      'Bean rust is caused by the fungus Uromyces appendiculatus. It spreads rapidly under warm, humid conditions and can cause yield losses of up to 40%.',
    symptoms: [
      'Reddish-brown pustules on the underside of leaves',
      'Yellow or pale green spots on upper leaf surface',
      'Premature leaf drop in severe cases',
      'Rust-coloured pustules on infected pods',
    ],
    causes: [
      'Fungus: Uromyces appendiculatus',
      'Favoured by temperatures 17–27°C with high humidity',
      'Spread by wind-borne spores from infected plants',
    ],
    treatments: [
      'Apply Mancozeb (2 g/L) or Chlorothalonil (2 mL/L) at first sign',
      'Repeat spray every 7–14 days under high disease pressure',
      'Triazole fungicides (Tebuconazole) for systemic control',
      'Remove and destroy heavily infected plant material',
    ],
    prevention: [
      'Plant rust-resistant varieties',
      'Avoid overhead irrigation; use drip irrigation',
      'Ensure proper plant spacing (30–40 cm)',
      'Destroy crop debris after harvest',
    ],
    economicImpact:
      'Can reduce yield by 20–40% in susceptible varieties. Early intervention is critical.',
  },
  angular_leaf_spot: {
    nameAr: 'تبقع الأوراق الزاوي',
    nameEn: 'Angular Leaf Spot',
    isHealthy: false,
    severity: 'moderate',
    description:
      'Angular leaf spot is caused by Pseudocercospora griseola. Lesions are limited by leaf veins giving them a distinctive angular shape. Yield losses can reach 80%.',
    symptoms: [
      'Angular, water-soaked lesions delimited by leaf veins',
      'Lesions turn grey-brown with a darker border on drying',
      'White to grey sporulation on underside of lesions',
      'Defoliation of heavily infected leaves',
      'Dark sunken lesions on pods and stems',
    ],
    causes: [
      'Fungus: Pseudocercospora griseola',
      'Favoured by temperatures 16–28°C with high humidity',
      'Spread by rain splash and contaminated seed',
    ],
    treatments: [
      'Foliar spray with Mancozeb (2 g/L) every 10–14 days',
      'Copper oxychloride (3 g/L) is effective',
      'Remove and burn infected leaves and debris',
      'Avoid working in fields when plants are wet',
    ],
    prevention: [
      'Use certified, disease-free seed',
      'Plant resistant varieties where available',
      'Practice 2–3 year crop rotation with non-legume crops',
      'Apply copper-based seed treatment before sowing',
    ],
    economicImpact:
      'Yield losses range from 20% in mild infections to 80% in severe epidemics.',
  },
} as const;

@Injectable()
export class ModelService implements OnModuleInit {
  private readonly logger = new Logger(ModelService.name);
  private model: tf.GraphModel | tf.LayersModel | null = null;

  async onModuleInit() {
    await this.loadModel();
  }

  private async loadModel(): Promise<void> {
    const modelPath = path.resolve(__dirname, 'bean_dynamic.tflite');
    const fallbackPath = path.resolve(
      process.cwd(),
      'models',
      'bean_dynamic.tflite',
    );
    const resolvedPath = fs.existsSync(modelPath) ? modelPath : fallbackPath;

    if (!fs.existsSync(resolvedPath)) {
      this.logger.error(`Model not found at ${modelPath} or ${fallbackPath}`);
      return;
    }

    try {
      // Convert TFLite to TensorFlow.js format first, or use TFLite extension
      // For now, we'll assume you have the model in SavedModel or H5 format
      // Or use: https://github.com/tensorflow/tfjs/tree/master/tfjs-tflite

      this.model = await tf.loadGraphModel(
        `file://${resolvedPath.replace('.tflite', '/model.json')}`,
      );
      this.logger.log(`Model loaded from ${resolvedPath}`);
    } catch (err) {
      this.logger.error('Failed to load model', err);
      throw new InternalServerErrorException('Model loading failed');
    }
  }

  private async preprocessImage(buffer: Buffer): Promise<tf.Tensor> {
    const { data, info } = await sharp(buffer)
      .resize(INPUT_SIZE, INPUT_SIZE, { fit: 'cover' })
      .removeAlpha()
      .raw()
      .toBuffer({ resolveWithObject: true });

    const normalized = new Float32Array(data.length);
    for (let i = 0; i < data.length; i++) {
      normalized[i] = data[i] / 255.0;
    }

    const tensor = tf
      .tensor3d(Array.from(normalized), [INPUT_SIZE, INPUT_SIZE, 3], 'float32')
      .expandDims(0);

    return tensor;
  }

  async predict(imageBuffer: Buffer): Promise<InferenceResult> {
    if (!this.model) {
      throw new InternalServerErrorException('Model not loaded');
    }

    const inputTensor = await this.preprocessImage(imageBuffer);
    const outputTensor = this.model.predict(inputTensor) as tf.Tensor;
    const scores = await outputTensor.data();

    inputTensor.dispose();
    outputTensor.dispose();

    const probabilities = {} as Record<BeanClass, number>;
    CLASSES.forEach((cls, i) => {
      probabilities[cls] = scores[i];
    });

    let bestIdx = 0;
    for (let i = 1; i < scores.length; i++) {
      if (scores[i] > scores[bestIdx]) bestIdx = i;
    }

    return {
      label: CLASSES[bestIdx],
      confidence: scores[bestIdx],
      probabilities,
    };
  }

  async analyzeImage(buffer: Buffer, cropType?: string) {
    const prediction = await this.predict(buffer);
    const info = DISEASE_INFO[prediction.label];

    return {
      isHealthy: info.isHealthy,
      disease: info.isHealthy ? null : info.nameEn,
      confidence: prediction.confidence,
      label: prediction.label,
      diseaseNameAr: info.nameAr,
      diseaseNameEn: info.nameEn,
      severity: info.severity,
      description: info.description,
      symptoms: [...info.symptoms],
      causes: [...info.causes],
      treatments: [...info.treatments],
      prevention: [...info.prevention],
      economicImpact: info.economicImpact,
      probabilities: prediction.probabilities,
      cropType: cropType ?? null,
      analysedAt: new Date().toISOString(),
    };
  }
}
