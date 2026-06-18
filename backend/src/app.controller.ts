import { Controller, Get } from '@nestjs/common';
import { ApiTags, ApiOperation } from '@nestjs/swagger';

@ApiTags('Health')
@Controller()
export class AppController {
  @Get('health')
  @ApiOperation({ summary: 'فحص صحة الخادم' })
  getHealth() {
    return { status: 'ok', timestamp: new Date().toISOString(), version: '1.0.0' };
  }
}
