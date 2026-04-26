# ijustus — Deployment

## Staging

```bash
wrangler deploy --env staging
curl https://staging.ijustus.workers.dev/health
```

## Production

```bash
wrangler deploy
```

## Rollback

```bash
wrangler rollback
```
