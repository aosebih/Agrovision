import { Injectable, NestInterceptor, ExecutionContext, CallHandler } from '@nestjs/common';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';

export interface Response<T> {
  data: T;
}

@Injectable()
export class TransformInterceptor<T> implements NestInterceptor<T, Response<T>> {
  intercept(context: ExecutionContext, next: CallHandler): Observable<Response<T>> {
    return next.handle().pipe(
      map((data) => {
        // Remove password field from user objects
        if (data && typeof data === 'object') {
          this.removePasswordFields(data);
        }
        return data;
      }),
    );
  }

  private removePasswordFields(obj: any): void {
    if (Array.isArray(obj)) {
      obj.forEach((item) => this.removePasswordFields(item));
    } else if (obj && typeof obj === 'object') {
      if ('password' in obj) {
        delete obj.password;
      }
      Object.values(obj).forEach((value) => {
        if (value && typeof value === 'object') {
          this.removePasswordFields(value);
        }
      });
    }
  }
}
