# NorthClaw - OpenClaw Docker Container

This project contains Docker configuration for running [OpenClaw](https://www.npmjs.com/package/openclaw) - a personal AI assistant that integrates with messaging platforms like WhatsApp, Telegram, Slack, Discord, and Signal.

## What is OpenClaw?

OpenClaw is a personal AI assistant that you run on your own devices. It can integrate with various messaging platforms to provide AI-powered assistance.

## Setup

### Local Testing

Build the Docker image:
```bash
docker build -t northclaw:latest .
```

Run with Docker Compose (recommended for persistent data):
```bash
docker-compose up -d
```

Or run directly with Docker:
```bash
docker run -it --rm \
  -v openclaw-data:/data \
  -v openclaw-config:/config \
  -p 3000:3000 \
  -e OPENAI_API_KEY=your_key_here \
  northclaw:latest
```

### Northflank Deployment

#### Step 1: Push to Git
Push this repository to your Git provider (GitHub, GitLab, Bitbucket, etc.)

#### Step 2: Create Service in Northflank
1. Navigate to [Northflank](https://app.northflank.com/t/stefano94103s-team)
2. Create a new **Combined Service**
3. Connect your Git repository
4. Configure the service:
   - **Context Path**: `/`
   - **Dockerfile Path**: `Dockerfile`
   - **Port**: `3000`

#### Step 3: Configure Volumes
In Northflank, add persistent volumes:
- **Volume Path**: `/data` - for application data
- **Volume Path**: `/config` - for configuration files

#### Step 4: Environment Variables
Add required environment variables in Northflank:

##### AI Providers (Required)

| Variable | Description | Required |
|----------|-------------|----------|
| `KIMI_API_KEY` | Kimi (Moonshot AI) API key | Yes** |
| `KIMI_MODEL` | Kimi model (default: moonshot-v1-128k) | No |
| `OPENROUTER_API_KEY` | OpenRouter API key (heartbeat/fallback) | Yes** |
| `OPENROUTER_HEARTBEAT_MODEL` | Heartbeat model (default: openai/gpt-3.5-turbo) | No |
| `OPENROUTER_FALLBACK_MODEL` | Fallback model (default: anthropic/claude-3-haiku) | No |

**Both Kimi and OpenRouter keys are required for this configuration.

##### Optional AI Providers (Backup)

| Variable | Description |
|----------|-------------|
| `OPENAI_API_KEY` | OpenAI API key for GPT models |
| `ANTHROPIC_API_KEY` | Anthropic API key for Claude |

##### Messaging Platforms (Optional)

| Variable | Description |
|----------|-------------|
| `WHATSAPP_PHONE_NUMBER` | WhatsApp integration |
| `TELEGRAM_BOT_TOKEN` | Telegram bot token |
| `SLACK_BOT_TOKEN` | Slack bot token |
| `DISCORD_BOT_TOKEN` | Discord bot token |

#### Step 5: Resource Allocation
Recommended settings:
- **CPU**: 0.5 - 1 vCPU
- **RAM**: 512MB - 1GB
- **Storage**: 1GB+ (for data persistence)

#### Step 6: Deploy
Click "Deploy" and monitor the logs for any issues.

## Configuration

### AI Provider Configuration

This setup uses **Kimi 2.5** as the main AI provider and **OpenRouter** for heartbeat/fallback:

- **Kimi (Moonshot AI)**: Primary model for all AI responses
  - Model: `moonshot-v1-128k` (128k context)
  - Alternative models: `moonshot-v1-32k`, `moonshot-v1-8k`

- **OpenRouter**: Secondary provider for heartbeat checks and fallback
  - Heartbeat model: `openai/gpt-3.5-turbo` (lightweight health checks)
  - Fallback model: `anthropic/claude-3-haiku` (backup when Kimi is unavailable)

This configuration provides cost efficiency (Kimi's competitive pricing) with reliability (OpenRouter fallback).

### Getting API Keys

#### Kimi (Moonshot AI)
1. Visit [Moonshot AI](https://platform.moonshot.cn/)
2. Create an account and obtain your API key
3. The key format starts with `sk-`

#### OpenRouter
1. Visit [OpenRouter](https://openrouter.ai/)
2. Create an account and obtain your API key
3. The key format starts with `sk-or-`

### First-Time Setup

After deployment, you may need to initialize OpenClaw:

```bash
# Access the container shell (in Northflank console or SSH)
openclaw init

# Or run the initialization directly
docker exec -it openclaw-container openclaw init
```

### Adding Skills

OpenClaw supports AI skills for enhanced functionality:

```bash
openclaw skill add <skill-name>
```

## Troubleshooting

### Container Won't Start
- Check the logs in Northflank
- Verify all required environment variables are set
- Ensure API keys are valid

### Data Persistence Issues
- Verify volumes are properly mounted in Northflank
- Check volume permissions

### API Key Issues
- Ensure API keys have proper permissions
- Check if the keys are valid and active

## Security Notes

- The container runs as a non-root user (openclaw:1001)
- API keys should be stored as environment variables, not in code
- Consider using Northflank's secret management for sensitive data
- OpenClaw can access files and execute commands - ensure proper security measures

## Resources

### OpenClaw
- [OpenClaw NPM Package](https://www.npmjs.com/package/openclaw)
- [OpenClaw Documentation](https://docs.z.ai/devpack/tool/openclaw)
- [Installation & Beginner Guide](https://datapipe.app/openclaw-installation-guide/)

### AI Providers
- [Kimi (Moonshot AI) Platform](https://platform.moonshot.cn/) - Primary AI provider
- [OpenRouter](https://openrouter.ai/) - Heartbeat and fallback provider
- [OpenRouter Models](https://openrouter.ai/models) - Available models

### Infrastructure
- [Northflank Documentation](https://docs.northflank.com/)
- [Northflank Dashboard](https://app.northflank.com/t/stefano94103s-team)

## License

This Docker configuration is provided as-is for deploying OpenClaw. Refer to OpenClaw's license for terms of use.
