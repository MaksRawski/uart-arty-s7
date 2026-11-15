# Vivadwow
Solution for using vivado without its GUI. Inspired by [vivado-wrapper](https://git.recolic.net/root/vivado-wrapper).

Heart of this project is a Makefile which runs simple tcl scripts in vivado to do basic synthesis and implementation.
Adding support for VHDL and SystemVerilog is probably quite trivial but I'm not interested in maintaining it.

## Dependencies
- Vivado - tested using version 2023.2
- [iverilog](https://github.com/steveicarus/iverilog) for simulation
- [openFPGALoader](https://github.com/trabucayre/openFPGALoader) for programming

## Usage
Create a new directory for your project and clone or add as a submodule this project into it, then run `vivadwow/setup.sh`.

```
mkdir my-proj
cd my-proj
git clone https://github.com/MaksRawski/vivadwow.git
./vivadwow/setup.sh
```

Configuration is done in `Makefile` and `scripts/config.tcl`.

- `make sim TARGET=my_module` - Runs the testbench for the module `my_module`. 
  Will look for a file `my_module_tb.v` in `src/` or any of its subdirectories. 
  By default chooses `top` module which must be stored in `src/top.v`.

- `make synth` - Synthesizes the entire design.

- `make impl` - Implement the design; place and route.

- `make bit` - Generate the bitstream, which will be put in `build/top.bit`

- `make reports` - Generates various reports and puts them in `build/reports/`.

- `make prog` - Programs the board using openFPGALoader. 
  Make sure to put the name of the board you are trying to program in `Makefile`'s `BOARD_NAME` variable.

- `make burn` - Programs the board but will write the bitstream into flash, changing this way the default design loaded by the FPGA.
