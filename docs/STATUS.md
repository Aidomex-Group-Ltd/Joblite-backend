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

## Not established

- PostgreSQL development/test databases, migrations, Sandbox test helpers (P02).
- Release boot with real runtime credentials (P11 gate).
- Authentication, tenant isolation, ATS persistence, AI behavior or production readiness.
- GitHub remotes or published repositories.

## Next actions

1. ~~Install safely on the intended host; verify the two Git roots and preserve legacy files.~~ Done; see `docs/iterations/P00.md`.
2. ~~Complete P01.01: verify the pinned toolchain can execute.~~ Done.
3. ~~Resolve dependencies, format, compile and execute the authored tests under P01.~~ Done.
4. ~~Record actual command results and compatible commits before marking any phase verified.~~ Done for P00/P01.
5. P02.01: create isolated development and test databases. The host PostgreSQL 14
   already occupies TCP 5432, so the `compose.yaml` 127.0.0.1:5432 mapping conflicts;
   decide the documented local strategy with evidence before touching any data.

See VALIDATION.md for packaging/static checks completed in the authoring session.
