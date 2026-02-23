#!/usr/bin/env bash

if ! command -v node >/dev/null; then
    echo "Node.js is not installed. Installing Node.js..."

    sudo apt update -y
    sudo apt install -y nodejs npm

    echo "Node.js $(node --version) and npm $(npm --version) have been installed."
else
    echo "Node.js is already installed. Version: $(node --version)"
fi

echo "What is the name of your Next.js project?"
read projectName

echo "Creating a new Next.js project named \"$projectName\"..."

echo "Running npx create-next-app..."
npx create-next-app@latest "$projectName" --yes

echo "Navigating into the project directory..."
cd "$projectName"

if [ $? -ne 0 ]; then
    echo "Failed to navigate into the project directory."
    exit 1
else
    echo "Successfully navigated into the project directory."
fi

echo "Creating Copilot instructions..."
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

echo "Next.js project \"$projectName\" has been created successfully."
echo "Before you log off run: npm run dev"
echo "To start later: cd $projectName && npm run dev"
echo "Enjoy building your Next.js application!"
