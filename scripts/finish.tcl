# ------------------------------------------------------------------------------
# STEP 0: Load the design
# ------------------------------------------------------------------------------
set design_name "RocketTile"

# Read lef files
set lef_files "[glob ./tech/*.lef] [glob ./src/*.lef]"
foreach lef $lef_files {
  read_lef $lef
}

# Read liberty files
set lib_files "[glob ./tech/*.lib] [glob ./src/*.lib]"
foreach lib $lib_files {
  read_liberty $lib
}

# Read the design and read sdc
read_def ./results/detail_route.def
read_sdc ./src/$design_name.sdc

# ------------------------------------------------------------------------------
# STEP 6: Finalize
# ------------------------------------------------------------------------------

# Insert filler cells
filler_placement "FILLCELL_X1 FILLCELL_X2 FILLCELL_X4 FILLCELL_X8 FILLCELL_X16 FILLCELL_X32"
check_placement -verbose


log_begin ./reports/final_report.rpt
puts "\n=========================================================================="
puts "report_checks -path_delay min"
puts "--------------------------------------------------------------------------"
report_checks -path_delay min

puts "\n=========================================================================="
puts "report_checks -path_delay max"
puts "--------------------------------------------------------------------------"
report_checks -path_delay max

puts "\n=========================================================================="
puts "report_checks -unconstrained"
puts "--------------------------------------------------------------------------"
report_checks -unconstrained

puts "\n=========================================================================="
puts "report_tns"
puts "--------------------------------------------------------------------------"
report_tns

puts "\n=========================================================================="
puts "report_wns"
puts "--------------------------------------------------------------------------"
report_wns

puts "\n=========================================================================="
puts "report_check_types -max_slew -violators"
puts "--------------------------------------------------------------------------"
report_check_types -max_slew -violators

puts "\n=========================================================================="
puts "report_power"
puts "--------------------------------------------------------------------------"
report_power

puts "\n=========================================================================="
puts "report_design_area"
puts "--------------------------------------------------------------------------"
report_design_area
log_end


write_def ./results/final.def