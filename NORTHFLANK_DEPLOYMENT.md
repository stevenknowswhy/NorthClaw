# Northflank Deployment Guide

This guide provides step-by-step instructions for deploying OpenClaw to Northflank.

## Prerequisites

- A Northflank account (https://app.northflank.com/t/stefano94103s-team)
- A Git repository with this code
- API keys for:
  - **Kimi (Moonshot AI)** - Primary AI provider
  - **OpenRouter** - Heartbeat and fallback provider

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

| Variable | Value |
|----------|-------|
| `NODE_ENV` | `production` |
| `KIMI_API_KEY` | Your Kimi (Moonshot AI) API key |
| `KIMI_MODEL` | `moonshot-v1-128k` (or `moonshot-v1-32k`, `moonshot-v1-8k`) |
| `KIMI_BASE_URL` | `https://api.moonshot.cn/v1` |
| `OPENROUTER_API_KEY` | Your OpenRouter API key |
| `OPENROUTER_HEARTBEAT_MODEL` | `openai/gpt-3.5-turbo` (or `google/gemini-flash-1.5`) |
| `OPENROUTER_FALLBACK_MODEL` | `anthropic/claude-3-haiku` (or `openai/gpt-4o-mini`) |

#### Optional (Messaging Integrations)

| Variable | Description |
|----------|-------------|
| `TELEGRAM_BOT_TOKEN` | Telegram bot token |
| `SLACK_BOT_TOKEN` | Slack bot token |
| `DISCORD_BOT_TOKEN` | Discord bot token |
| `WHATSAPP_PHONE_NUMBER` | WhatsApp phone number |

#### Example Configuration

```
NODE_ENV=production
KIMI_API_KEY=sk-xxxxxxxxxxxxx
KIMI_MODEL=moonshot-v1-128k
KIMI_BASE_URL=https://api.moonshot.cn/v1
OPENROUTER_API_KEY=sk-or-xxxxxxxxxxxxx
OPENROUTER_HEARTBEAT_MODEL=openai/gpt-3.5-turbo
OPENROUTER_FALLBACK_MODEL=anthropic/claude-3-haiku
```

⚠️ **Important**: Use Northflank's secret management for sensitive values. Never hardcode API keys.

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

### Initial Configuration

If OpenClaw requires initial setup, you may need to:

1. Access the container via **"Console"** in Northflank
2. Run initialization commands:
   ```bash
   openclaw init
   ```
3. Follow the interactive prompts

### Connect Messaging Platforms

1. For each platform you want to use:
   - Set the required environment variables
   - Follow OpenClaw's documentation for platform-specific setup
   - Restart the service to apply changes

### Monitor the Service

- Set up monitoring in Northflank
- Configure alerts for CPU, memory, and disk usage
- Regularly check logs for issues

## Troubleshooting

### Container Won't Start

**Check:**
- Dockerfile syntax is correct
- All environment variables are set
- API keys are valid
- Volumes are properly configured

**Action:** View the build logs and deployment logs for specific error messages.

### API Key Errors

**Symptom:** Container starts but fails to make AI requests.

**Solution:**
- Verify API keys are correct and active
- Check that the keys have proper permissions
- Ensure no whitespace or special characters in environment variable values

### Volume Permission Issues

**Symptom:** OpenClaw can't write to /data or /config directories.

**Solution:** The Dockerfile sets up proper permissions, but if issues persist, check the volume ownership in the container:
```bash
ls -la /data /config
```

### Service Crashes

**Check:**
- Resource limits (may need more CPU/RAM)
- Application logs for errors
- External service availability (API providers)

## Updates and Maintenance

### Updating OpenClaw

To update to the latest version:

1. Update the Dockerfile to use a specific version or `latest`:
   ```dockerfile
   RUN npm install -g openclaw@latest
   ```

2. Push changes to Git

3. Trigger a new deployment in Northflank

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

## Support

For issues specific to:
- **Northflank**: Check [Northflank Documentation](https://docs.northflank.com/)
- **OpenClaw**: Refer to [OpenClaw Documentation](https://docs.z.ai/devpack/tool/openclaw)
- **This Setup**: Check the main [README.md](README.md)
