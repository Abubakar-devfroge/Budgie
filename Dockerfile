ARG ELIXIR_VERSION=1.19.1
ARG OTP_VERSION=28.1.1
ARG DEBIAN_VERSION=trixie-20260112-slim

ARG BUILDER_IMAGE="docker.io/hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}"
ARG RUNNER_IMAGE="docker.io/debian:${DEBIAN_VERSION}"

############################
# Builder stage
############################
FROM ${BUILDER_IMAGE} AS builder

# Install build dependencies (IMPORTANT: ca-certificates)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    curl \
    ca-certificates \
 && update-ca-certificates \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

ENV MIX_ENV=prod

# Install Hex + Rebar
RUN mix local.hex --force && mix local.rebar --force

# Install Elixir deps
COPY mix.exs mix.lock ./
RUN mix deps.get --only prod

COPY config/config.exs config/prod.exs config/
RUN mix deps.compile

# --- ASSETS (Phoenix recommended order) ---

COPY assets assets
RUN mix assets.deploy

# --- APP CODE ---

COPY priv priv
COPY lib lib
RUN mix compile

COPY config/runtime.exs config/
COPY rel rel
RUN mix release

############################
# Runtime stage
############################
FROM ${RUNNER_IMAGE} AS final

RUN apt-get update && apt-get install -y --no-install-recommends \
    libstdc++6 \
    openssl \
    libncurses6 \
    locales \
    ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    MIX_ENV=prod

WORKDIR /app
RUN chown nobody /app

COPY --from=builder --chown=nobody:root /app/_build/prod/rel/first ./

USER nobody

CMD ["/app/bin/first", "start"]
