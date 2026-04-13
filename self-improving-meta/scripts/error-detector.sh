#!/bin/bash
# Meta Self-Improvement Error Detector Hook
# Triggers on PostToolUse for Bash to detect infrastructure errors
# Reads CLAUDE_TOOL_OUTPUT environment variable

set -e

OUTPUT="${CLAUDE_TOOL_OUTPUT:-}"

ERROR_PATTERNS=(
    "hook"
    "skill"
    "SKILL.md"
    "AGENTS.md"
    "SOUL.md"
    "TOOLS.md"
    "MEMORY.md"
    "CLAUDE.md"
    "frontmatter"
    "yaml"
    "metadata"
    "not found"
    "failed to load"
    "context length"
    "token limit"
    "truncated"
    "conflict"
    "deprecated"
    "stale"
    "malformed"
)

contains_error=false
for pattern in "${ERROR_PATTERNS[@]}"; do
    if [[ "$OUTPUT" == *"$pattern"* ]]; then
        contains_error=true
        break
    fi
done

if [ "$contains_error" = true ]; then
    cat << 'EOF'
<meta-error-detected>
An infrastructure-related term was detected in command output. Consider logging to .learnings/ if:
- Prompt file instruction was misinterpreted → LEARNINGS.md (instruction_ambiguity)
- Hook script failed or produced no output → META_ISSUES.md [META-YYYYMMDD-XXX]
- Skill didn't activate when it should have → META_ISSUES.md with skill_gap area
- Rules conflict across files → LEARNINGS.md (rule_conflict)
- Context was truncated or token limit hit → LEARNINGS.md (context_bloat)
- Memory entry references stale or deleted content → LEARNINGS.md (prompt_drift)

Meta-learnings modify infrastructure directly. Apply fixes to the affected files.
</meta-error-detected>
EOF
fi
