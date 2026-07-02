# project name is hardcoded below
project_open fuzzed_netlist
create_timing_netlist -model slow
read_sdc
update_timing_netlist
foreach_in_collection p [get_timing_paths -setup -npaths 1 -nworst 1] {
    puts "QUARTUS_WNS [get_path_info $p -slack]"
}
project_close