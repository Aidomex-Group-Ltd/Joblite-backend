# Joblite backend

OTP app: `:joblite_core`. Public domain namespace: `Joblite`.
This is the business and PostgreSQL side of one Phoenix monolith, not a standalone HTTP API.

Read `docs/DEVELOPMENT_HANDBOOK.md`, `docs/PHASES.md`, `docs/STATUS.md` and `AGENTS.md`.
The paired web repo must be a sibling at `../frontend`.

Start checks after installing the pinned runtime:

```bash
mix deps.get
mix format
mix test
elixir scripts/check_architecture.exs
```

No dependency lockfile or executed Elixir test result is included yet. Core standalone
tests initially disable Repo startup. Follow P02 before adding database tests.
