# GemmaNPU hardware emulator
This is the main part of the project.

# Project structure
src/core Here there are all the core compoenents like the `processing elements`, `memories`, `systolic arrays`, etc...
src/io   Here there are all the componests that are used to by the core components to comunicate with other NPUs or hosts

tests/formal    Contains the `.sby` file definitions to run formal verification of each component
tests/automatic Contains the code for run automated tests

# Installing 
For installations please look at [INSTALLING.md](INSTALLING.md)


# Tutorials
## [Make your first processing element](/examples/make_your_first_processing_element/README.md)
In this tutorial you will create your first minimal processing element and the respective test bench.