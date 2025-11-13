#!/usr/bin/env bash
set -e

cd /work

# Remove pre-existing server.pid
rm -f tmp/pids/server.pid

echo "==> Checking gems..."
if ! bundle check > /dev/null 2>&1; then
  echo "==> Installing missing gems..."
  bundle install
fi

if [ -f package.json ]; then
  echo "==> Checking node_modules..."
  if [ ! -d node_modules ]; then
    echo "==> Installing npm packages..."
    npm install
  fi
fi

echo "==> Starting: $*"
exec "$@"
