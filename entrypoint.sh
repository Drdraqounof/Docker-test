#!/bin/sh
# entrypoint.sh
# Checks for required secrets and prints helpful messages before starting the app.
#!/bin/sh
# entrypoint.sh - Custom entrypoint to check for required secrets and print helpful messages

REQUIRED_SECRET="MY_SECRET_KEY"

if [ -z "$(printenv $REQUIRED_SECRET)" ]; then
  echo "[WARNING][SECRETS] The environment variable $REQUIRED_SECRET is missing.\nIf you see errors related to authentication or secrets, please check your .env file.\nThis is a known issue—see README.md for resolution steps."
fi

# Start the main application
exec "$@"
