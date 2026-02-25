# Docker Build Troubleshooting

This document outlines the errors encountered during the `docker compose up --build -d` process and the corresponding fixes.

## 1. Missing "build" script

- **Error:** `npm error Missing script: "build"`
- **Fix:** The `package.json` file was missing the necessary `scripts` for a Next.js application. I added the `build`, `dev`, `start`, and `lint` scripts.

```json
"scripts": {
  "dev": "next dev",
  "build": "next build",
  "start": "next start",
  "lint": "next lint"
}
```

## 2. TypeScript not found

- **Error:** `Failed to load next.config.ts` and `Cannot find module 'typescript'`
- **Fix:** The build process required TypeScript to transpile `next.config.ts`, but it wasn't listed as a dependency. I added `typescript` and `@types/node` to the `devDependencies` in `package.json`.

```json
"devDependencies": {
  "prisma": "^7.4.1",
  "typescript": "^5.5.4",
  "@types/node": "^20.14.12"
}
```

## 3. Out-of-sync `package-lock.json`

- **Error:** `npm ci` failed, reporting that `package.json` and `package-lock.json` were out of sync.
- **Fix:** After adding the new dev dependencies, the lockfile needed to be updated. I ran `npm install` to regenerate the `package-lock.json` file.

## 4. Empty `page.tsx`

- **Error:** `Type error: File '/app/app/page.tsx' is not a module.`
- **Fix:** The `app/page.tsx` file was empty, which is not a valid module. I added a simple "Hello, World!" React component to the file.

```tsx
export default function Home() {
  return (
    <main>
      <h1>Hello, World!</h1>
    </main>
  );
}
```

## 5. Standalone output not found

- **Error:** `failed to calculate checksum of ref ... "/app/.next/standalone": not found`
- **Fix:** The `Dockerfile` was configured to copy the `.next/standalone` directory, which is only generated when the `output` mode is set to `standalone`. I updated `next.config.ts` to include this setting.

```typescript
const nextConfig = {
    output: 'standalone',
};

module.exports = nextConfig;
```

## 6. Unknown user/group for `chown`

- **Error:** `chown: unknown user/group nextjs:nextjs`
- **Fix:** The `chown` command was being run in a separate Docker layer from where the `nextjs` user and group were created. I combined the user/group creation and the directory ownership commands into single `RUN` instructions in the `Dockerfile` to ensure the user exists when `chown` is executed.

```dockerfile
# Don't run production as root
RUN addgroup --system --gid 1001 nodejs && \
    adduser  --system --uid  1001 nextjs

# ...

# Set ownership and permissions for the .next directory
RUN mkdir .next && chown nextjs:nextjs .next
```
