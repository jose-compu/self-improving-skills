#!/bin/bash
# Security Self-Improvement Error Detector Hook
# Triggers on PostToolUse for Bash to detect security-relevant patterns
# Reads CLAUDE_TOOL_OUTPUT environment variable

set -e

OUTPUT="${CLAUDE_TOOL_OUTPUT:-}"

SECURITY_PATTERNS=(
    "CVE-"
    "vulnerability"
    "CRITICAL"
    "unauthorized"
    "Unauthorized"
    "forbidden"
    "Forbidden"
    "secret"
    "token"
    "password"
    "credential"
    "injection"
    "XSS"
    "CSRF"
    "SSL"
    "certificate expired"
    "certificate verify failed"
    "Permission denied"
    "Access denied"
    "authentication failed"
    "auth failure"
    "invalid token"
    "expired token"
    "CORS"
    "insecure"
    "plaintext"
    "unencrypted"
    "privilege escalation"
    "brute force"
    "rate limit"
    "SQL error"
    "command injection"
    "path traversal"
    "directory traversal"
    "open redirect"
    "ssrf"
    "SSRF"
    "XXE"
    "deserialization"
)

contains_security_pattern=false
matched_pattern=""
for pattern in "${SECURITY_PATTERNS[@]}"; do
    if [[ "$OUTPUT" == *"$pattern"* ]]; then
        contains_security_pattern=true
        matched_pattern="$pattern"
        break
    fi
done

if [ "$contains_security_pattern" = true ]; then
    cat << EOF
<security-finding-detected>
Security-relevant pattern detected in command output: "$matched_pattern"

Consider logging to .learnings/ if:
- A vulnerability or CVE was identified
- Secrets or credentials appeared in output (REDACT before logging)
- An access control or authentication issue was revealed
- A misconfiguration or insecure default was found
- A compliance-relevant finding was discovered

CRITICAL: NEVER log actual secrets, credentials, tokens, or PII.
Use REDACTED_* placeholders. Describe the type, not the content.

Format: [SEC-YYYYMMDD-XXX] for incidents, [LRN-YYYYMMDD-XXX] for learnings.
</security-finding-detected>
EOF
fi
