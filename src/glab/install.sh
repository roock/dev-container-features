#!/usr/bin/env bash
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
    echo "This feature must be installed as root." >&2
    exit 1
fi

# Install download prerequisites even on distributions using the binary fallback.
packages=(ca-certificates tar)
if ! command -v curl >/dev/null 2>&1; then
    packages+=(curl)
fi
if command -v apt-get >/dev/null 2>&1; then
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y --no-install-recommends "${packages[@]}"
elif command -v dnf >/dev/null 2>&1; then
    dnf install -y "${packages[@]}"
elif command -v yum >/dev/null 2>&1; then
    yum install -y "${packages[@]}"
elif command -v apk >/dev/null 2>&1; then
    apk add --no-cache "${packages[@]}"
fi

for tool in curl tar; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "The glab installer requires ${tool}; install it before using this feature." >&2
        exit 1
    fi
done

case "$(uname -m)" in
    x86_64) arch="amd64" ;;
    aarch64 | arm64) arch="arm64" ;;
    i386 | i686) arch="386" ;;
    armv6l) arch="armv6" ;;
    armv7l) arch="armv7" ;;
    *)
        echo "Unsupported glab architecture: $(uname -m)" >&2
        exit 1
        ;;
esac

release_url="$(curl --fail --silent --show-error --location \
    --output /dev/null --write-out '%{url_effective}' \
    https://gitlab.com/gitlab-org/cli/-/releases/permalink/latest)"
tag="${release_url##*/}"
if [[ ! "$tag" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Unable to resolve the latest glab release: ${tag}" >&2
    exit 1
fi
version="${tag#v}"

ID=""
ID_LIKE=""
if [ -r /etc/os-release ]; then
    . /etc/os-release
fi

format="tar.gz"
if [[ " ${ID} ${ID_LIKE} " == *" debian "* || "$ID" == "ubuntu" ]] \
    && command -v apt-get >/dev/null 2>&1; then
    format="deb"
elif [[ " ${ID} ${ID_LIKE} " =~ [[:space:]](fedora|rhel|centos)[[:space:]] ]] \
    && { command -v dnf >/dev/null 2>&1 || command -v yum >/dev/null 2>&1; }; then
    format="rpm"
fi

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT
asset="glab_${version}_linux_${arch}.${format}"
curl --fail --silent --show-error --location \
    "https://gitlab.com/gitlab-org/cli/-/releases/${tag}/downloads/${asset}" \
    --output "${tmp_dir}/${asset}"

case "$format" in
    deb)
        apt-get install -y --no-install-recommends "${tmp_dir}/${asset}"
        ;;
    rpm)
        if command -v dnf >/dev/null 2>&1; then
            dnf install -y "${tmp_dir}/${asset}"
        else
            yum install -y "${tmp_dir}/${asset}"
        fi
        ;;
    tar.gz)
        tar -xzf "${tmp_dir}/${asset}" -C "$tmp_dir" bin/glab
        mkdir -p /usr/local/bin
        install -m 0755 "${tmp_dir}/bin/glab" /usr/local/bin/glab
        ;;
esac

glab --version
