#!/bin/bash
# Engineering Error Detector Hook
# Triggers on PostToolUse for Bash to detect build/test/deploy failures
# Reads CLAUDE_TOOL_OUTPUT environment variable

set -e

OUTPUT="${CLAUDE_TOOL_OUTPUT:-}"

ERROR_PATTERNS=(
    "build failed"
    "Build failed"
    "BUILD FAILED"
    "test failed"
    "Test failed"
    "FAIL "
    "DEPRECATED"
    "vulnerability"
    "CVE-"
    "breaking change"
    "regression"
    "timeout"
    "Timeout"
    "OOM"
    "out of memory"
    "memory leak"
    "error:"
    "Error:"
    "ERROR:"
    "fatal:"
    "FATAL:"
    "npm ERR!"
    "gyp ERR!"
    "ModuleNotFoundError"
    "SyntaxError"
    "TypeError"
    "ReferenceError"
    "Traceback"
    "Exception"
    "exit code"
    "non-zero"
    "command not found"
    "No such file"
    "Permission denied"
    "ECONNREFUSED"
    "ENOTFOUND"
    "ENOMEM"
    "Segmentation fault"
    "core dumped"
    "stack overflow"
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
<engineering-error-detected>
A build/test/deploy error was detected. Consider logging to .learnings/ if:
- Build failure with non-obvious cause → ENGINEERING_ISSUES.md [ENG-YYYYMMDD-XXX]
- Test failure revealing a gap → LEARNINGS.md with testing_gap category
- Dependency vulnerability flagged → ENGINEERING_ISSUES.md with CVE details
- Performance issue surfaced → ENGINEERING_ISSUES.md with metrics
- Architecture violation triggered the error → LEARNINGS.md with architecture_debt

Include: error output, environment details, root cause, and suggested fix.
</engineering-error-detected>
EOF
fi
