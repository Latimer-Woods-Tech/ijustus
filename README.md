# iJustus

A Cloudflare Workers application built on the Factory Core infrastructure. Civic and justice
platform — organization management, session facilitation, and simulation tools for legal and
community practice scenarios. See [`CLAUDE.md`](./CLAUDE.md) for the full mission and stack.

**Production**: https://ijustus.adrper79.workers.dev
**Staging**: https://ijustus-staging.adrper79.workers.dev

## Quick Start

```bash
# Install dependencies
npm ci

# Copy environment variables
cp .dev.vars.example .dev.vars
# Fill in .dev.vars values — see CLAUDE.md's Stack section for what each one backs

# Run locally
npm run dev
```

Then open http://localhost:8787.

### Verify Setup

```bash
npm run typecheck   # TypeScript strict mode, zero errors required
npm test             # Vitest suite
```

If both pass, you're ready to deploy.

## Environment Setup

`.dev.vars` (git-ignored) holds local secrets — Workers don't support `.env` files. Production
and staging secrets are set via `wrangler secret put`, never in `wrangler.jsonc` `vars`. See
[`docs/runbooks/secret-rotation.md`](./docs/runbooks/secret-rotation.md).

## API Routes

- `GET /health` — app status
- `/api/organizations` — organization management
- `/api/sessions` — session scheduling and facilitation
- `/api/simulators` — simulation tool management

See `src/routes/` for full route implementations.

## Deployment

```bash
npm run deploy           # production
npm run deploy:staging   # staging
```

Pushes to `main` deploy via `.github/workflows/deploy.yml`. Full runbook:
[`docs/runbooks/deployment.md`](./docs/runbooks/deployment.md).

## Testing

```bash
npm test
```

Vitest with `@cloudflare/vitest-pool-workers` to simulate the Workers runtime.

## Related Documentation

- [`CLAUDE.md`](./CLAUDE.md) — standing orders, stack, hard constraints, commit format
- [`docs/runbooks/getting-started.md`](./docs/runbooks/getting-started.md)
- [`docs/runbooks/deployment.md`](./docs/runbooks/deployment.md)
- [`docs/runbooks/database.md`](./docs/runbooks/database.md)
- [`docs/runbooks/secret-rotation.md`](./docs/runbooks/secret-rotation.md)
- [`docs/runbooks/slo.md`](./docs/runbooks/slo.md)
