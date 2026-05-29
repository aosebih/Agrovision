// src/chat/chat.service.ts
import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';

// ── Minimal knowledge base (mirrors the Python RAG KB) ───────────────────────
const KNOWLEDGE_BASE = [
  { keywords: ['rice', 'أرز'], text: 'Rice requires 200-250 mm water monthly. Temperature: 20-35°C. pH: 5.5-7.0. NPK: 120:60:60 kg/ha.' },
  { keywords: ['maize', 'corn', 'ذرة'], text: 'Maize requires 80-100 mm water monthly. Temperature: 18-30°C. pH: 5.5-7.5. NPK: 150:60:40 kg/ha.' },
  { keywords: ['blast', 'بلاست', 'صدأ أرز'], text: 'Rice blast: spindle-shaped lesions on leaves. Control: resistant varieties, avoid excess nitrogen, apply tricyclazole.' },
  { keywords: ['bean rust', 'صدأ فاصولياء', 'فاصولياء'], text: 'Bean rust caused by Uromyces appendiculatus. Apply Mancozeb 2g/L or Chlorothalonil 2ml/L. Repeat every 7-14 days.' },
  { keywords: ['angular leaf', 'تبقع', 'زاوي'], text: 'Angular leaf spot caused by Pseudocercospora griseola. Spray Mancozeb 2g/L every 10-14 days. Use copper oxychloride 3g/L.' },
  { keywords: ['ph', 'تربة', 'soil', 'حموضة'], text: 'pH below 5.5: add lime 2-5 tons/ha. pH above 7.5: add sulfur or organic matter.' },
  { keywords: ['nitrogen', 'نيتروجين', 'يوريا', 'urea'], text: 'Nitrogen promotes vegetative growth. Urea (46-0-0): 100-150 kg/ha for cereals. Split application recommended.' },
  { keywords: ['irrigation', 'ري', 'water', 'مياه'], text: 'Rice: maintain 5cm standing water. Alternate wetting and drying (AWD) saves 30% water. Irrigate cereals at critical growth stages.' },
  { keywords: ['wheat', 'قمح'], text: 'Wheat requires 450-650 mm water per season. Temperature: 15-24°C. NPK: 120:60:40 kg/ha. Irrigate at tillering and grain fill.' },
  { keywords: ['fertilizer', 'سماد', 'تسميد', 'npk'], text: 'NPK application: apply phosphorus at planting, split nitrogen into 2-3 doses, potassium improves drought resistance and root strength.' },
];

function retrieveContext(question: string): string {
  const q = question.toLowerCase();
  const matched = KNOWLEDGE_BASE.filter(({ keywords }) =>
    keywords.some((kw) => q.includes(kw.toLowerCase())),
  );
  if (matched.length === 0) return '';
  return matched.map((m) => m.text).join('\n');
}

@Injectable()
export class ChatService {
  private readonly logger = new Logger(ChatService.name);

  constructor(
    private readonly config: ConfigService,
    private readonly http: HttpService,
  ) {}

  async ask(question: string): Promise<{
    answer: string;
    success: boolean;
    confidence: number | null;
    sources: string[];
    timestamp: string;
  }> {
    const apiKey = this.config.get<string>('GEMINI_API_KEY');
    const context = retrieveContext(question);
    const hasContext = context.length > 0;

    const systemPrompt = hasContext
      ? `أنت مساعد زراعي خبير. أجب بناءً على هذا السياق فقط:\n\n${context}\n\nإذا لم يكن السياق كافياً، قل "لا أملك معلومات كافية". كن مختصراً وعملياً (3-5 أسطر).`
      : `أنت مساعد زراعي خبير متخصص في الزراعة الجزائرية. أجب باللغة العربية بأسلوب واضح وعملي. إذا لم تعرف الإجابة، قل ذلك صراحةً. كن مختصراً (3-5 أسطر).`;

    const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${apiKey}`;

    try {
      const { data } = await firstValueFrom(
        this.http.post(url, {
          // FIX: system prompt must be in system_instruction, not mixed into contents
          system_instruction: {
            parts: [{ text: systemPrompt }],
          },
          contents: [
            {
              role: 'user',
              parts: [{ text: question }],
            },
          ],
          generationConfig: { temperature: 0.3, maxOutputTokens: 1024 },
        }),
      );

      const answer: string =
        data?.candidates?.[0]?.content?.parts?.[0]?.text ?? '';

      if (!answer) {
        return this._fallback(question);
      }

      return {
        answer,
        success: true,
        confidence: hasContext ? 0.85 : 0.5,
        sources: hasContext ? ['knowledge_base'] : [],
        timestamp: new Date().toISOString(),
      };
    } catch (err) {
      // FIX: log the full Gemini error response body, not just err.message
      const e = err as { response?: { data?: unknown }; message?: string };
      this.logger.error(
        'Gemini API error',
        JSON.stringify(e?.response?.data ?? e?.message ?? err),
      );
      return this._fallback(question);
    }
  }

  private _fallback(question: string) {
    const q = question.toLowerCase();
    let answer: string;

    if (q.includes('صدأ') || q.includes('بقع') || q.includes('مرض') || q.includes('blast')) {
      answer = 'لتشخيص أمراض المحاصيل، استخدم كاميرا التطبيق لتحليل الصورة.\nللعلاج العام: أزل الأجزاء المصابة، رش مبيد فطري (Mancozeb 2g/L)، وحسّن تهوية الحقل.';
    } else if (q.includes('ري') || q.includes('مياه') || q.includes('water')) {
      answer = 'توصيات الري:\n• اسقِ في الصباح الباكر لتقليل التبخر\n• تجنب الري عند الظهيرة\n• راقب رطوبة التربة قبل الري\n• استخدم الري بالتنقيط لتوفير المياه';
    } else if (q.includes('سماد') || q.includes('نيتروجين') || q.includes('npk')) {
      answer = 'نصائح التسميد:\n• أضف سماداً نيتروجينياً في مرحلة النمو الخضري\n• استخدم الفوسفور عند الزراعة\n• أضف البوتاسيوم لتقوية الجذور';
    } else if (q.includes('تربة') || q.includes('ph')) {
      answer = 'لتحسين صحة التربة:\n• أضف كمبوست أو سماد عضوي\n• اعتمد تناوب المحاصيل كل موسم\n• pH مثالي: 6.0-7.0 لمعظم المحاصيل';
    } else {
      answer = 'اكتب سؤالك بوضوح حول: أمراض المحاصيل، الري، التسميد، أو صحة التربة وسأساعدك.';
    }

    return {
      answer,
      success: true,
      confidence: null,
      sources: [],
      timestamp: new Date().toISOString(),
    };
  }
}