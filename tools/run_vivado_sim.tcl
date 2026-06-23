if {[info exists SEED]} {
    set sim_seed $SEED
} elseif {[info exists ::env(SEED)]} {
    set sim_seed $::env(SEED)
} else {
    set sim_seed [clock seconds]
}

if {[info exists ARGS]} {
    set sim_args $ARGS
} elseif {[info exists ::env(ARGS)]} {
    set sim_args $::env(ARGS)
} else {
    set sim_args ""
}

puts "=== Launching Vivado Simulation with SEED=$sim_seed, ARGS=$sim_args ==="

set proj_name "vivado_sim"
set proj_dir "./syn/vivado_sim"
set top_module "tb_top_led"

if {[current_project -quiet] ne ""} {
    close_project
}

if {[file exists $proj_dir/$proj_name.xpr]} {
    puts "Opening existing simulation project..."
    open_project $proj_dir/$proj_name.xpr
} else {
    puts "Creating new simulation project..."
    create_project $proj_name $proj_dir -part xc7a35tcpg236-1 -force
}

remove_files [get_files -quiet]

add_files -fileset sources_1 [glob ./rtl/counter.sv ./rtl/shift_reg.sv ./rtl/top_led.sv]

add_files -fileset sim_1 [glob ./tb/tb_top_led.sv]

set_property top $top_module [get_filesets sim_1]
update_compile_order -fileset sim_1

if {[info commands stop_gui] ne ""} {
    set_property -name {xsim.simulate.runtime} -value {0ns} -objects [get_filesets sim_1]
} else {
    set_property -name {xsim.simulate.runtime} -value {-all} -objects [get_filesets sim_1]
}

set_property -name {xsim.elaborate.xelab.more_options} -value "" -objects [get_filesets sim_1]
set xsim_opts "-sv_seed $sim_seed"
if {$sim_args ne ""} {
    if {[string index $sim_args 0] ne "+"} {
        set sim_args "+$sim_args"
    }
    set xsim_opts "$xsim_opts -testplusarg $sim_args"
}
set_property -name {xsim.simulate.xsim.more_options} -value $xsim_opts -objects [get_filesets sim_1]

launch_simulation

if {[info commands stop_gui] ne ""} {
    puts "Vivado GUI detected. Setting up waveforms..."
    
    if {[get_waves -quiet] ne ""} {
        remove_wave [get_waves]
    }
    
    set group_uut [add_wave_group "UUT Interfaces"]
    add_wave -into $group_uut /tb_top_led/uut/*
    
    set group_counter [add_wave_group "Counter Logic"]
    add_wave -into $group_counter /tb_top_led/uut/u_counter/*
    
    set group_shift [add_wave_group "Shift Register"]
    add_wave -into $group_shift /tb_top_led/uut/u_shift_reg/*
    
    run -all
    
    puts "Simulation run complete. Waves ready in GUI. (Tip: Press 'F' or click the 'Zoom Fit' toolbar button in the GUI to fit the timeline)"
} else {
    puts "Vivado Batch Mode detected. Simulation complete. Exiting..."
    exit
}
