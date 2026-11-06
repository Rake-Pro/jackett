# jackett

Jackett on the shared [alpine-base](https://github.com/Rake-Pro/alpine-base) image, built in-house from the upstream release.

```
ghcr.io/rake-pro/jackett
```

## Tags / releases

| Tag | Meaning |
| --- | --- |
| `X.Y.Z` | Immutable release, built from git tag `vX.Y.Z` |
| `X.Y` | Latest patch of that minor |
| `latest` | Latest release |
| `<upstream-version>` | The exact upstream Jackett version baked into that release (currently `v0.24.3021`) |
| `sha-<short>` | Commit the image was built from |

- `dev` is the integration branch (default); `ci.yml` builds, smoke-tests and Trivy-scans on every push and PR.
- `version-check.yml` polls upstream daily and opens a PR into `dev` bumping the pinned `VERSION` build arg.
- `sync-main.yml` opens a promotion PR from `dev` to `main`. Merging it (merge commit) mints the next patch tag and `release.yml` builds, scans and pushes the image. A fixable CRITICAL finding blocks the push.
- Label the promotion PR `release:minor` or `release:major` to change the bump.
- `trivy-rescan.yml` re-scans the released image weekly (CRITICAL+HIGH) so CVEs disclosed after release still surface.
- Dependabot bumps the base image digest and the GitHub Actions weekly.
- Pin `X.Y.Z` in deployments; `latest` is a convenience pointer.

## Image facts

| Item | Value |
| --- | --- |
| Base | `ghcr.io/rake-pro/alpine-base` (Alpine, patched weekly) |
| Init | `catatonit` as PID 1 |
| User | `65534:65534` from the first process (no s6, no privilege drop, no added capabilities) |
| Data | `/config/Jackett` (ServerConfig.json, Indexers/, logs) |
| Port | `9117` |
| Upstream | <https://github.com/Jackett/Jackett> |
| Upstream version | `v0.24.3021` (build arg `VERSION`) |
| Platform | linux/amd64 |

## Run

```
docker run -d --name jackett \
  -p 9117:9117 \
  -v /path/to/config:/config \
  ghcr.io/rake-pro/jackett:latest
```

- The `/config` mount must be writable by uid 65534 (`chown -R 65534:65534 /path/to/config`).

## Notes

- Started with `--NoUpdates --ListenPublic --DataFolder /config/Jackett`; in-app updates are off, bump the image instead.
- Upstream publishes near-daily; the version check opens one PR per release.
