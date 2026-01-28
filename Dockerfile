ARG ELIXIR_VERSION=1.19.1
ARG OTP_VERSION=28.1.1
ARG DEBIAN_VERSION=trixie-20260112-slim

ARG BUILDER_IMAGE="docker.io/hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}"
ARG RUNNER_IMAGE="docker.io/debian:${DEBIAN_VERSION}"

FROM ${BUILDER_IMAGE} AS builder

# 1. Install Node.js and build dependencies
# We add 'curl' to get the NodeSource script
RUN apt-get update \
  && apt-get install -y --no-install-recommends build-essential git curl \
  && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
  && apt-get install -y nodejs \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN mix local.hex --force \
  && mix local.rebar --force

ENV MIX_ENV="prod"

COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mkdir config

COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

# 2. Handle NPM assets before running mix assets.deploy
# We copy package files and run npm install first
COPY assets/package.json assets/package-lock.json ./assets/
RUN npm install --prefix assets

COPY priv priv
COPY lib lib
COPY assets assets

# This will now use the 'npx' command we put in your mix.exs aliases
RUN mix compile
RUN mix assets.deploy

COPY config/runtime.exs config/
COPY rel rel
RUN mix release

FROM ${RUNNER_IMAGE} AS final

RUN apt-get update \
  && apt-get install -y --no-install-recommends libstdc++6 openssl libncurses6 locales ca-certificates \
  && rm -rf /var/lib/apt/lists/*

RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
  && locale-gen

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

WORKDIR "/app"
RUN chown nobody /app

ENV MIX_ENV="prod"

# NOTE: Ensure 'first' matches your actual app name in mix.exs
COPY --from=builder --chown=nobody:root /app/_build/${MIX_ENV}/rel/first ./

USER nobody

CMD ["/app/bin/server"]