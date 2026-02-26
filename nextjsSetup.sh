#!/usr/bin/env bash
# nextjsSetup.sh
# Interactive script to bootstrap a Next.js project with Copilot and troubleshooting instructions.
#!/usr/bin/env bash

if ! command -v node >/dev/null; then
    echo "[ERROR][NODE_CHECK] Node.js is not installed. Installing Node.js..."

    sudo apt update -y
    sudo apt install -y nodejs npm

    echo "[INFO][NODE_INSTALL] Node.js $(node --version) and npm $(npm --version) have been installed."
else
    echo "[INFO][NODE_CHECK] Node.js is already installed. Version: $(node --version)"
fi

echo "[PROMPT][PROJECT_NAME] What is the name of your Next.js project?"
read projectName

echo "[INFO][CREATE_PROJECT] Creating a new Next.js project named \"$projectName\"..."

echo "[INFO][CREATE_PROJECT] Running npx create-next-app..."

npx create-next-app@latest "$projectName" --yes

echo "[INFO][NAVIGATE] Navigating into the project directory..."
cd "$projectName"

if [ $? -ne 0 ]; then
    echo "[ERROR][NAVIGATE] Failed to navigate into the project directory."
    exit 1
else
    echo "[INFO][NAVIGATE] Successfully navigated into the project directory."
fi

echo "[INFO][COPILOT] Creating Copilot instructions..."
mkdir -p .github

cat <<'EOF' > .github/copilot-instructions.md
## Copilot Instructions

- Do NOT modify test files
- Test files include:
  - __tests__/
  - *.test.ts
  - *.test.js
  - *.spec.ts
  - *.spec.js
- If changes to tests are needed, suggest them in comments only
- Prefer functional React components
- Follow Next.js conventions
EOF

echo "[SUCCESS][CREATE_PROJECT] Next.js project \"$projectName\" has been created successfully."
echo "[INFO][DEV] Before you log off run: npm run dev"
echo "[INFO][DEV] To start later: cd $projectName && npm run dev"
echo "[INFO][COMPLETE] Enjoy building your Next.js application!"
