// Prisma 7+ config for Neon
import { defineConfig } from 'prisma';

export default defineConfig({
  db: {
    provider: 'postgresql',
    url: process.env.DATABASE_URL,
  },
});
