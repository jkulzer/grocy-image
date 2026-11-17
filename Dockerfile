FROM alpine:3.22 AS fetch
# renovate: datasource=github-release-attachments depName=grocy/grocy
ARG GROCY_VERSION=v4.7.1
ARG GROCY_SHA256=c4a10e96ed76664baf465e9b27dc7a31aa08c0e3ad876afdfae4f1ff9ab2fc19
RUN apk add --no-cache curl unzip \
 && curl -fsSL -o /tmp/grocy.zip \
      "https://github.com/grocy/grocy/releases/download/${GROCY_VERSION}/grocy_${GROCY_VERSION#v}.zip" \
 && echo "${GROCY_SHA256}  /tmp/grocy.zip" | sha256sum -c - \
 && mkdir /app && unzip -q /tmp/grocy.zip -d /app \
 && chmod -R go-w,a+rX /app

FROM dunglas/frankenphp:1-php8.5-alpine
RUN install-php-extensions gd intl opcache \
 && setcap -r /usr/local/bin/frankenphp
COPY Caddyfile /etc/frankenphp/Caddyfile
COPY grocy.ini $PHP_INI_DIR/conf.d/zz-grocy.ini
COPY --from=fetch /app /app
RUN mkdir -p /app/data && chown 65532:65532 /app/data
ENV XDG_DATA_HOME=/tmp/caddy/data XDG_CONFIG_HOME=/tmp/caddy/config
HEALTHCHECK NONE
USER 65532:65532
EXPOSE 8080
