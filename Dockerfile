# TODO: choose a base image.
#   - Use a Python 3.11 image, "slim" variant recommended (smaller, fewer
#     packages than the default image).

FROM python:3.11-slim AS builder

# TODO: set the working directory for the rest of the instructions below
#   (e.g. /app).

WORKDIR /app

# TODO: install dependencies.
#   - Copy ONLY requirements.txt first, then run pip install.
#   - Copying requirements.txt before the rest of the source means Docker
#     can reuse this layer from cache when only your source code changes,
#     instead of reinstalling every dependency on every build.
#   - Use `pip install --no-cache-dir -r requirements.txt` to avoid
#     bloating the image with pip's download cache.

COPY requirements.txt .
# No --user flag: --user installs to /root/.local, which is 0700 (root-only)
# on Debian and unreadable by the non-root user this image switches to below.
# Installing system-wide instead lands packages under /usr/local, which is
# world-readable (0755) by default.
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install --no-cache-dir -r requirements.txt

FROM python:3.11-slim

COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Dedicated non-privileged user/group with explicit numeric IDs.
# Kubernetes' securityContext (runAsUser/runAsGroup/runAsNonRoot) matches
# against numeric UIDs, not names — hardcode them here and reuse the same
# numbers in the Helm chart's securityContext.
RUN groupadd --gid 10001 appgroup && \
    useradd --uid 10001 --gid appgroup --no-create-home --shell /usr/sbin/nologin appuser

WORKDIR /app

# --chown sets ownership during the copy itself, avoiding a separate
# `RUN chown -R` layer that would double the image's file-copy cost.
COPY --chown=appuser:appgroup . .

EXPOSE 8000

USER 10001:10001

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
