# syntax=docker/dockerfile:1

# Jackett on the shared Alpine base, rootless from the first process. Upstream
# ships a self-contained .NET build for linux-musl-x64; the image adds only the
# native libraries that runtime loads. VERSION is the upstream release tag.
FROM ghcr.io/rake-pro/alpine-base:1.0@sha256:13603c44f47bc2163846b1959d16987bc4b85e2fd2fe07d4a0bc618755e8fedb AS fetch
ARG VERSION="v0.24.3082"
RUN apk add --no-cache curl \
    && mkdir -p /out/bin \
    && curl -fsSL -o /tmp/app.tgz \
        "https://github.com/Jackett/Jackett/releases/download/${VERSION}/Jackett.Binaries.LinuxMuslAMDx64.tar.gz" \
    && tar -xzf /tmp/app.tgz -C /out/bin --strip-components=1 \
    && rm -rf /out/bin/JackettUpdater* /tmp/app.tgz \
    && chmod -R u=rwX,go=rX /out

FROM ghcr.io/rake-pro/alpine-base:1.0@sha256:13603c44f47bc2163846b1959d16987bc4b85e2fd2fe07d4a0bc618755e8fedb
ARG VERSION
LABEL org.opencontainers.image.source="https://github.com/Rake-Pro/jackett" \
      org.opencontainers.image.version="${VERSION}"

ENV HOME="/config" \
    XDG_CONFIG_HOME="/config" \
    DOTNET_EnableDiagnostics=0

RUN apk add --no-cache \
        icu-data-full \
        icu-libs \
        libintl

COPY --from=fetch /out /app
COPY --chmod=0755 entrypoint.sh /entrypoint.sh

USER 65534:65534
WORKDIR /config
VOLUME ["/config"]
EXPOSE 9117

ENTRYPOINT ["/usr/bin/catatonit", "--", "/entrypoint.sh"]
