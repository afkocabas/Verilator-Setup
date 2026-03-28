# Verilator Setup

Base setup for developing SystemVerilog projects with Verilator and GTKWave.

## Features
- Generate headers and related translation units for developing test suites
- Compile `.sv` files and C++ test files (`.cc`) into executable binaries
- Generate waveform files for debugging

## Requirements
The `build.sh` script requires the following tools to be installed:

- `verilator`
- `gtkwave` (By default, the script tries to generate waveforms.)
- `g++-14`

The C++ compiler, C++ standard, compilation flags and waveform type can be changed by modifying the corresponding environment variables in `build.sh`.

## Use & Example
The repository includes several directories with examples.

### Notes
- The `obj_dir` directory is ignored, so IDEs or text editors may report missing symbols in `.cc` files.
- Required headers can be generated manually using the build script.

### Generate Headers
`./build.sh 0 andGate/AndGate.sv` 

This command generates the headers into `obj_dir`. Header files can later be used to create verification suites in C++.

### Build Executable
After creating the tests, they can be used to generate final executable using following command:

`./build.sh 1 andGate/AndGate.sv andGate/AndGate.cc`

This command generates binary executable named as `VAndGate`.

### Multiple Verilog Files
The script also supports multiple `.sv` files. The top-level module must be provided last:

`./build.sh 1 file.sv file2.sv toplevel.sv TestSuit.cc`
