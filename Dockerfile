# Dockerfile
ARG RUBY_VERSION=3.2.2
FROM registry.docker.com/library/ruby:$RUBY_VERSION-alpine as base

ARG APP_ROOT=/app
ARG BUNDLE_PATH="vendor/bundle"
WORKDIR $APP_ROOT

RUN mkdir -p $APP_ROOT

# Set production environment
ENV BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH=$BUNDLE_PATH \
    BUNDLE_WITHOUT="development"

FROM base as build

ARG BUILD_PACKAGES="build-base curl-dev git curl"
ARG DEV_PACKAGES="gcompat sqlite"
ARG RUBY_PACKAGES="tzdata"

RUN apk update \
    && apk upgrade \
    && apk add --update --no-cache $BUILD_PACKAGES $DEV_PACKAGES $RUBY_PACKAGES

# WORKDIR $APP_ROOT

COPY Gemfile* ./
RUN bundle install  && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

ENV USER=vlad
ENV UID=12345
ENV GID=23456

# Run and own only the runtime files as a non-root user for security
# https://stackoverflow.com/questions/49955097/how-do-i-add-a-user-when-im-using-alpine-as-a-base-image
RUN addgroup \
  --gid $GID \
  $USER

RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "$(pwd)" \
    --ingroup "$USER" \
    --no-create-home \
    --uid "$UID" \
    "$USER"

COPY db.rb .
COPY app.rb .
COPY config config/
COPY config.ru .
COPY fonts fonts/
COPY public public/
COPY views views/
COPY stardeveloper.db .

EXPOSE 9292

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
