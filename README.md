# hubot-azure-discord

One-click deploy a [Hubot](https://github.com/hubotio/hubot) instance with the [Discord adapter](https://github.com/hubot-friends/hubot-discord) to Azure. Uses [hubot-azure-brain](https://github.com/coryallegory/hubot-azure-brain) for persistent brain storage via Azure Blob Storage.

## Prerequisites

Before deploying, you need a Discord bot token:

1. Go to the [Discord Developer Portal](https://discord.com/developers/applications)
2. Click **New Application**, give it a name, and click **Create**
3. Navigate to **Bot** in the left sidebar and click **Add Bot**
4. Under the **Token** section, click **Reset Token** to generate a new token
5. Copy this token — you will need it during deployment
6. Under **Privileged Gateway Intents**, enable **Message Content Intent** if you want the bot to respond to messages via `robot.hear`
7. Navigate to **OAuth2 > URL Generator**, select the `bot` scope, then select permissions: **Read Messages/View Channels**, **Send Messages**, **Read Message History**
8. Open the generated URL to invite the bot to your Discord server

## Deploy to Azure

> **Important:** Fork this repository before clicking the deploy button so the web app is linked to your own repository and you can add additional hubot scripts.

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmaju6406%2Fhubot-azure-discord%2Fmain%2Fazuredeploy.json)

### Deployment Parameters

| Parameter | Type | Description |
|---|---|---|
| `siteName` | string | Name of the Azure Web App that hosts the hubot instance |
| `hostingPlanName` | string | Name of the App Service plan for the web app |
| `location` | string | Azure region for deploying all resources (defaults to the resource group location) |
| `pricingTier` | string | App Service pricing tier: Free, Shared, Basic, or Standard |
| `enableAlwaysOn` | bool | Enable Always On (set to false for Free/Shared tiers) |
| `storageAccountName` | string | Storage account name for hubot brain persistence via hubot-azure-brain |
| `storageAccountType` | string | Replication strategy: Standard_LRS, Standard_GRS, or Standard_ZRS |
| `discordBotToken` | securestring | Discord bot token from the Developer Portal |
| `hubotName` | string | Display name for the hubot instance (default: hubot) |
| `repoUrl` | string | URL of your forked repository |
| `branch` | string | Git branch to deploy from (default: main) |

## Environment Variables

The ARM template automatically configures these environment variables on the Azure Web App:

- `HUBOT_ADAPTER` — Set to `discord`
- `HUBOT_DISCORD_TOKEN` — Your Discord bot token
- `HUBOT_BRAIN_AZURE_CONNSTRING` — Connection string for Azure Blob Storage (auto-generated from the storage account)
- `HUBOT_NAME` — The bot display name

## Usage

Once deployment is complete:

1. The bot should appear online in your Discord server
2. In any channel where the bot has been added, type `@hubot help` (or whatever name you chose) to see available commands

## Adding Scripts

To add more hubot scripts:

1. Add the npm package to `package.json` under `dependencies`
2. Add the script name to `external-scripts.json`
3. Push changes to your forked repository
4. In the Azure Portal, navigate to your Web App > Deployment Center and click **Sync** to pull the latest changes

See the [Hubot scripting docs](https://hubotio.github.io/hubot/scripting.html) for more details.

## Project Structure

| File | Description |
|---|---|
| `azuredeploy.json` | Azure ARM template for one-click deployment |
| `package.json` | Node.js dependencies including hubot, hubot-discord, and hubot-azure-brain |
| `external-scripts.json` | List of external hubot scripts to load |
| `server.js` | Entry point for Azure Web App (IISNode) |
| `Procfile` | Process definition for Azure App Service |
| `deploy.sh` | Custom deployment script used by Kudu |
| `bin/hubot` | Shell script to run hubot locally |
| `bin/hubot.cmd` | Windows batch script to run hubot locally |

## Running Locally

```sh
HUBOT_DISCORD_TOKEN=<your-bot-token> bin/hubot --adapter discord
```

## License

[MIT](LICENSE)