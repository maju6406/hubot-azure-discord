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

### Testing Your Discord Bot Token

Before deploying to Azure, you can verify that your Discord bot token is valid using curl:

```bash
curl -H "Authorization: Bot YOUR_BOT_TOKEN_HERE" \
     https://discord.com/api/v10/users/@me
```

A valid token will return JSON with your bot's information:
```json
{
  "id": "123456789012345678",
  "username": "YourBotName",
  "discriminator": "0000",
  "bot": true,
  ...
}
```

If the token is invalid, you'll receive an error response:
```json
{
  "message": "401: Unauthorized",
  "code": 0
}
```

## Deploy to Azure

> **Important:** Fork this repository before clicking the deploy button so the web app is linked to your own repository and you can add additional hubot scripts.

### Deploy with ARM Template

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmaju6406%2Fhubot-azure-discord%2Fmain%2Fazuredeploy.json)

### Deploy with Bicep

Alternatively, you can deploy using the Bicep template:

```bash
# Clone or download the repository
git clone https://github.com/maju6406/hubot-azure-discord.git
cd hubot-azure-discord

# Login to Azure
az login

# Create a resource group
az group create --name my-hubot-rg --location eastus

# Deploy the Bicep template
az deployment group create \
  --resource-group my-hubot-rg \
  --template-file azuredeploy.bicep \
  --parameters siteName=my-hubot \
               storageAccountName=myhubotstore \
               discordBotToken=YOUR_DISCORD_TOKEN \
               repoUrl=https://github.com/YOUR_USERNAME/hubot-azure-discord
```

> **Note:** This deployment creates a **Linux-based** Azure App Service. The app runs Node.js 18 LTS on Linux.

### Deployment Parameters

| Parameter | Type | Description |
|---|---|---|
| `siteName` | string | Name of the Azure Web App that hosts the hubot instance |
| `hostingPlanName` | string | Name of the App Service plan for the web app (default: {siteName}-plan) |
| `location` | string | Azure region for deploying all resources (defaults to the resource group location) |
| `pricingTier` | string | App Service pricing tier: Free, Shared, Basic, or Standard (default: Free) |
| `enableAlwaysOn` | bool | Enable Always On (set to false for Free/Shared tiers, default: false) |
| `storageAccountName` | string | Storage account name for hubot brain persistence via hubot-azure-brain |
| `storageAccountType` | string | Replication strategy: Standard_LRS, Standard_GRS, or Standard_ZRS (default: Standard_LRS) |
| `discordBotToken` | securestring | Discord bot token from the Developer Portal |
| `hubotName` | string | Display name for the hubot instance (default: hubot) |
| `repoUrl` | string | URL of your forked repository |
| `branch` | string | Git branch to deploy from (default: main) |

## Environment Variables

The ARM template automatically configures these environment variables on the Azure Web App:

- `WEBSITE_NODE_DEFAULT_VERSION` — Node.js runtime version (set to `~18`)
- `HUBOT_ADAPTER` — Set to `discord`
- `HUBOT_DISCORD_TOKEN` — Your Discord bot token
- `HUBOT_BRAIN_AZURE_CONNSTRING` — Connection string for Azure Blob Storage (auto-generated from the storage account)
- `HUBOT_NAME` — The bot display name
- `APPINSIGHTS_INSTRUMENTATIONKEY` — Application Insights instrumentation key (automatically configured)
- `APPLICATIONINSIGHTS_CONNECTION_STRING` — Application Insights connection string (automatically configured)

## Usage

Once deployment is complete:

1. The bot should appear online in your Discord server
2. In any channel where the bot has been added, type `@hubot help` (or whatever name you chose) to see available commands

## Post-Deployment: Accessing Azure Services

After your hubot instance is deployed, you can leverage several Azure services for monitoring, logging, and diagnostics.

### Application Insights - Monitoring & Logs

Application Insights is automatically configured during deployment and provides:

1. **Access Application Insights:**
   - Navigate to the [Azure Portal](https://portal.azure.com)
   - Go to your Resource Group
   - Click on the Application Insights resource (named `{siteName}-insights` where `{siteName}` is the siteName parameter value you provided during deployment)

2. **View Real-time Metrics:**
   - Click **Live Metrics** in the left menu to see real-time telemetry
   - Monitor requests, response times, and failures as they happen

3. **Query Logs:**
   - Click **Logs** in the left menu
   - Example queries:
     ```
     // View all traces (console.log output)
     traces
     | where timestamp > ago(1h)
     | order by timestamp desc
     
     // View exceptions and errors
     exceptions
     | where timestamp > ago(24h)
     | order by timestamp desc
     
     // View custom events
     customEvents
     | where timestamp > ago(1h)
     | order by timestamp desc
     ```

4. **Set Up Alerts:**
   - Click **Alerts** in the left menu
   - Create alert rules for failures, performance degradation, or custom metrics
   - Configure email, SMS, or webhook notifications

### Web App Diagnostics

The Azure Web App has built-in diagnostic logging enabled:

1. **Access Diagnostic Logs:**
   - Navigate to your Web App in the Azure Portal
   - Click **Log stream** in the left menu to view live logs
   - Or click **App Service logs** to configure log retention

2. **Download Logs:**
   - In your Web App, go to **Advanced Tools (Kudu)** → **Go**
   - Navigate to **Debug console** → **CMD**
   - Browse to `/LogFiles` to download log files

3. **Enable Additional Logging:**
   - Go to **Monitoring** → **App Service logs**
   - Configure application logging, web server logging, and detailed error messages
   - Set retention periods as needed

### Azure Storage - Hubot Brain

Your hubot's persistent memory is stored in Azure Blob Storage via `hubot-azure-brain`:

1. **Access Storage:**
   - Navigate to your Storage Account in the Azure Portal
   - Click **Containers** to view blob containers
   - The hubot brain data is stored in the default container

2. **View Brain Data:**
   - Click on the container
   - Download `brain.json` to inspect the bot's stored data

### Deployment Outputs

After deployment completes, the following information will be displayed in the Azure Portal deployment outputs:
- **Web App URL:** `https://{siteName}.azurewebsites.net` (where `{siteName}` is the siteName parameter value)
- **Application Insights Name:** `{siteName}-insights`
- **Storage Account Name:** `{storageAccountName}` (the storageAccountName parameter value)

You can also find this information in the Azure Portal under your Resource Group.

### Health Monitoring

To verify your bot is running (replace `{siteName}` with your siteName parameter value):

1. Visit `https://{siteName}.azurewebsites.net` - you should see the hubot web interface (typically displays "OK" or basic status information)
2. Check Application Insights Live Metrics for active requests
3. Verify the bot is online in your Discord server
4. Test a command like `@hubot ping` in Discord

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
| `azuredeploy.json` | Azure ARM template for one-click deployment (Linux App Service) |
| `azuredeploy.bicep` | Azure Bicep template for deployment (alternative to ARM template) |
| `package.json` | Node.js dependencies including hubot, hubot-discord, and hubot-azure-brain |
| `external-scripts.json` | List of external hubot scripts to load |
| `server.js` | Entry point for Azure Web App |
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