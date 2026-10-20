# Source and verification status

Date: 20 October 2026. Architecture revision: 2.0.

## Prepared

- Two source trees with separate Mix application identities and a sibling dependency.
- One-release definition, core Repo, PubSub, health boundary and frontend endpoint.
- Minimal connected LiveView teaching slice and pure application-stage rule examples.
- Core rule tests and a connected LiveView test, authored but not executed.
- Development handbook, atomic phases, reusable prompt and handoff templates.
- Non-overwriting installer for the requested Linux layout.
- Two local Git repositories initialized inside the deliverable kit, without commits or remotes.

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

## Not established

- Resolved dependencies or either mix.lock; no lockfile was fabricated.
- Elixir formatting, compilation, ExUnit/LiveView tests, PostgreSQL integration or release boot.
- Authentication, tenant isolation, ATS persistence, AI behavior or production readiness.
- GitHub remotes or published repositories.

The authoring session runs on Windows. The requested Linux destination is not mounted.
The local Elixir/Mix executable failed with `Cannot find erlexec.dll` before application
compilation. This is an environment blocker, not proof that the authored source works
or fails. Run P01 on the actual host and repair/review any source issues found there.

Initial test configuration deliberately does not start Repo. P02 must enable a dedicated
test database and Sandbox helpers before database-dependent tests are accepted.

## Next actions

1. ~~Install safely on the intended host; verify the two Git roots and preserve legacy files.~~ Done; see `docs/iterations/P00.md`.
2. Complete P01.01: verify the pinned toolchain can execute.
3. Resolve dependencies, format, compile and execute the authored tests under P01.
4. Record actual command results and compatible commits before marking any phase verified.

See VALIDATION.md for packaging/static checks completed in the authoring session.
