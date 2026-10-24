# dev-container-features
My custom dev container features (https://containers.dev)

## GitLab CLI (glab)

Installs the latest stable [glab release](https://gitlab.com/gitlab-org/cli/-/releases).
Use the feature in your `devcontainer.json`:

```json
{
    "features": {
        "ghcr.io/roock/dev-container-features/glab:1": {}
    }
}
```

Debian/Ubuntu and Fedora/RHEL-based distributions install the release's `.deb`
or `.rpm` package, respectively. Other Linux distributions install the release
binary to `/usr/local/bin/glab`. The installer requires Bash and root access;
it installs curl, CA certificates, and tar using apt, dnf, yum, or apk when
available. On other distributions, provide these prerequisites beforehand.
The release is resolved at installation time, not from distribution repositories.

To run the feature's container smoke tests with Docker and the Dev Container CLI:

```sh
devcontainer features test --project-folder . -f glab
```
