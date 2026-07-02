# proj name and verilog file name are hardcoded, change below
project_new fuzzed_netlist -overwrite
set_global_assignment -name FAMILY "MAX 10"
set_global_assignment -name DEVICE 10M50DAF484C7G
set_global_assignment -name TOP_LEVEL_ENTITY top
set_global_assignment -name VERILOG_FILE fuzzed_netlist.v
set_global_assignment -name SDC_FILE fuzzed_netlist.sdc
project_close