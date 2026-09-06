# parrotos-terminal-railway

Railway wrapper image for a ParrotOS Security Edition browser terminal (ttyd).

- Base image pinned by digest, ttyd pinned to 1.7.7.
- `USERNAME` baked (default `admin`); `PASSWORD` must be supplied or the
  container exits 1 rather than serving an unauthenticated root shell.
- Home directory is `/root`, which is where the Railway volume is mounted; a
  pristine copy of the image's home skeleton lives at `/opt/root-skel` and is
  restored for any entry the volume hides.

Published as `ghcr.io/bon5co/parrotos-terminal-railway:security`.
