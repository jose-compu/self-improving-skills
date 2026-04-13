#!/bin/bash
# Supply Chain Self-Improvement Error Detector Hook
# Triggers on PostToolUse for Bash to detect supply chain disruptions and issues
# Reads CLAUDE_TOOL_OUTPUT environment variable

set -e

OUTPUT="${CLAUDE_TOOL_OUTPUT:-}"

ERROR_PATTERNS=(
    "stockout"
    "backorder"
    "delay"
    "shortage"
    "defect"
    "rejection"
    "recall"
    "overstock"
    "expired"
    "lead time"
    "capacity"
    "forecast"
    "variance"
    "disruption"
    "out of stock"
    "back order"
    "stock-out"
    "safety stock"
    "reorder point"
    "fill rate"
    "on-time delivery"
    "quality hold"
    "inspection fail"
    "shipping delay"
    "port congestion"
    "customs hold"
    "freight"
    "demurrage"
    "detention"
    "mismatch"
    "shrinkage"
    "cycle count"
    "inventory variance"
    "supplier fail"
    "MAPE"
    "understock"
    "allocation"
    "constraint"
    "bottleneck"
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
<supply-chain-disruption-detected>
A supply chain issue was detected in command output. Consider logging to .learnings/ if:
- Stockout or backorder requires investigation → SUPPLY_CHAIN_ISSUES.md [SCM-YYYYMMDD-XXX]
- Delivery delay with non-obvious root cause → SUPPLY_CHAIN_ISSUES.md (logistics_delay)
- Supplier issue signals risk pattern → LEARNINGS.md (supplier_risk)
- Quality rejection above threshold → SUPPLY_CHAIN_ISSUES.md (quality_deviation)
- Forecast variance reveals model gap → LEARNINGS.md (forecast_error)
- Demand shift not captured by planning → LEARNINGS.md (demand_signal_shift)

Include impact metrics (units, cost, days affected). Specify area tag.
</supply-chain-disruption-detected>
EOF
fi
