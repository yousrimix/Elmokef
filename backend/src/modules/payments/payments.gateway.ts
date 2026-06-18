import { WebSocketGateway, WebSocketServer, SubscribeMessage, OnGatewayConnection, OnGatewayDisconnect } from '@nestjs/websockets';
import { Logger } from '@nestjs/common';
import { Server, Socket } from 'socket.io';

const IDLE_TIMEOUT_MS = 30_000;

@WebSocketGateway({
  namespace: '/ws/payments',
  cors: { origin: '*', credentials: true },
  transports: ['websocket', 'polling'],
})
export class PaymentsGateway implements OnGatewayConnection, OnGatewayDisconnect {
  private readonly logger = new Logger(PaymentsGateway.name);

  @WebSocketServer()
  server: Server;

  private clientPayments = new Map<string, string>();
  private idleTimers = new Map<string, NodeJS.Timeout>();

  handleConnection(client: Socket) {
    const paymentId = client.handshake.query.paymentId as string;
    if (paymentId) {
      const room = `payment:${paymentId}`;
      this.clientPayments.set(client.id, paymentId);
      client.join(room);
      this.logger.log(`WebSocket connected: client=${client.id}, paymentId=${paymentId}, room=${room}`);
    }
    this._resetIdleTimer(client);
  }

  handleDisconnect(client: Socket) {
    this.clientPayments.delete(client.id);
    this._clearIdleTimer(client.id);
    this.logger.log(`WebSocket disconnected: client=${client.id}`);
  }

  notifyPaymentConfirmed(paymentId: string) {
    const room = `payment:${paymentId}`;
    this.server.to(room).emit('payment:confirmed', {
      event: 'payment:confirmed',
      paymentId,
      status: 'COMPLETED',
      timestamp: new Date().toISOString(),
    });
    this.logger.log(`Payment confirmed emitted to room=${room}`);
    this._disconnectRoom(room);
  }

  notifyPaymentFailed(paymentId: string, reason?: string) {
    const room = `payment:${paymentId}`;
    this.server.to(room).emit('payment:failed', {
      event: 'payment:failed',
      paymentId,
      status: 'FAILED',
      reason: reason || 'فشلت عملية الدفع',
      timestamp: new Date().toISOString(),
    });
    this.logger.warn(`Payment failed emitted to room=${room}`);
    this._disconnectRoom(room);
  }

  @SubscribeMessage('subscribe:payment')
  handleSubscribePayment(client: Socket, payload: { paymentId: string }) {
    const room = `payment:${payload.paymentId}`;
    this.clientPayments.set(client.id, payload.paymentId);
    client.join(room);
    this._resetIdleTimer(client);
    this.logger.log(`Client ${client.id} subscribed to room=${room}`);
  }

  private _resetIdleTimer(client: Socket) {
    this._clearIdleTimer(client.id);
    const timer = setTimeout(() => {
      this.logger.warn(`Idle timeout — disconnecting client=${client.id}`);
      client.disconnect();
    }, IDLE_TIMEOUT_MS);
    this.idleTimers.set(client.id, timer);
  }

  private _clearIdleTimer(clientId: string) {
    const existing = this.idleTimers.get(clientId);
    if (existing) {
      clearTimeout(existing);
      this.idleTimers.delete(clientId);
    }
  }

  private _disconnectRoom(room: string) {
    const sockets = this.server.sockets.adapter.rooms.get(room);
    if (!sockets) return;
    for (const socketId of sockets) {
      const socket = this.server.sockets.sockets.get(socketId);
      if (socket) {
        setTimeout(() => socket.disconnect(), 500);
      }
    }
  }
}
