#!/bin/sh
# entrypoint-troubleshoot.sh
# Runs automated troubleshooting and environment validation before starting the app.
#!/bin/sh
# entrypoint-troubleshoot.sh - Checks for previously fixed issues and prints helpful messages

# 1. Check for missing build script
if ! grep -q '"build"' package.json; then
  echo "[WARNING][BUILD_SCRIPT] 'build' script missing in package.json. This was a previous issue. See troubleshoot.md#1."
fi

# 2. Check for typescript in devDependencies
if ! grep -q '"typescript"' package.json; then
  echo "[WARNING][TYPESCRIPT] 'typescript' not found in devDependencies. This was a previous issue. See troubleshoot.md#2."
fi

# 3. Check for out-of-sync package-lock.json
if [ package-lock.json -ot package.json ]; then
  echo "[WARNING][LOCKFILE] package-lock.json may be out of sync with package.json. This was a previous issue. See troubleshoot.md#3."
fi

# 4. Check for empty page.tsx
if [ -f app/page.tsx ] && [ ! -s app/page.tsx ]; then
  echo "[WARNING][PAGE] app/page.tsx is empty. This was a previous issue. See troubleshoot.md#4."
fi

# 5. Check for standalone output in next.config.ts
if ! grep -q "output: 'standalone'" next.config.ts; then
  echo "[WARNING][STANDALONE] Standalone output not set in next.config.ts. This was a previous issue. See troubleshoot.md#5."
fi

# 6. Check for nextjs user in Dockerfile
if ! grep -q 'adduser  --system --uid  1001 nextjs' Dockerfile; then
  echo "[WARNING][USER] 'nextjs' user not created in Dockerfile. This was a previous issue. See troubleshoot.md#6."
fi

# 7. Enforce secret injection discipline
REQUIRED_SECRETS="MY_SECRET_KEY DATABASE_URL"
for secret in $REQUIRED_SECRETS; do
  if [ -z "$(printenv $secret)" ]; then
    echo "[ERROR][SECRET] Required secret $secret is missing. Refusing to start."
    exit 1
  fi
done

# Start the main application
exec "$@"
