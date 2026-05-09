import { describe, it, expect, vi } from 'vitest';
import app from './index.js';

vi.mock('@latimer-woods-tech/analytics', () => ({
  initAnalytics: () => ({
    track: vi.fn().mockResolvedValue(undefined),
    identify: vi.fn().mockResolvedValue(undefined),
    businessEvent: vi.fn().mockResolvedValue(undefined),
    page: vi.fn().mockResolvedValue(undefined),
  }),
}));

describe('ijustus', () => {
  it('GET /health returns ok', async () => {
    const res = await app.request('/health', {}, {
      ENVIRONMENT: 'test',
      WORKER_NAME: 'ijustus',
      DB: { connectionString: 'postgresql://test:test@localhost:5432/test' } as Hyperdrive,
      JWT_SECRET: 'test-secret',
      SENTRY_DSN: '',
      POSTHOG_KEY: '',
      ANTHROPIC_API_KEY: '',
      GROK_API_KEY: '',
      GROQ_API_KEY: '',
      RESEND_API_KEY: '',
    });
    expect(res.status).toBe(200);
    const body = await res.json();
    expect(body).toMatchObject({ status: 'ok' });
  });
});
