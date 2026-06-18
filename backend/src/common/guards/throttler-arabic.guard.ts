import { Injectable } from '@nestjs/common';
import { ThrottlerGuard } from '@nestjs/throttler';

@Injectable()
export class ThrottlerArabicGuard extends ThrottlerGuard {
  protected errorMessage = 'طلبات كثيرة جداً. الرجاء المحاولة بعد 60 ثانية';
}
