run_impl() {
        local out=$1
        local synth_top=$2
        local impl_top=$3
        local clk_period=${4:-10.000}
        local fuzed_top=${5:-"fuzzed_netlist"}
        local log_dir=${6:-"$out/logs"}
        local device="$DEVICE"  # add to lib.sh later
        local top="$TOP"        # add to lib.sh later

        local quartus_ret=0
        local setup="$(pwd)/flows/quartus/setup.tcl"
        local sta="$(pwd)/flows/quartus/sta.tcl"

        # cannot run synth and impl like vivado, must use executables
        # use step function to see the error code at the stage it happens
        step() { timeout 600 "$@" >/dev/null 2>&1 || quartus_ret=$?; }

        (
                # subshell prevents cd $out leaking to following scripts
                cd "$out" || exit 1

                # set up project
                step "$QUARTUS_BIN/quartus_sh" -t "$setup" "$fuzed_top"

                 # create sdc file
                printf 'create_clock -name clk -period %s [get_ports clk]\n' "$clk_period" > fuzzed_netlist.sdc
      
                # synth
                ((quartus_ret == 0)) && step "$QUARTUS_BIN/quartus_map" "$fuzed_top"
                ((quartus_ret == 0)) && step "$QUARTUS_BIN/quartus_eda" "$fuzed_top" --simulation --tool=modelsim --functional --format=verilog
                ((quartus_ret == 0)) && mv "simulation/modelsim/top.vo" "$synth_top.v"
                ((quartus_ret == 0)) && sed -i "s/module top/module synth/" "$synth_top.v"

                # impl
                ((quartus_ret == 0)) && step "$QUARTUS_BIN/quartus_fit" "$fuzed_top"
                ((quartus_ret == 0)) && step "$QUARTUS_BIN/quartus_eda" "$fuzed_top" --simulation --tool=modelsim --functional --format=verilog
                ((quartus_ret == 0)) && { timeout 600 "$QUARTUS_BIN/quartus_sta" -t "$sta" > sta.log 2>&1 || quartus_ret=$?; }
                ((quartus_ret == 0)) && mv "simulation/modelsim/top.vo" "$impl_top.v"
                ((quartus_ret == 0)) && sed -i "s/module top/module impl/" "$impl_top.v"
                # Quartus fitter always adds on-chip flash (unvm) and adc block, removed as they
                # are disconnected and dont affect logic
                ((quartus_ret == 0)) && awk '/fiftyfivenm_unvm|fiftyfivenm_adcblock/{skip=1} skip&&/translate_on/{skip=0;next} !skip' "$impl_top.v" > "$impl_top.v.tmp" \
                                && mv "$impl_top.v.tmp" "$impl_top.v"

                if   ((quartus_ret == 124 )); then exit 3
                elif ((quartus_ret > 128));   then exit 2
                elif ((quartus_ret > 0));     then exit 1
                fi
                exit 0
        )
        local rc=$?
        ((rc == 0)) && info "Quartus implementation completed successfully"
        return $rc
}