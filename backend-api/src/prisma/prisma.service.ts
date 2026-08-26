import { Injectable, OnModuleDestroy, OnModuleInit } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

/// Prisma's default connection pool size is `num_physical_cpus * 2 + 1` --
/// on this service's small container that works out to only a handful of
/// connections, which a burst of concurrent requests queues up behind
/// (each waiting on Prisma's default 10s pool_timeout) rather than being
/// served in parallel. Verified directly with a load test: at 500
/// concurrent requests against a single instance, ~35% timed out with
/// 5-10s latencies, even though Postgres itself allows up to 500
/// connections and was nowhere near that ceiling. Raised well above the
/// default -- with the whole app running as a single instance (this
/// service has a persistent volume attached, so it can't be horizontally
/// scaled across replicas without decoupling file storage first), this
/// pool is the only lever available for handling a real concurrent
/// traffic spike, e.g. an audience opening the app during a live demo.
function withPoolTuning(url: string | undefined): string | undefined {
  if (!url) return url;
  const separator = url.includes('?') ? '&' : '?';
  return `${url}${separator}connection_limit=120&pool_timeout=20`;
}

@Injectable()
export class PrismaService
  extends PrismaClient
  implements OnModuleInit, OnModuleDestroy
{
  constructor() {
    super({ datasourceUrl: withPoolTuning(process.env.DATABASE_URL) });
  }

  async onModuleInit() {
    await this.$connect();
  }

  async onModuleDestroy() {
    await this.$disconnect();
  }
}