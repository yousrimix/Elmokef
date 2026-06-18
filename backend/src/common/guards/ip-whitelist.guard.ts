import { Injectable, CanActivate, ExecutionContext, ForbiddenException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class IpWhitelistGuard implements CanActivate {
  private allowedIps: string[];

  constructor(private config: ConfigService) {
    const raw = this.config.get('CMI_IPS', '');
    this.allowedIps = raw ? raw.split(',').map((s: string) => s.trim()) : [];
  }

  canActivate(context: ExecutionContext): boolean {
    if (this.config.get('NODE_ENV') === 'development') return true;
    if (this.allowedIps.length === 0) return true;

    const request = context.switchToHttp().getRequest();
    const ip = request.ip || request.connection?.remoteAddress;

    if (!ip || !this.allowedIps.includes(ip)) {
      throw new ForbiddenException('IP غير مسموح به');
    }
    return true;
  }
}
