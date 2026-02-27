# Environment Variables in Docker Compose

## How Environment Variables Are Set

In this project, environment variables for the `app` service are loaded using the `env_file` property in `docker-compose.yml`:

```yaml
env_file:
  - .env
```

This tells Docker Compose to read variables from the `.env` file and inject them into the container. These variables are available to your application at runtime, but are not visible in the `docker-compose.yml` file itself.

## Why This Is More Secure
- **Secrets are not exposed**: Sensitive values (like database passwords) are not written directly in the `docker-compose.yml` file, so they are not visible to anyone reading the compose file.
- **Easier to keep private**: You can add `.env` and `.env.production` to your `.gitignore` file, so secrets are not committed to version control.

## Comparison with `environment:`
Some projects use the `environment:` section to set variables directly:

```yaml
environment:
  SECRET_KEY: mysecret
```

This exposes secrets in the compose file, which is less secure and more likely to be shared or committed by accident.

## Best Practice

- **Use `env_file` for secrets and environment-specific configuration.**
  - The `env_file` property in your `docker-compose.yml` allows you to specify one or more files (like `.env`, `.env.production`, etc.) that contain environment variables. These files are loaded automatically when the container starts, making the variables available to your application without exposing them in the compose file itself.
  - Example setup:
    1. Create a file named `.env` (for development) or `.env.production` (for production) in your project root.
    2. Add your secrets and configuration variables to this file, e.g.:
       ```env
       DATABASE_URL=your_database_url_here
       SECRET_KEY=your_secret_key_here
       ```
    3. In your `docker-compose.yml`, add:
       ```yaml
       env_file:
         - .env
       ```
       or for production:
       ```yaml
       env_file:
         - .env.production
       ```
    4. Make sure to add `.env` and `.env.production` to your `.gitignore` file so they are not committed to version control.
    5. Your application code can now access these variables using standard environment variable access (e.g., `process.env.SECRET_KEY` in Node.js).

- **Never commit your `.env` files to public repositories.**
- **Use `.gitignore` to keep secrets private.**

---

**Summary:**
Your secrets are not exposed in `docker-compose.yml` because you use `env_file` to load them from a separate, private file. This is a best practice for security and maintainability. By following this approach, you keep sensitive information out of your codebase and configuration files that are likely to be shared or versioned.
