# Failure Modes

This document lists known failure modes for the project and how they are detected and handled.

## 1. Missing Secrets
- **Detection**: Entrypoint scripts check for required secrets and refuse to start if missing.
- **Resolution**: Add missing secrets to your environment or .env file.

## 2. Database Not Ready
- **Detection**: Docker healthcheck on db service; app waits for db to be healthy before starting.
- **Resolution**: Ensure db service is healthy; check logs for healthcheck failures.

## 3. Out-of-Sync package-lock.json
- **Detection**: Troubleshooting script warns if package-lock.json is older than package.json.
- **Resolution**: Run `npm install` to update lockfile.

## 4. Build or TypeScript Errors
- **Detection**: Build fails in CI or locally; errors are shown in logs.
- **Resolution**: Fix code or dependency issues as indicated by error messages.

## 5. Empty or Invalid page.tsx
- **Detection**: Troubleshooting script checks for empty app/page.tsx.
- **Resolution**: Add a valid React component to app/page.tsx.

## 6. Standalone Output Not Set
- **Detection**: Troubleshooting script checks next.config.ts for output: 'standalone'.
- **Resolution**: Update next.config.ts to include output: 'standalone'.

## 7. User/Group Issues in Dockerfile
- **Detection**: Troubleshooting script checks for nextjs user creation in Dockerfile.
- **Resolution**: Ensure user/group creation and chown are in the same Docker layer.

## 8. Test Failures in CI
- **Detection**: GitHub Actions workflow marks build as failed and logs test errors.
- **Resolution**: Review CI logs and fix failing tests.
