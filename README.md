# NorthClaw - OpenClaw Docker Container

This project contains Docker configuration for running [OpenClaw](https://www.npmjs.com/package/openclaw) - a personal AI assistant that integrates with messaging platforms like WhatsApp, Telegram, Slack, Discord, and Signal.

## What is OpenClaw?

OpenClaw is a personal AI assistant that you run on your own devices. It can integrate with various messaging platforms to provide AI-powered assistance.

## Configuration Overview

This deployment comes pre-configured with:

### AI Models

| Purpose | Model | Provider |
|---------|-------|----------|
| **Primary** | Kimi K2.5 (moonshot/kimi-k2.5) | Moonshot AI |
| **Heartbeat** | Gemini 2.0 Flash (google/gemini-2.0-flash) | Google AI |
| **Fallback** | Free tier models via OpenRouter | OpenRouter |

### Agents

| ID | Name | Emoji | Workspace |
|----|------|-------|-----------|
| `main` | Wendy | 🌊 | `/data/workspace` |
| `ahyeon` | Ah-Yeon | 🐦 | `/data/workspace-ahyeon` |

### Model Details

**Primary: Kimi K2.5**
- Context Window: 256,000 tokens
- Max Output: 8,192 tokens
- Provider: Moonshot AI (https://api.moonshot.ai/v1)

**Heartbeat: Gemini 2.0 Flash**
- Context Window: 1,048,576 tokens
- Max Output: 8,192 tokens
- Provider: Google AI (https://generativelanguage.googleapis.com/v1beta)

**Fallback Models** (free tier):
- `openrouter/free:free`
- `nvidia/nemotron-3-nano-30b-a3b:free`
- `qwen/qwen3-next-80b-a3b-instruct:free`
- `stepfun/step-3.5-flash:free`
- `qwen/qwen3-vl-30b-a3b-thinking:free`

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
  -e MOONSHOT_API_KEY=your_key_here \
  -e GOOGLE_API_KEY=your_google_key_here \
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
- **Volume Path**: `/data` - for application data (1GB+)
- **Volume Path**: `/config` - for configuration files (100MB)

#### Step 4: Environment Variables
Add these environment variables in Northflank:

##### Required (AI Providers)

| Variable | Description | Required |
|----------|-------------|----------|
| `NODE_ENV` | Environment (production) | Yes |
| `MOONSHOT_API_KEY` | Moonshot AI API key (Kimi K2.5) | Yes |
| `MOONSHOT_BASE_URL` | Moonshot API endpoint | No (defaults to https://api.moonshot.ai/v1) |
| `GOOGLE_API_KEY` | Google AI API key (Gemini) | Yes |
| `GOOGLE_BASE_URL` | Google API endpoint | No (defaults to https://generativelanguage.googleapis.com/v1beta) |
| `ZAI_API_KEY` | ZAI authentication key | Optional |

##### Agent Configuration (Optional)

| Variable | Description | Default |
|----------|-------------|---------|
| `AGENT_WORKSPACE` | Default agent workspace | `/data/workspace` |
| `MAX_CONCURRENT` | Max concurrent operations | `4` |
| `MAX_SUBAGENT_CONCURRENT` | Max subagent operations | `8` |
| `COMPACTION_MODE` | Memory compaction mode | `safeguard` |

##### Messaging Platforms (Optional)

| Variable | Description |
|----------|-------------|
| `TELEGRAM_BOT_TOKEN` | Telegram bot token |
| `SLACK_BOT_TOKEN` | Slack bot token |
| `DISCORD_BOT_TOKEN` | Discord bot token |
| `WHATSAPP_PHONE_NUMBER` | WhatsApp phone number |

#### Step 5: Resource Allocation
Recommended settings:
- **CPU**: 0.5 - 1 vCPU
- **RAM**: 512MB - 1GB
- **Storage**: 1GB+ (for data persistence)

#### Step 6: Deploy
Click "Deploy" and monitor the logs for any issues.

## Getting API Keys

### Moonshot AI (Kimi K2.5)
1. Visit [Moonshot AI](https://platform.moonshot.cn/)
2. Create an account and obtain your API key
3. The key format starts with `sk-`

### Google AI (Gemini 2.0 Flash)
1. Visit [Google AI Studio](https://aistudio.google.com/app/apikey)
2. Create an account and obtain your API key
3. The key format starts with `AIza`

### ZAI (Optional)
1. Visit [ZAI Platform](https://z.ai/)
2. Create an account and obtain your API key

## OpenClaw Configuration

The container includes a pre-configured `openclaw.json` file at `/config/openclaw.json` with:

- **Agent-to-agent communication** enabled between `main` and `ahyeon`
- **Model aliases** for easy reference (Kimi K2.5, Gemini Flash, GLM)
- **Fallback chain** with multiple free-tier models
- **Workspace configuration** for both agents

To customize the configuration, you can:
1. Mount your own `openclaw.json` to `/config/openclaw.json`
2. Use environment variables to override settings
3. Access the container and edit the config directly

## First-Time Setup

After deployment, you may need to initialize OpenClaw:

```bash
# Access the container shell (in Northflank console or SSH)
openclaw init

# Or run the initialization directly
docker exec -it openclaw-container openclaw init
```

## Troubleshooting

### Container Won't Start
- Check the logs in Northflank
- Verify all required environment variables are set
- Ensure API keys are valid and properly formatted

### Data Persistence Issues
- Verify volumes are properly mounted in Northflank
- Check volume permissions

### API Key Errors
- Ensure API keys have proper permissions
- Check if the keys are valid and active
- Verify key formats (Moonshot: `sk-`, Google: `AIza`)

### Agent Issues
- Check that workspaces are accessible (`/data/workspace`, `/data/workspace-ahyeon`)
- Verify agent-to-agent communication is enabled in config

## Security Notes

- The container runs as a non-root user (openclaw:1001)
- API keys should be stored as environment variables, not in code
- **Never commit actual API keys to the repository**
- Use Northflank's secret management for sensitive data
- OpenClaw can access files and execute commands - ensure proper security measures

## Resources

### OpenClaw
- [OpenClaw NPM Package](https://www.npmjs.com/package/openclaw)
- [OpenClaw Documentation](https://docs.z.ai/devpack/tool/openclaw)
- [Installation & Beginner Guide](https://datapipe.app/openclaw-installation-guide/)

### AI Providers
- [Moonshot AI Platform](https://platform.moonshot.cn/) - Primary AI (Kimi K2.5)
- [Google AI Studio](https://aistudio.google.com/app/apikey) - Heartbeat (Gemini)
- [Google Gemini API Docs](https://ai.google.dev/gemini-api/docs) - Gemini documentation

### Infrastructure
- [Northflank Documentation](https://docs.northflank.com/)
- [Northflank Dashboard](https://app.northflank.com/t/stefano94103s-team)

## License

This Docker configuration is provided as-is for deploying OpenClaw. Refer to OpenClaw's license for terms of use.
