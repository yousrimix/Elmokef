import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  OnGatewayConnection,
  OnGatewayDisconnect,
  OnGatewayInit,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { Logger, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';

interface AuthenticatedSocket extends Socket {
  userId?: string;
  role?: string;
}

@WebSocketGateway({
  namespace: '/orders',
  cors: { origin: '*', credentials: true },
})
export class OrdersGateway implements OnGatewayInit, OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

  private readonly logger = new Logger(OrdersGateway.name);
  private readonly connectedClients = new Map<string, AuthenticatedSocket[]>();

  constructor(private jwtService: JwtService) {}

  afterInit() {
    this.logger.log('📡 Orders WebSocket Gateway initialized');
  }

  async handleConnection(client: AuthenticatedSocket) {
    try {
      const token = this.extractToken(client);
      if (!token) {
        this.logger.warn(`Client ${client.id} — no token provided, disconnecting`);
        client.disconnect();
        return;
      }

      const payload = await this.jwtService.verifyAsync(token);
      client.userId = payload.sub;
      client.role = payload.role;

      // Join user to their personal room
      client.join(`user:${payload.sub}`);

      // Artisans join a shared room for new order broadcasts
      if (payload.role === 'ARTISAN') {
        client.join('artisans');
      }

      // Track client
      const existing = this.connectedClients.get(payload.sub) || [];
      existing.push(client);
      this.connectedClients.set(payload.sub, existing);

      this.logger.log(`🔗 Client connected: ${payload.sub} (${payload.role}) — ${client.id}`);
    } catch (err) {
      this.logger.warn(`Client ${client.id} — invalid token, disconnecting`);
      client.disconnect();
    }
  }

  handleDisconnect(client: AuthenticatedSocket) {
    if (client.userId) {
      const clients = this.connectedClients.get(client.userId) || [];
      const filtered = clients.filter((c) => c.id !== client.id);
      if (filtered.length === 0) {
        this.connectedClients.delete(client.userId);
      } else {
        this.connectedClients.set(client.userId, filtered);
      }
      this.logger.log(`🔌 Client disconnected: ${client.userId} — ${client.id}`);
    }
  }

  @SubscribeMessage('subscribe:orders')
  handleSubscribeOrders(client: AuthenticatedSocket) {
    if (client.role === 'ARTISAN') {
      client.join('artisans');
    } else {
      client.join(`user:${client.userId}`);
    }
    return { event: 'subscribed', data: { rooms: [...client.rooms] } };
  }

  /**
   * إرسال إشعار للحرفي بطلب جديد
   */
  notifyNewOrder(order: any, artisanData: any) {
    this.server.to('artisans').emit('order.created', {
      order,
      artisanData,
      timestamp: new Date().toISOString(),
    });

    // Also send to the specific artisan's personal room
    this.server.to(`user:${order.artisanId}`).emit('order.created', {
      order,
      artisanData,
      timestamp: new Date().toISOString(),
    });
  }

  /**
   * إرسال إشعار للعميل بتحديث حالة الطلب
   */
  notifyOrderUpdated(order: any) {
    this.server.to(`user:${order.clientId}`).emit('order.updated', {
      order,
      timestamp: new Date().toISOString(),
    });
  }

  /**
   * إرسال إشعار لكلا الطرفين
   */
  notifyBoth(order: any) {
    this.server.to(`user:${order.artisanId}`).emit('order.updated', {
      order,
      timestamp: new Date().toISOString(),
    });
    this.server.to(`user:${order.clientId}`).emit('order.updated', {
      order,
      timestamp: new Date().toISOString(),
    });
  }

  private extractToken(client: AuthenticatedSocket): string | null {
    const authHeader = client.handshake.headers.authorization;
    if (authHeader && authHeader.startsWith('Bearer ')) {
      return authHeader.substring(7);
    }
    const token = client.handshake.query?.token as string;
    return token || null;
  }
}
