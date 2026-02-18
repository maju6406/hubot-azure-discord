@description('Name of the Azure Web App that hosts the hubot instance')
param siteName string = 'hubot-discord'

@description('Name of the App Service plan for the web app')
param hostingPlanName string = '${siteName}-plan'

@description('Azure region for deploying all resources')
param location string = resourceGroup().location

@description('App Service pricing tier')
@allowed([
  'Free'
  'Shared'
  'Basic'
  'Standard'
])
param pricingTier string = 'Basic'

@description('Enable Always On (not available on Free/Shared tiers)')
param enableAlwaysOn bool = false

@description('Storage account name for hubot brain persistence via hubot-azure-brain')
param storageAccountName string = 'hubotst'

@description('Replication strategy for the storage account')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_ZRS'
])
param storageAccountType string = 'Standard_LRS'

@description('Discord bot token from https://discord.com/developers/applications')
@secure()
param discordBotToken string

@description('Display name for the hubot instance')
param hubotName string = 'hubot-discord'



var tierToSku = {
  Free: 'F1'
  Shared: 'D1'
  Basic: 'B1'
  Standard: 'S1'
}
var resolvedSku = tierToSku[pricingTier]
var appInsightsName = '${siteName}-insights'

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: storageAccountType
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: hostingPlanName
  location: location
  kind: 'linux'
  sku: {
    name: resolvedSku
  }
  properties: {
    reserved: true
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
    RetentionInDays: 90
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

resource webApp 'Microsoft.Web/sites@2022-03-01' = {
  name: siteName
  location: location
  kind: 'app,linux'
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'NODE|22-lts'
      appCommandLine: 'npm start'
      alwaysOn: enableAlwaysOn
      minTlsVersion: '1.2'
      ftpsState: 'Disabled'
      httpLoggingEnabled: true
      detailedErrorLoggingEnabled: true
      requestTracingEnabled: true
    }
  }
}

resource webAppConfig 'Microsoft.Web/sites/config@2022-03-01' = {
  name: 'appsettings'
  parent: webApp
  properties: {
    WEBSITE_NODE_DEFAULT_VERSION: '~22'
    HUBOT_ADAPTER: 'discord'
    HUBOT_DISCORD_TOKEN: discordBotToken
    HUBOT_BRAIN_AZURE_CONNSTRING: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${storageAccount.listKeys().keys[0].value};EndpointSuffix=core.windows.net'
    HUBOT_NAME: hubotName
    APPINSIGHTS_INSTRUMENTATIONKEY: appInsights.properties.InstrumentationKey
    APPLICATIONINSIGHTS_CONNECTION_STRING: appInsights.properties.ConnectionString
    ApplicationInsightsAgent_EXTENSION_VERSION: '~3'
    XDT_MicrosoftApplicationInsights_Mode: 'recommended'
    SCM_DO_BUILD_DURING_DEPLOYMENT: 'false'
  }
}

@description('URL of the deployed web app')
output webAppUrl string = 'https://${webApp.properties.defaultHostName}'

@description('Name of the Application Insights resource')
output applicationInsightsName string = appInsightsName

@description('Name of the storage account for hubot brain')
output storageAccountName string = storageAccountName
