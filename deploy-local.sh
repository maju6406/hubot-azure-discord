#!/bin/bash
# Azure App Service deployment script for hubot-azure-discord

set -e

echo "Starting hubot-azure-discord deployment..."

if [ -f "package.json" ]; then
  echo "Installing npm dependencies..."
  npm install --production
fi

echo "Deployment completed successfully."
