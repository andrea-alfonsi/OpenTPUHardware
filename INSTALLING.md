#  Installing 
This file desbribe the process to all the required toolsin order to test, build, develop, install and run the project

## Icarus verilog
This is the default interpreter for the project. Informations about the project can be foundon the officialpage [Icarus verilog Github page](https://github.com/steveicarus/iverilog)

## Yosys ( mandatory for development only )
This is used for sysnthesys and formal verification of the modules. Is not stricly necessary forrunning the project but mandatory for developement. Installtion instructions can be found at the [OSS Cad Suite](https://github.com/YosysHQ/oss-cad-suite-build)

## Verilator ( optional )
This is used to  compile hardware code into standalone executable. This is used to dispaly the project on the web or when istalling iverilog is not an option. Installation guidelines can be found on the [Official Verilator Github page](https://github.com/verilator/verilator)