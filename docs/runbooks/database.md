# ijustus — Database

## Where the data lives

ijustus's tables (`organizations`, `simulators`, `call_sessions`) live in the
OCI Postgres **`neighbor_aid`** database (host `129.146.27.227:5433`, role
`neighbor_aid`), reached at runtime through the `ijustus-db` Hyperdrive config
(`933b84184870481ab097a4506db5a675`, binding `env.DB`).

**Boundary rule (capricast#911):** this worker must never connect to another
product's database. Until 2026-07-18 the Hyperdrive origin was misdirected at
the kairoscouncil PROD database; that coupling is severed and guarded by
`scripts/check-db-boundary.sh` (pre-deploy in `deploy.yml` + weekly in
`db-boundary-guard.yml`). Any `DATABASE_URL` used for migrations below must
point at the `neighbor_aid` database only.

## Generate Migration

```bash
npx drizzle-kit generate
```

## Apply Migration

```bash
export DATABASE_URL="postgresql://..."
npx drizzle-kit migrate
```

## Preview Branch (CI)

Set NEON_PREVIEW_URL in GitHub repo secrets to run migration dry-run in CI.
