# 📦 Orders Module — Outbox

> **Module:** Order/ServiceRequest  
> **Status:** ✅ Complete  
> **Date:** 2026-06-18  
> **Developer:** Backend — Orders Module

---

## ✅ 1. Prisma Schema — `prisma/schema.prisma`

### Added `OrderStatus` enum (after `DocumentStatus`)

```prisma
enum OrderStatus {
  PENDING
  ACCEPTED
  DECLINED
  IN_PROGRESS
  COMPLETED
  CANCELLED
}
```

### Added relations on `User` model

```prisma
ordersAsClient    Order[]       @relation("ClientOrders")
ordersAsArtisan   Order[]       @relation("ArtisanOrders")
```

### Added relation on `Service` model

```prisma
orders          Order[]
```

### Added `Order` model (after `Favorite`)

```prisma
model Order {
  id             String      @id @default(uuid())
  clientId       String      @map("client_id")
  client         User        @relation("ClientOrders", fields: [clientId], references: [id])
  artisanId      String      @map("artisan_id")
  artisan        User        @relation("ArtisanOrders", fields: [artisanId], references: [id])
  serviceId      String      @map("service_id")
  service        Service     @relation(fields: [serviceId], references: [id])
  status         OrderStatus @default(PENDING)
  description    String?
  location       Json?       @map("location")
  budget         Decimal?    @map("budget") @db.Decimal(10, 2)
  scheduledDate  DateTime?   @map("scheduled_date")
  artisanNote    String?     @map("artisan_note")
  declinedReason String?     @map("declined_reason")
  totalPaid      Decimal?    @map("total_paid") @db.Decimal(10, 2)
  paidAt         DateTime?   @map("paid_at")
  completedAt    DateTime?   @map("completed_at")
  createdAt      DateTime    @default(now()) @map("created_at")
  updatedAt      DateTime    @updatedAt @map("updated_at")
  deletedAt      DateTime?   @map("deleted_at")

  @@index([clientId])
  @@index([artisanId])
  @@index([serviceId])
  @@index([status])
  @@map("orders")
}
```

✅ Prisma generates successfully.

---

## ✅ 2. NestJS Module — `src/modules/orders/`

```
orders/
├── dto/
│   └── index.ts                    # CreateOrderDto, UpdateOrderStatusDto, OrderFilterDto
├── guards/
│   └── verified-artisan.guard.ts   # Only verified artisans
├── orders.controller.ts            # REST endpoints
├── orders.module.ts                # Module config (JWT + Notifications)
├── orders.service.ts               # Business logic + status transitions
└── orders.gateway.ts               # WebSocket real-time events
```

---

## ✅ 3. REST Endpoints

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| `POST` | `/orders` | JWT (Client) | إنشاء طلب خدمة |
| `GET` | `/orders/client` | JWT | طلباتي كعميل (مع cursor pagination) |
| `GET` | `/orders/artisan` | JWT | طلباتي كحرفي — الطلبات الواردة |
| `GET` | `/orders/:id` | JWT | تفاصيل الطلب |
| `PATCH` | `/orders/:id/status` | JWT | تحديث حالة الطلب |
| `PATCH` | `/orders/:id/cancel` | JWT | إلغاء الطلب |
| `DELETE` | `/orders/:id` | JWT + ADMIN | حذف الطلب (soft delete) |

---

## ✅ 4. Status Transition Rules

```
PENDING    → ACCEPTED, DECLINED, CANCELLED
ACCEPTED   → IN_PROGRESS, CANCELLED
IN_PROGRESS → COMPLETED, CANCELLED
DECLINED    → (terminal)
COMPLETED   → (terminal)
CANCELLED   → (terminal)
```

**Permissions:**
- Artisan: ACCEPT, DECLINE, set IN_PROGRESS, set COMPLETED
- Client: CANCELLED only
- DeclinedReason is **required** when DECLINED

---

## ✅ 5. WebSocket Events — `/orders` namespace

| Event | Direction | Description |
|-------|-----------|-------------|
| `order.created` | Server → Artisans room + user:artisanId | إشعار للحرفي بطلب جديد (مع artisanData) |
| `order.updated` | Server → user:clientId (or both) | إشعار للعميل بتغير حالة الطلب |
| `subscribe:orders` | Client → Server | اشتراك في القنوات (room-based) |

**Auth:** JWT token from `Authorization` header or `token` query param.

---

## ✅ 6. Registered in `app.module.ts`

```typescript
import { OrdersModule } from './modules/orders/orders.module';
// ...
OrdersModule,
```

---

## ✅ 7. Push Notifications (FCM)

Each status change sends a push notification via existing `NotificationsService`:
- `order.created` → artisan: `📩 طلب خدمة جديد`
- `ACCEPTED` → client: `تم قبول طلبك ✅`
- `DECLINED` → client: `تم رفض الطلب ❌`
- `IN_PROGRESS` → client: `بدأ الحرفي في العمل 🔧`
- `COMPLETED` → client: `تم إنجاز الطلب 🎉`
- `CANCELLED` → both: `تم إلغاء الطلب`

---

## ✅ TypeScript Compilation

Only pre-existing errors in `app.controller.spec.ts` (unrelated). Orders module compiles cleanly.

---

## 🔜 Future Work (Not in scope)

- [ ] Payment integration (set `totalPaid`/`paidAt` when payment is confirmed)
- [ ] Chat/messaging per order
- [ ] Order review after COMPLETED
- [ ] Auto-cancel PENDING orders after 48h (cron/scheduler)
- [ ] Admin dashboard: order management endpoints
- [ ] Geo-fencing — only show orders within artisan's radius
