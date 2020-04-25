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

# Read verilog
read_verilog ./results/synth.v

# Link the design and read sdc
link_design $design_name
read_sdc ./src/$design_name.sdc

set_wire_rc -layer "metal3"

# ------------------------------------------------------------------------------
# STEP 1: Floorplan
# ------------------------------------------------------------------------------
initialize_floorplan -utilization 24.0 \
                     -aspect_ratio 1.0 \
                     -core_space 2.0 \
                     -tracks "./tech/tracks.info" \
                     -site "FreePDK45_38x28_10R_NP_162NW_34O"


# Initial Report
log_begin ./reports/init.rpt

puts "\n=========================================================================="
puts "report_checks"
puts "--------------------------------------------------------------------------"
report_checks

puts "\n=========================================================================="
puts "report_tns"
puts "--------------------------------------------------------------------------"
report_tns

puts "\n=========================================================================="
puts "report_wns"
puts "--------------------------------------------------------------------------"
report_wns

puts "\n=========================================================================="
puts "report_design_area"
puts "--------------------------------------------------------------------------"
report_design_area
log_end


# IO Placement
io_placer -hor_layer 3 -ver_layer 2 -random

# Timing Driven Mixed Size Placement
global_placement -timing_driven -density 0.50

# Macro Placement
macro_placement -global_config ./tech/IP_global.cfg

# Well-tie and tap-cell insertion (Using filler cells as dummies)
tapcell -endcap_cpp "2" -distance 120  \
        -tapcell_master "FILLCELL_X1" -endcap_master "FILLCELL_X1"

# Well-tie and tap-cell insertion
pdngen ./tech/pdn.cfg -verbose

# ------------------------------------------------------------------------------
# STEP 2: Placement, Resizing and Repairs
# ------------------------------------------------------------------------------

# Global placement
global_placement -timing_driven -density 0.50 \
                 -pad_left 2 -pad_right 2


# Set the buffer cell
set buffer_cell "NangateOpenCellLibrary/BUF_X1"
set max_fanout 100
buffer_ports -buffer_cell $buffer_cell

# Perform resizing
resize -resize

# Repair max cap
repair_max_cap -buffer_cell $buffer_cell

# Repair max slew
repair_max_slew -buffer_cell $buffer_cell

# Repair tie lo fanout
repair_tie_fanout -max_fanout $max_fanout "NangateOpenCellLibrary/LOGIC0_X1/Z"

# Repair tie hi fanout
repair_tie_fanout -max_fanout $max_fanout "NangateOpenCellLibrary/LOGIC1_X1/Z"

# Repair max fanout
repair_max_fanout -max_fanout $max_fanout -buffer_cell $buffer_cell

# Repair hold violations
repair_hold_violations -buffer_cell $buffer_cell

# Detail Placement
set_placement_padding -global -left 1 -right 1
detailed_placement
check_placement -verbose

# ------------------------------------------------------------------------------
# STEP 3: Clock Tree Synthesis
# ------------------------------------------------------------------------------
clock_tree_synthesis -lut_file ./tech/cts/lut.txt \
                     -sol_list ./tech/cts/sol_list.txt \
                     -root_buf "BUF_X4" \
                     -wire_unit 20

# Legalize placement for buffers
set_placement_padding -global -left 1 -right 1
detailed_placement
check_placement -verbose

# ------------------------------------------------------------------------------
# STEP 4: Global Route
# ------------------------------------------------------------------------------
fastroute -output_file ./results/route.guide \
          -max_routing_layer 10 \
          -unidirectional_routing true \
          -capacity_adjustment 0.15 \
          -layers_adjustments {{2 0.5} {3 0.5}} \
          -overflow_iterations 100


write_def ./results/global_route.def

