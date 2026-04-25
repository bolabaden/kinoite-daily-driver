# Optional: gitleaks for this workspace

If you `git init` here and ever commit **sanitized** exports only:

```bash
# example — install gitleaks per upstream docs, then:
gitleaks detect --source . -v
```

The root `.gitignore` already ignores typical `imports/` exports.
