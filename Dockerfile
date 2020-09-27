# SEE https://hub.docker.com/r/nixos/nix/dockerfile
FROM alpine:3.12

# Enable HTTPS support in wget and set nsswitch.conf to make resolution work within containers
RUN apk add --no-cache --update openssl \
  && echo hosts: dns files > /etc/nsswitch.conf

# Download Nix and install it into the system.
ARG NIX_VERSION=2.3.6
RUN wget https://nixos.org/releases/nix/nix-${NIX_VERSION}/nix-${NIX_VERSION}-x86_64-linux.tar.xz \
  && tar xf nix-${NIX_VERSION}-x86_64-linux.tar.xz \
  && addgroup -g 30000 -S nixbld \
  && adduser -D -u 1000 -G nixbld ci \
  && for i in $(seq 1 30); do adduser -S -D -h /var/empty -g "Nix build user $i" -u $((30000 + i)) -G nixbld nixbld$i ; done \
  && mkdir -m 0755 /etc/nix \
  && echo 'sandbox = false' > /etc/nix/nix.conf \
  && mkdir -m 0755 /nix \
  && chown -R ci:nixbld /nix \
  && USER=ci sh nix-${NIX_VERSION}-x86_64-linux/install \
  && ln -s /nix/var/nix/profiles/default/etc/profile.d/nix.sh /etc/profile.d/ \
  && rm -r /nix-${NIX_VERSION}-x86_64-linux* \
  && rm -rf /var/cache/apk/* \
  && /nix/var/nix/profiles/default/bin/nix-collect-garbage --delete-old \
  && /nix/var/nix/profiles/default/bin/nix-store --optimise \
  && /nix/var/nix/profiles/default/bin/nix-store --verify --check-contents \
  && cp -r /nix/var/nix/profiles/per-user/root /nix/var/nix/profiles/per-user/ci \
  && chown -R ci:nixbld /nix/var/nix/profiles/per-user/ci \
  && ln -s /nix/var/nix/profiles/default /home/ci/.nix-profile \
  && chown -R ci:nixbld /nix/var/

USER ci
ONBUILD ENV \
    ENV=/etc/profile \
    USER=ci \
    PATH=/nix/var/nix/profiles/default/bin:/nix/var/nix/profiles/default/sbin:/bin:/sbin:/usr/bin:/usr/sbin \
    GIT_SSL_CAINFO=/etc/ssl/certs/ca-certificates.crt \
    NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt

ENV \
    ENV=/etc/profile \
    USER=ci \
    PATH=/nix/var/nix/profiles/default/bin:/nix/var/nix/profiles/default/sbin:/bin:/sbin:/usr/bin:/usr/sbin \
    GIT_SSL_CAINFO=/etc/ssl/certs/ca-certificates.crt \
    NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt \
    NIX_PATH=/nix/var/nix/profiles/per-user/root/channels
