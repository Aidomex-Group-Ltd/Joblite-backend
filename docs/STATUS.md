# Source and verification status

Date: 20 October 2026. Architecture revision: 2.0.

## Prepared

- Two source trees with separate Mix application identities and a sibling dependency.
- One-release definition, core Repo, PubSub, health boundary and frontend endpoint.
- Minimal connected LiveView teaching slice and pure application-stage rule examples.
- Core rule tests and a connected LiveView test (authored in the kit; executed and
  passing on the Linux host under P01).
- Development handbook, atomic phases, reusable prompt and handoff templates.
- Non-overwriting installer for the requested Linux layout.
- Two local Git repositories (initialized by the installing session on the host;
  the packaged kit itself contained no `.git` directories).

## Installed on the Linux host (20 October 2026, implementation session)

- `/home/aidomex/Joblite/backend` and `/home/aidomex/Joblite/frontend` populated from
  the extracted kit by a controlled copy (destinations verified empty first; the
  installer was inspected and not used because it refuses existing directories).
- Two independent Git roots on `main`, no parent repository, no remotes. Legacy
  `~/joblite-release` and `~/joblite-www` untouched.
- P00 evidence: `docs/iterations/P00.md`, `docs/ADR-0001-two-sibling-repos-one-release.md`,
  ledger `docs/IMPLEMENTATION_STATE.json`.
- Host toolchain present: Elixir 1.20.2/OTP 28 via asdf, PostgreSQL 14 client/server,
  Node 22. Exact runtime pin verification is P01.01.

## Verified on the Linux host (implementation session, 20 October 2026)

- P00 (workspace/ADR/docs/foundation): verified. Evidence `docs/iterations/P00.md`.
- P01.01 pinned runtime: Elixir 1.20.4-otp-28 / Erlang 28.5 execute in both repos
  (installed the missing Elixir pin via asdf).
- P01.02 backend: real `mix.lock` (ecto_sql 3.14.0, ecto 3.14.2, postgrex 0.22.4,
  phoenix_pubsub 2.4.1); format/compile-with-warnings-as-errors/3 tests/`mix check`
  pass. Fixed the `check` alias env (`def cli` preferred_envs) exposed by Elixir 1.20.
- P01.03 frontend: real `mix.lock` (phoenix 1.8.16, phoenix_live_view 1.2.13,
  bandit 1.13.1, plug 1.20.3 + core path dep); format/compile/tests/`mix check` pass.
- P01.04 assets and connected UI: esbuild bundle built; headless-Chromium smoke
  (`frontend/scripts/browser_smoke.js`) proves LiveView WebSocket join, a working
  `phx-click` event and liveness; `/health/ready` correctly 503 without a database.
- P01.05 quality gates: Credo (both repos, 0 issues) wired into `mix check`;
  Sobelow 1 reviewed low-confidence finding (`Config.CSWH`, check_origin set in
  config); architecture smoke passes.
- P01.06 release: `MIX_ENV=prod mix release joblite` assembled one artifact
  containing core+web+digested assets, no sibling source paths in release config;
  `bin/joblite version` runs. Production boot remains a P11 gate.
- Compatible commits: backend `49510b1`, frontend `ca33fb6`. Full evidence:
  `docs/iterations/P01.md`.

## Verified on the Linux host (implementation session, 20 October 2026, continued)

- P02.01 databases: isolated postgres:18 on `127.0.0.1:5543` (host PostgreSQL 14
  owns 5432; `fsync=off` documented for this local-only volume after its first
  init stalled >220s and was recreated empty). `joblite_dev` + `joblite_test`
  exist; migration ledger empty (`schema_migrations`, 0 rows).
- P02.02 Sandbox helpers: Repo starts in all envs; `:manual` Sandbox mode;
  `Joblite.DataCase` (backend) and `JobliteWeb.ConnCase` (frontend) own
  connections per test; tests prove `current_database()=joblite_test`,
  ownership denial and `allow_runner` allowance.
- P02.03 readiness: `readiness/1` failure mapping tested (missing repo,
  unreachable port); live smoke `/health/live` 200, `/health/ready` 200 with DB
  (was 503 in P01), `/` 200; liveness independent of the database.
- P02.04 conventions: handbook §8 documents empty forward-only ledger, UUID
  PK/FK defaults from `config/shared.exs`, UTC timestamps, Sandbox rollback,
  composite FKs for tenant consistency; no speculative tables.
- Compatible commits: backend `1a34aa7`, frontend `e73633c`. Full evidence:
  `docs/iterations/P02.md`.

## Verified on the Linux host (implementation session, 20 October 2026, continued)

- P03.01 accounts foundation: first real migration
  (`20261020164000`, users + users_tokens, UUID PKs, unique lowercase email,
  FK delete_all, UTC timestamps); `Joblite.Accounts` core-only context
  (register/normalize/hash, session-token generate/verify/revoke with 60-day
  validity, hash-only storage); bcrypt_elixir 3.3.2 in core (+ frontend
  transitive lockfile); 11 new tests; 21 backend + 2 frontend tests pass.
- Compatible commits: backend `9431800`, frontend `93819b0`. Full evidence:
  `docs/iterations/P03.md`.

## Not established

- Login/logout HTTP or LiveView surface (P03.02); organizations, memberships
  and scoped roles (P03.03-P03.04).
- Tenant isolation, ATS persistence, AI behavior or production readiness.
- Release boot with real runtime credentials (P11 gate).
- GitHub remotes or published repositories.

## Next actions

1. ~~Install safely on the intended host; verify the two Git roots and preserve legacy files.~~ Done; see `docs/iterations/P00.md`.
2. ~~Complete P01.01: verify the pinned toolchain can execute.~~ Done.
3. ~~Resolve dependencies, format, compile and execute the authored tests under P01.~~ Done.
4. ~~Record actual command results and compatible commits before marking any phase verified.~~ Done for P00/P01.
5. ~~P02.01: create isolated development and test databases.~~ Done; port 5543
   chosen with evidence; see `docs/iterations/P02.md`.
6. ~~P03.01: Accounts schema, identity lookup and session token lifecycle.~~
   Done; see `docs/iterations/P03.md`.
7. P03.02: login/logout and LiveView authentication integration. HTTP and
   connected mount both validate the session; public/protected routes behave
   intentionally; raw session token enters the Phoenix session exactly once.

See VALIDATION.md for packaging/static checks completed in the authoring session.
