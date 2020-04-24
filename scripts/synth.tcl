# Import yosys commands
yosys -import


# Set design names
set design_name "RocketTile"
# Set verilog source files
set verilog_files "[glob src/*.v]"
# Set liberty files
set lib_file "./tech/NangateOpenCellLibrary_typical.lib"


# Read verilog files
foreach file $verilog_files {
  read_verilog -sv $file
}

# Use hierarchy to automatically generate blackboxes for known memory macro.
# Pins are enumerated for proper mapping
hierarchy -generate fakeram45_* o:rd_out i:addr_in i:we_in \
                                i:wd_in i:w_mask_in i:clk i:ce_in

# generic synthesis
synth -top $design_name -flatten

# Optimize the design
opt -purge

# technology mapping of flip-flops
dfflibmap -liberty $lib_file
opt

# Technology mapping for cells
abc -D [expr 5.6 * 1000] \
    -liberty $lib_file

# technology mapping of constant hi- and/or lo-drivers
hilomap -singleton \
        -hicell LOGIC1_X1 Z \
        -locell LOGIC0_X1 Z

# replace undef values with defined constants
setundef -zero

# Splitting nets resolves unwanted compound assign statements in netlist (assign {..} = {..})
splitnets

# insert buffer cells for pass through wires
insbuf -buf BUF_X1 A Z

# remove unused cells and wires
opt_clean -purge

# reports
tee -o ./reports/synth_check.txt check
tee -o ./reports/synth_stat.txt stat -liberty $lib_file

# write synthesized design
write_verilog -noattr -noexpr -nohex -nodec ./results/synth.v
