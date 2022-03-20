#
# Step 1 - build the OTP binary
#
FROM hexpm/elixir:1.13.3-erlang-24.2.2-alpine-3.15.0 AS otp-builder

ENV MIX_ENV=prod

WORKDIR /build

# Install Alpine dependencies
RUN apk update --no-cache && \
  apk upgrade --no-cache && \
  apk add --no-cache git build-base

# Install Erlang dependencies
RUN mix local.rebar --force && \
  mix local.hex --force

# Install dependencies
COPY mix.* ./
RUN mix deps.get --only prod && \
  mix deps.compile

# Compile codebase
COPY config config
COPY lib lib
COPY priv priv
RUN mix compile

# Build OTP release
RUN mix release

#
# Step 2 - build a lean runtime container
#
FROM alpine:3.15.0

ARG APP_NAME
ARG APP_VERSION

ENV APP_NAME=${APP_NAME} \
  APP_VERSION=${APP_VERSION}

# Install Alpine dependencies
RUN apk update --no-cache && \
  apk upgrade --no-cache && \
  apk add --no-cache bash shadow su-exec openssl libgcc libstdc++

WORKDIR /opt/boreale

# Copy OTP binary from step 1
COPY --from=otp-builder /build/_build/prod/${APP_NAME}-${APP_VERSION}.tar.gz .
RUN tar -xvzf ${APP_NAME}-${APP_VERSION}.tar.gz && \
  rm ${APP_NAME}-${APP_VERSION}.tar.gz

# Copy the entrypoint script
COPY docker-entrypoint.sh /usr/local/bin
RUN chmod a+x /usr/local/bin/docker-entrypoint.sh

COPY boreale-cli.sh bin/boreale-cli
RUN chmod u+x bin/boreale-cli

# Create a non-root user
RUN adduser -D boreale && chown -R boreale: /opt/boreale

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["start"]
