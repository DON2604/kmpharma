# Docker / Podman Deployment Guide for Med Backend

This guide documents the **exact workflow used to build, tag, push, pull, and run** the Med Backend image using **Podman** and **Docker Hub**.

---

## Prerequisites

* Podman or Docker installed
* Docker Hub account
* `.env` file with required environment variables

---

## Environment Setup

1. **Create your `.env` file**

```bash
cp .env.example .env
```

2. **Edit `.env`** with valid values:

* `DATABASE_URL`
* `BACKBLAZE_KEY`
* `BACKBLAZE_KEYID`
* `ENDPOINT_URL`
* `BUCKET`
* `GEMINI_API_KEY`

---

## Step 1 — Build the Image (Podman)

```bash
podman build -t med-backend:latest .
```

Podman automatically names this as:

```
localhost/med-backend:latest
```

Verify:

```bash
podman images
```

You should see:

```
localhost/med-backend   latest   <IMAGE_ID>
```

---

## Step 2 — Tag for Docker Hub

Tag the local image with the **full Docker Hub registry path**:

```bash
podman tag localhost/med-backend:latest docker.io/dawn2604/kmpharma:latest
```

Verify:

```bash
podman images
```

You should now see:

```
docker.io/dawn2604/kmpharma   latest   <IMAGE_ID>
```

---

## Step 3 — Push to Docker Hub

```bash
podman login docker.io
podman push docker.io/dawn2604/kmpharma:latest
```

Your image is now live on Docker Hub.

---

## Step 4 — Pull from Docker Hub

```bash
podman pull docker.io/dawn2604/kmpharma:latest
```

---

## Step 5 — Run the Container

```bash
podman run -d \
  --name med-backend \
  -p 8000:8000 \
  --env-file .env \
  docker.io/dawn2604/kmpharma:latest
```

---

## Container Management

### Check running containers

```bash
podman ps
```

### View logs

```bash
podman logs -f med-backend
```

### Stop & remove

```bash
podman stop med-backend
podman rm med-backend
```

---

## Testing

```bash
curl http://localhost:8000/
```

Expected:

```json
{"message": "Welcome to Med Backend Services"}
```

---

## Troubleshooting

### Logs

```bash
podman logs med-backend
```

### Verify env variables

```bash
podman exec med-backend env | grep DATABASE_URL
```

### Rebuild clean

```bash
podman build --no-cache -t med-backend:latest .
```

---

## Production Notes

* Avoid `latest` in production
* Use secrets managers
* Add resource limits
* Use HTTPS with reverse proxy

---

## Example Production Run

```bash
podman run -d \
  --name med-backend \
  -p 8000:8000 \
  --env-file .env \
  --memory="512m" \
  --cpus="1.0" \
  --restart=unless-stopped \
  docker.io/dawn2604/kmpharma:latest
```

