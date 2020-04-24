OpenROAD-example
----------------
This is a simple standalone example design that uses the
[OpenROAD](https://github.com/The-OpenROAD-Project/OpenROAD) tools. It serves as a quick demonstration (i.e. "hello world") of the flow going from verilog to gds.

The design is a "TinyConfig" of the [RISC-V Rocket Core](https://github.com/chipsalliance/rocket-chip) from Berkeley.
The design uses the [Nangate 45 Open Cell Library](https://projects.si2.org/openeda.si2.org/help/group_ld.php?group=63). It also uses SRAM macro models generated using [bsg_fakeram](https://github.com/bespoke-silicon-group/bsg_fakeram).

To start, reference the build instructions in the OpenROAD-flow Readme[https://github.com/The-OpenROAD-Project/OpenROAD-flow#setup]

You will need 4 binaries to proceed: yosys, openroad, TritonRoute and klayout

Once the binaries are installed, run `make` to begin. At the end of the flow you should have a gds saved in the `./results` directory. You can visually inspect the final gds in klayout by running `make inspect`

