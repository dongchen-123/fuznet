#!/usr/bin/env bash
# Arguments: 1: synth_top, 2: impl_top, 3: out, 4: log_dir (optional)
# Returns: 0 on pass, 1 on failure, 2 on unknown state, 3 on timeout

run_miter() {
    local out=$1
    local synth_top=$2
    local impl_top=$3
    local log_dir=${4:-"$out/logs"}

    info "Running miter for equivalence check"

    local miter_log="$log_dir/miter.log"
    local miter_ret=0

    ./scripts/quartus_yosysify.sh "$out/$synth_top.v" "$out/${synth_top}_yosys.v"
    ./scripts/quartus_yosysify.sh "$out/$impl_top.v" "$out/${impl_top}_yosys.v"

    yosys -p "read_verilog $PRIMS_V $out/${synth_top}_yosys.v $out/${impl_top}_yosys.v; \
        miter -equiv $synth_top $impl_top miter; hierarchy -top miter; flatten; \
        proc; opt_clean; clk2fflogic; \
        sat -seq 20 -set-init-zero -prove trigger 0 miter" \
        > "$log_dir/miter.log" 2>&1 || miter_ret=$?

    local miter_token=$(grep -oE 'SUCCESS!|FAIL!|TIMEOUT!' "$miter_log" || echo "UNKNOWN")

    case "$miter_token" in
        "SUCCESS!") pass  "Miter check passed"        ; return 0 ;;
        "FAIL!")    fail  "Miter check failed"        ; return 1 ;;
        "TIMEOUT!") warn  "Miter check timed out"     ; return 3 ;;
        *)            fail  "Miter check unknown state" ; return 2 ;;
    esac
}