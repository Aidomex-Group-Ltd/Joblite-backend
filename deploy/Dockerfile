# syntax=docker/dockerfile:1
#
# Joblite product release images.
#
# Context MUST be the workspace parent that contains both sibling repositories
#   <workspace>/backend   (:joblite_core)
#   <workspace>/frontend  (:joblite_web, assembles the `joblite` release)
# Use backend/deploy/build-images.sh as the documented entry point.
#
# Targets:
#   backend   - one-off maintenance image (migrations etc.) over the release
#   liveview  - product image serving Phoenix + LiveView (default target)

ARG ELIXIR_IMAGE=hexpm/elixir:1.20.4-erlang-28.5.0.8-debian-bookworm-20261020-slim
ARG DEBIAN_IMAGE=debian:bookworm-slim

# ---------------------------------------------------------------------------
# build: compiles :joblite_core + :joblite_web and assembles the `joblite`
# release with MIX_ENV=prod. Never shipped; compilers stay out of runtime.
# ---------------------------------------------------------------------------
FROM ${ELIXIR_IMAGE} AS build

# build-essential compiles native libraries (bcrypt_elixir NIF via elixir_make).
RUN apt-get update \
 && apt-get install -y --no-install-recommends build-essential ca-certificates \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app
ENV MIX_ENV=prod LANG=C.UTF-8

# Dependency manifests first so the dependency layer caches across source edits.
# The frontend mix.lock is the integrated application's dependency resolution
# (Mix ignores a path dependency's own lockfile).
COPY backend/mix.exs backend/mix.lock backend/.formatter.exs ./backend/
COPY frontend/mix.exs frontend/mix.lock frontend/.formatter.exs ./frontend/

RUN mix local.hex --force && mix local.rebar --force

WORKDIR /app/frontend
RUN mix deps.get --only prod

# Full source of both applications, then compile, production assets and release.
COPY backend ./backend
COPY frontend ./frontend

RUN mix deps.compile \
 && mix compile \
 && mix assets.setup \
 && mix assets.deploy \
 && mix release joblite

# ---------------------------------------------------------------------------
# runtime-base: the release artifact plus a minimal Debian userland.
# Non-root; no compilers, no source checkouts, no Mix.
# ---------------------------------------------------------------------------
FROM ${DEBIAN_IMAGE} AS runtime-base

RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl libstdc++6 openssl \
 && rm -rf /var/lib/apt/lists/* \
 && groupadd --system --gid 10001 joblite \
 && useradd --system --uid 10001 --gid joblite --home-dir /app --shell /usr/sbin/nologin joblite

WORKDIR /app
COPY --from=build --chown=joblite:joblite /app/frontend/_build/prod/rel/joblite/ ./

ENV HOME=/app \
    LANG=C.UTF-8 \
    RELEASE_DISTRIBUTION=none
USER joblite

# ---------------------------------------------------------------------------
# backend: maintenance image. Same release artifact, never starts the HTTP
# endpoint (JOBLITE_ROLE=maintenance). Invoked as a one-off container, e.g.
#   docker run --rm joblite-backend:<id> eval 'JobliteWeb.Release.migrate()'
# ---------------------------------------------------------------------------
FROM runtime-base AS backend

ENV JOBLITE_ROLE=maintenance
ENTRYPOINT ["/app/bin/joblite"]
CMD ["help"]

# ---------------------------------------------------------------------------
# liveview: product image. Serves the Phoenix endpoint and LiveView WebSocket.
# ---------------------------------------------------------------------------
FROM runtime-base AS liveview

ENV PORT=4000
EXPOSE 4000
HEALTHCHECK --interval=15s --timeout=3s --start-period=20s \
  CMD curl -fsS "http://127.0.0.1:${PORT:-4000}/health/live" >/dev/null || exit 1
ENTRYPOINT ["/app/bin/joblite"]
CMD ["start"]
