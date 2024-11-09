To start run `python new_module.py core.processing_elements.my_first_pe` in your terminal. This script will generate the design file (located under `rtl/core/processing_elements/my_first_pe.sv`) and the test files (located in `sim/core/processing_elements/my_first_pe`) automatically.
It will also generate the instructions in the Makefile to test your design.

Now you can copy the content of the [basic pe](/rtl/core/processing_elements/basic_pe.sv) inside the design file generated previously.
And copy also the [testbench](/sim/core/processing_elements/basic_pe/basic_pe_tb.sv) in the `my_first_pe_tb.sv` file in the `sim` folder.

To test if everything works run finally `make test_my_first_pe`.