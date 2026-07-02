#!/usr/bin/env bash

set -euo pipefail

info()  { printf "\033[0;34m[INFO] \033[0m%s\n"  "$*"; }
warn()  { printf "\033[0;33m[WARN] \033[0m%s\n"  "$*"; }
pass()  { printf "\033[0;32m[PASS] \033[0m%s\n"  "$*"; }
fail()  { printf "\033[0;31m[FAIL] \033[0m%s\n"  "$*"; }

export TOP=${TOP:-top}
export SEED=${SEED:-$(od -An -N4 -tu4 < /dev/urandom)}
export VENDOR=${VENDOR:-vivado}  # allow switching between vivado and quartus

export MAX_REDUCTION_ITER=${MAX_REDUCTION_ITER:-100}

export FUZNET_BIN=${FUZNET_BIN:-fuznet}
export SETTINGS_TOML=${SETTINGS_TOML:-config/settings.toml}

if [ "$VENDOR" = "quartus" ]; then
    export CELL_LIB=${CELL_LIB:-hardware/quartus/cells.yaml}
    export PRIMS_V=${PRIMS_V:-hardware/quartus/cell_sim.v}
    export QUARTUS_BIN=${QUARTUS_BIN:-/usr/local/altera/18.1/quartus/bin}  # for remote linux server
    export DEVICE=${DEVICE:-10M50DAF484C7G}  # might extend to cyclone V later
    export VERILATOR_FLAGS=${VERILATOR_FLAGS:-}  # no -DGLBL
    export VERILATOR_CXX=${VERILATOR_CXX:-x86_64-conda-linux-gnu-g++}  # for remote linux server
else
    export CELL_LIB=${CELL_LIB:-hardware/xilinx/cells.yaml}
    export PRIMS_V=${PRIMS_V:-hardware/xilinx/cell_sim.v}
    export VIVADO_BIN=${VIVADO_BIN:-/opt/Xilinx/Vivado/2024.2/bin/vivado}
    export VIVADO_TCL=${VIVADO_TCL:-flows/vivado/impl.tcl}
    export VERILATOR_FLAGS=${VERILATOR_FLAGS:--DGLBL}
    export VERILATOR_CXX=${VERILATOR_CXX:-}  # default g++