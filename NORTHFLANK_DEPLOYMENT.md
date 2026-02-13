# Northflank Deployment Guide

This guide provides step-by-step instructions for deploying OpenClaw to Northflank with Kimi K2.5, Gemini 2.0 Flash, and your custom agent configuration.

## Prerequisites

- A Northflank account (https://app.northflank.com/t/stefano94103s-team)
- A Git repository with this code
- API keys for:
  - **Moonshot AI** - Primary AI provider (Kimi K2.5)
  - **Google AI** - Heartbeat health checks (Gemini 2.0 Flash)

## Configuration Summary

This deployment includes:

### AI Models
- **Primary**: Kimi K2.5 (256k context, 8k max tokens)
- **Heartbeat**: Gemini 2.0 Flash (1M context, 8k max tokens)
- **Fallback**: Multiple free-tier models

### Pre-Configured Agents
- **Wendy** (🌊) - Main agent at `/data/workspace`
- **Ah-Yeon** (🐦) - Secondary agent at `/data/workspace-ahyeon`

## Step-by-Step Deployment

### 1. Push Code to Git Repository

First, ensure all your files are pushed to a Git repository (GitHub, GitLab, Bitbucket, etc.).

### 2. Create a New Combined Service

1. Log in to [Northflank](https://app.northflank.com/t/stefano94103s-team)
2. Navigate to your project or create a new one
3. Click **"Create service"**
4. Select **"Combined service"**
5. Click **"Create combined service"**

### 3. Configure Git Repository

1. Under **"Build & deployment"**, select your Git provider
2. Authorize Northflank to access your repositories
3. Select the repository containing this Dockerfile
4. Select the branch (usually `main` or `master`)
5. Click **"Continue"**

### 4. Configure Docker Build Settings

Set the following options:

| Setting | Value |
|---------|-------|
| **Context path** | `/` |
| **Dockerfile path** | `Dockerfile` |
| **Build path** | (leave empty) |

### 5. Add Persistent Volumes

Under **"Volumes"**, add two volumes:

1. Click **"Add volume"**
   - **Mount path**: `/data`
   - **Size**: 1 GB (or more as needed)
   - Click **"Add"**

2. Click **"Add volume"** again
   - **Mount path**: `/config`
   - **Size**: 100 MB
   - Click **"Add"**

### 6. Configure Environment Variables

Under **"Environment variables"**, add your API keys:

#### Required (AI Providers)

| Variable | Value | Description |
|----------|-------|-------------|
| `NODE_ENV` | `production` | Environment |
| `MOONSHOT_API_KEY` | Your Moonshot API key | Kimi K2.5 |
| `MOONSHOT_BASE_URL` | `https://api.moonshot.ai/v1` | Moonshot API endpoint |
| `GOOGLE_API_KEY` | Your Google AI API key | Gemini 2.0 Flash |
| `GOOGLE_BASE_URL` | `https://generativelanguage.googleapis.com/v1beta` | Google API endpoint |

#### Optional (ZAI Platform)

| Variable | Value | Description |
|----------|-------|-------------|
| `ZAI_API_KEY` | Your ZAI API key | Platform features |

#### Agent Configuration (Optional)

| Variable | Default | Description |
|----------|---------|-------------|
| `AGENT_WORKSPACE` | `/data/workspace` | Default workspace |
| `MAX_CONCURRENT` | `4` | Max concurrent operations |
| `MAX_SUBAGENT_CONCURRENT` | `8` | Max subagent operations |
| `COMPACTION_MODE` | `safeguard` | Memory compaction |

#### Messaging Integrations (Optional)

| Variable | Description |
|----------|-------------|
| `TELEGRAM_BOT_TOKEN` | Telegram bot token |
| `SLACK_BOT_TOKEN` | Slack bot token |
| `DISCORD_BOT_TOKEN` | Discord bot token |
| `WHATSAPP_PHONE_NUMBER` | WhatsApp phone number |

#### Example Configuration

```
NODE_ENV=production
MOONSHOT_API_KEY=sk-your-moonshot-key-here
MOONSHOT_BASE_URL=https://api.moonshot.ai/v1
GOOGLE_API_KEY=AIza-your-google-key-here
GOOGLE_BASE_URL=https://generativelanguage.googleapis.com/v1beta
ZAI_API_KEY=your-zai-key-here
AGENT_WORKSPACE=/data/workspace
```

⚠️ **Important**: Use Northflank's secret management for sensitive values. Never hardcode API keys in the repository.

### 7. Configure Port

Under **"Ports"**:

- **Internal port**: `3000`
- **Protocol**: `TCP`
- **Type**: `HTTP` (if exposing a web interface)

### 8. Set Resource Limits

Under **"Resources"**:

| Resource | Recommended Value |
|----------|------------------|
| **CPU** | 0.5 vCPU minimum, 1 vCPU recommended |
| **RAM** | 512 MB minimum, 1 GB recommended |

### 9. Configure Deployment Options

- **Deployment mode**: `Auto deploy` (recommended) or `Manual`
- **Replicas**: `1` (can scale up if needed)
- **Retry policy**: Enable retries with backoff

### 10. Review and Deploy

1. Review all settings
2. Click **"Create service"**
3. Wait for the build to complete
4. Monitor the deployment logs for any errors

## Post-Deployment Steps

### Verify Deployment

1. Check the **"Logs"** tab to ensure OpenClaw started successfully
2. Look for any error messages related to missing API keys or configuration
3. Verify that both agents (Wendy and Ah-Yeon) are loaded correctly

### Initial Configuration

The container includes a pre-configured `openclaw.json` with your agent setup. If you need to make changes:

1. Access the container via **"Console"** in Northflank
2. View the current configuration:
   ```bash
   cat /config/openclaw.json
   ```
3. Edit if needed:
   ```bash
   vi /config/openclaw.json
   ```
4. Restart the service to apply changes

### Connect Messaging Platforms

1. For each platform you want to use:
   - Set the required environment variables
   - Follow OpenClaw's documentation for platform-specific setup
   - Restart the service to apply changes

### Monitor the Service

- Set up monitoring in Northflank
- Configure alerts for CPU, memory, and disk usage
- Regularly check logs for issues
- Watch for agent communication between Wendy and Ah-Yeon

## Troubleshooting

### Container Won't Start

**Check:**
- Dockerfile syntax is correct
- All required environment variables are set (`MOONSHOT_API_KEY`, `GOOGLE_API_KEY`)
- API keys are valid and properly formatted
- Volumes are properly configured

**Action:** View the build logs and deployment logs for specific error messages.

### API Key Errors

**Symptom:** Container starts but fails to make AI requests.

**Solution:**
- Verify API keys are correct and active
- Check key formats:
  - Moonshot: starts with `sk-`
  - Google: starts with `AIza` (may be shorter format `AQ.Ab8...`)
- Ensure no whitespace or special characters in environment variable values

### Agent Issues

**Symptom:** Agents not responding or communicating.

**Solution:**
- Check that workspaces are accessible:
  ```bash
  ls -la /data/workspace /data/workspace-ahyeon
  ```
- Verify agent-to-agent communication is enabled in config
- Check logs for agent-specific errors

### Volume Permission Issues

**Symptom:** OpenClaw can't write to /data or /config directories.

**Solution:** The Dockerfile sets up proper permissions, but if issues persist:
```bash
ls -la /data /config
```

### Service Crashes

**Check:**
- Resource limits (may need more CPU/RAM)
- Application logs for errors
- External service availability (API providers)
- Agent communication logs

## Updates and Maintenance

### Updating OpenClaw

To update to the latest version:

1. Update the Dockerfile to use a specific version or `latest`:
   ```dockerfile
   RUN npm install -g openclaw@latest
   ```

2. Push changes to Git

3. Trigger a new deployment in Northflank

### Updating Configuration

To modify agent configuration or models:

1. Edit `config/openclaw.json` in the repository
2. Push changes to Git
3. Redeploy in Northflank

### Scaling

To handle more load:

1. Increase CPU/RAM allocation
2. Consider using external storage if volume limits are reached
3. For high availability, consider multiple replicas with a load balancer

## Security Best Practices

1. **Use Secrets**: Store API keys in Northflank's secret management
2. **Limit Permissions**: Use API keys with minimal required permissions
3. **Monitor Logs**: Regularly review logs for suspicious activity
4. **Update Regularly**: Keep OpenClaw and dependencies updated
5. **Network Security**: Use HTTPS and consider IP whitelisting
6. **Agent Access**: Ensure agent-to-agent communication is properly configured

## Support

For issues specific to:
- **Northflank**: Check [Northflank Documentation](https://docs.northflank.com/)
- **OpenClaw**: Refer to [OpenClaw Documentation](https://docs.z.ai/devpack/tool/openclaw)
- **This Setup**: Check the main [README.md](README.md)

## Quick Reference: API Key Formats

| Provider | Key Format | Example |
|----------|------------|---------|
| Moonshot AI | `sk-...` | `sk-kimi-3ip58...` |
| Google AI | `AIza...` or `AQ.Ab8...` | `AQ.Ab8RN6Jc...` |
| ZAI | varies | Check platform |
