# UART demo for Arty S7
The goal of this project is to get UART communication with Arty S7 working and 
to display each received byte as a character on a HD44780U LCD.

Pins on the LCD and their connections to FPGA:
```
LCD:  | VSS | VDD |     V0      |  RS |  RW |  E   | D[0-7]  |  A  |  K  |
FPGA: | GND | 5V0 | POT 10K GND | IO9 | IO8 | IO10 | IO7-IO0 | 5V0 | GND |
```

## Dependencies
- Vivado - tested using version 2023.2
- [iverilog](https://github.com/steveicarus/iverilog) for simulation
- [openFPGALoader](https://github.com/trabucayre/openFPGALoader) for programming

## Usage
- `make sim` - Runs the testbench for the top module.

- `make synth` - Synthesizes the entire design.

- `make impl` - Implement the design; place and route.

- `make gui` - Opens the project in Vivado GUI.

- `make bit` - Generate the bitstream, which will be put in `build/top.bit`

- `make reports` - Generates various reports and puts them in `build/reports/`.

- `make prog` - Programs the board using openFPGALoader. 

- `make burn` - Programs the board but will write the bitstream into flash, changing this way the default design loaded by the FPGA.
