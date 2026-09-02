# Security Policy

## Supported Versions

| Version | Supported |
| ------- | --------- |
| 1.0.x   | ✅ Yes    |

## Reporting a Vulnerability

If you discover a security vulnerability in ShilpSetu AI, please report it responsibly.

**Do NOT open a public GitHub issue for security vulnerabilities.**

Instead, contact the team directly via email or GitHub private messaging.

---

## Security Best Practices for Contributors

### Never commit:
- `.env` files containing real credentials
- MongoDB URIs with passwords
- JWT secrets or signing keys
- AI API keys (Gemini, OpenAI, HuggingFace, etc.)
- Firebase private keys or `google-services.json` with production credentials
- AWS / GCP / Azure credentials
- Personal access tokens or OAuth secrets

### Always:
- Use `.env.example` with placeholder values for documentation
- Verify `.gitignore` includes `.env` before committing
- Use `git check-ignore -v .env` to confirm the file is ignored
- Rotate any accidentally exposed secrets immediately

### Environment File Discipline
```bash
# Check if .env is properly ignored
git check-ignore -v .env
git check-ignore -v backend/.env

# See what is currently tracked
git ls-files | grep ".env"

# Remove accidentally tracked .env from index (safe — does not delete local file)
git rm --cached .env
git rm --cached backend/.env
```

---

## Production Deployment Checklist

- [ ] All secrets stored in environment variables or secret manager
- [ ] `NODE_ENV=production` set
- [ ] JWT_SECRET is a long random string (≥ 64 chars)
- [ ] MongoDB connection uses TLS
- [ ] CORS `CLIENT_URL` points to specific production domain (not `*`)
- [ ] Rate limiting configured
- [ ] Helmet security headers enabled (already configured)
