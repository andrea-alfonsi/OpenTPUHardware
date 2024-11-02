#!/bin/bash

# The config file contains the variables if the form 
# [01]{10} \d{4} \d{1}
# configs  outputs  stationary_data_after_2_iterations

# Search for array0..3  is,ws,os  f1,f2  r1,r2,r3
# Subarray   stationary   flow    role
#                                  1: data follows flow previous subarray
#                                  2: data follows flows curent subarray
#                                  3: data change direction


# TODO
iverilog -g2012 redas_pe_simulation.sv -o redas.o && vvp redas.o | grep -f config_file.txt
rm redas.o