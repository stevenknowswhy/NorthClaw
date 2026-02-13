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

| Variable | Description | Required |
|----------|-------------|----------|
| `NODE_ENV` | Environment (production/development) | No |
| `OPENAI_API_KEY` | OpenAI API key for GPT models | Yes* |
| `ANTHROPIC_API_KEY` | Anthropic API key for Claude | Yes* |
| `WHATSAPP_PHONE_NUMBER` | WhatsApp integration | No |
| `TELEGRAM_BOT_TOKEN` | Telegram bot token | No |
| `SLACK_BOT_TOKEN` | Slack bot token | No |
| `DISCORD_BOT_TOKEN` | Discord bot token | No |

*At least one AI provider API key is required.

#### Step 5: Resource Allocation
Recommended settings:
- **CPU**: 0.5 - 1 vCPU
- **RAM**: 512MB - 1GB
- **Storage**: 1GB+ (for data persistence)

#### Step 6: Deploy
Click "Deploy" and monitor the logs for any issues.

## Configuration

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

- [OpenClaw NPM Package](https://www.npmjs.com/package/openclaw)
- [OpenClaw Documentation](https://docs.z.ai/devpack/tool/openclaw)
- [Installation & Beginner Guide](https://datapipe.app/openclaw-installation-guide/)
- [Northflank Documentation](https://docs.northflank.com/)

## License

This Docker configuration is provided as-is for deploying OpenClaw. Refer to OpenClaw's license for terms of use.
