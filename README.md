# bonfyre-example-saas-stack

**Complete SaaS backend: auth, billing, API gateway, CMS. 240 KB total. No cloud required.**

## The pitch (for your CEO)

| Component | Typical stack | Monthly cost | **Bonfyre** | Size |
|---|---|---|---|---|
| API Gateway | AWS API Gateway / Kong | $50–500/mo | **bonfyre-api** | 69 KB |
| Authentication | Auth0 / Firebase Auth | $23–240/mo | **bonfyre-auth** | 35 KB |
| Authorization | Custom / Okta | $100–500/mo | **bonfyre-gate** | 33 KB |
| Usage metering | Stripe Metering / Amberflo | $100–1000/mo | **bonfyre-meter** | 34 KB |
| Billing | Stripe | 2.9% + $0.30/txn | **bonfyre-pay** | 35 KB |
| CMS | Strapi / Contentful | $29–300/mo | **bonfyre-cms** | 299 KB |
| **Total** | 6 vendors, 6 SDKs | **$302–2,540/mo** | **6 binaries** | **~240 KB** |

**Annual savings: $3,600–30,000.** Zero vendor lock-in. All data in SQLite on your machine.

## What you get

```
┌─────────────────────────────────────────────────┐
│                 bonfyre-api                      │
│           HTTP Gateway (port 9090)               │
│            Static files + REST API               │
│                   69 KB                          │
└────────────┬──────────┬──────────┬──────────────┘
             │          │          │
    ┌────────▼──┐  ┌────▼────┐  ┌─▼──────────┐
    │bonfyre-auth│  │bonfyre- │  │bonfyre-pay │
    │  Signup    │  │  gate   │  │ Invoicing  │
    │  Login     │  │ API keys│  │ Credits    │
    │  Sessions  │  │ Tiers   │  │ Payments   │
    │  35 KB     │  │ 33 KB   │  │  35 KB     │
    └──────┬─────┘  └────┬────┘  └─────┬──────┘
           │             │             │
           └─────────────┼─────────────┘
                         │
                ┌────────▼─────────┐
                │  bonfyre-meter   │
                │ Usage tracking   │
                │ Per-op pricing   │
                │ Rate limiting    │
                │     34 KB        │
                └──────────────────┘
```

All state in SQLite. No Redis. No Postgres. No external databases.

## Prerequisites

- C compiler (clang/gcc)
- SQLite3 headers

## Quick start

```bash
git clone https://github.com/Nickgonzales76017/bonfyre-example-saas-stack.git
cd bonfyre-example-saas-stack
./setup.sh      # clones bonfyre, builds 6 binaries (~1 min)
./run.sh         # starts backend + creates demo user + demo API calls
```

## What you'll see

```
╔══════════════════════════════════════════════════════╗
║     Bonfyre SaaS Stack — Full Backend Demo           ║
╚══════════════════════════════════════════════════════╝

━━━ Starting services ━━━

  [1/5] API gateway        ✓  http://localhost:9090  (69 KB)
  [2/5] Creating user      ✓  demo@example.com
  [3/5] Issuing API key    ✓  tier=pro, key=bf_pro_a1b2c3...
  [4/5] Recording usage    ✓  3 operations metered
  [5/5] Generating invoice ✓  $12.47 for April 2026

━━━ Backend running ━━━

  Dashboard:  http://localhost:9090
  API:        http://localhost:9090/api/
  User:       demo@example.com / demo123
  API Key:    bf_pro_a1b2c3d4e5f6

  Endpoints:
    POST /api/auth/signup     Create account
    POST /api/auth/login      Get session token
    GET  /api/gate/verify     Check API key
    GET  /api/meter/usage     View usage stats
    GET  /api/pay/invoice     Generate invoice

  Press Ctrl+C to stop.
```

## API key tiers

| Tier | Rate limit | Monthly price | Features |
|---|---|---|---|
| Free | 100 req/hr | $0 | Basic API access |
| Pro | 10,000 req/hr | $29 | Full pipeline, priority queue, webhooks |
| Enterprise | Unlimited | Custom | Dedicated support, SLA, custom integrations |

## Usage metering

Every API call is tracked automatically:

```bash
# Check usage for a user
bonfyre-meter status --email demo@example.com

# Output:
#   User: demo@example.com
#   Period: 2026-04
#   Operations:
#     embed:       142 calls    $2.84
#     search:      891 calls    $4.46
#     transcribe:  23 calls     $11.50
#     compress:    567 calls    $1.13
#   Total:         1,623 calls  $19.93
```

## Testing the API

After `./run.sh` starts the backend:

```bash
# Signup
curl -X POST http://localhost:9090/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"test123"}'

# Login
curl -X POST http://localhost:9090/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"test123"}'

# Verify API key
curl http://localhost:9090/api/gate/verify \
  -H "Authorization: Bearer bf_pro_a1b2c3d4e5f6"

# Check usage
curl http://localhost:9090/api/meter/usage?email=test@example.com
```

## Running the test suite

```bash
./test.sh
# Exercises every endpoint: signup → login → issue key → make API calls → check usage → invoice
```

## Pipeline intelligence

When you add transcription or content processing to your SaaS, you get:

| Capability | Detail |
|---|---|
| Transcription quality | **0.997** (HCP v3.2, 9-layer hallucination detection, 0.09% error rate) |
| Pipeline latency | **< 8 ms** per stage |
| OpenAI API | Drop-in via `bonfyre-proxy serve --port 8787` |
| Compression | **9.3%** JSON ratio with O(1) field reads (Lambda Tensors) |
| Total platform | **48 binaries, ~2.1 MB** — 167 tests passing |

## Deploying to production

Bonfyre's SaaS stack is static binaries — deploy anywhere:

```bash
# 1. Build on your CI
make

# 2. Copy 6 binaries to your server (240 KB total)
scp bonfyre-{api,auth,gate,meter,pay,cms} production-server:~/bin/

# 3. Start
ssh production-server 'bonfyre-api --port 9090 serve &'
```

No Docker. No Kubernetes. No container registry. Just `scp` and run.

## File structure

```
bonfyre-example-saas-stack/
├── README.md
├── setup.sh          # Clones + builds the 6 SaaS binaries
├── run.sh            # Starts backend + seeds demo data
├── test.sh           # API test suite
├── stop.sh           # Clean shutdown
└── output/           # Created at runtime (SQLite databases)
```

## Next steps

| Want to... | Example repo |
|---|---|
| Add semantic search to your SaaS | [bonfyre-example-semantic-search](https://github.com/Nickgonzales76017/bonfyre-example-semantic-search) |
| Add transcription to your SaaS | [bonfyre-example-transcribe](https://github.com/Nickgonzales76017/bonfyre-example-transcribe) |
| Compress your API responses | [bonfyre-example-compress](https://github.com/Nickgonzales76017/bonfyre-example-compress) |
| OpenAI-compatible API (drop-in) | `bonfyre-proxy serve --port 8787` — [main repo](https://github.com/Nickgonzales76017/bonfyre) |

## License

MIT — same as [Bonfyre](https://github.com/Nickgonzales76017/bonfyre).
