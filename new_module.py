#!/bin/python3

import os
import sys
import argparse

module_template = """`ifndef {MODULE_HIERARCHY}_{MODULE_NAME}
`define {MODULE_HIERARCHY}_{MODULE_NAME}

module {MODULE_NAME} #() ();
endmodule

`endif
"""

sim_template = """`include "rtl/{MODULE_HIERARCHY}/{MODULE_NAME}.sv"

module {MODULE_NAME}_tb;
endmodule

"""

makefile_template = """
.PHONY: test_{MODULE_NAME}
test_{MODULE_NAME}:
\t@mkdir -p build
\t${{COMPILER}} -o ${{TARGET_DIR}}/{MODULE_NAME}_tb.test sim/{MODULE_HIERARCHY}/{MODULE_NAME}/{MODULE_NAME}_tb.sv
\t${{INTERPRETER}} ${{TARGET_DIR}}/{MODULE_NAME}_tb.test"
"""

script_dir = os.path.dirname(os.path.realpath(__file__))

if __name__ == '__main__':

  parser = argparse.ArgumentParser("Generate the template for a new module")
  parser.add_argument("MODULE")
  parser.add_argument("--template")
  parser.add_argument("--template_sim")
  args = parser.parse_args()

  if args.template:
    module_template = args.template

  if args.template_sim:
    sim_template = args.template_sim  

  module_name = args.MODULE.split(".")[-1]
  module_hierarchy = args.MODULE.split(".")[:-1]

  os.makedirs( os.path.join(script_dir, "rtl", *module_hierarchy ), exist_ok=True )
  with open( os.path.join(script_dir, "rtl", *module_hierarchy, module_name + '.sv' ), 'w') as f:
    f.write( module_template.format(MODULE_NAME=module_name.upper(), MODULE_HIERARCHY="_".join(module_hierarchy).upper() ) ) 

  os.makedirs( os.path.join(script_dir, "sim", *module_hierarchy, module_name ), exist_ok=True )
  with open( os.path.join(script_dir, "sim", *module_hierarchy, module_name, module_name + '.sv' ), 'w') as f:
    f.write( sim_template.format(MODULE_NAME=module_name, MODULE_HIERARCHY="/".join(module_hierarchy) ) )

  makefile = ""
  with open( os.path.join( script_dir, "Makefile"), 'r' ) as f:
    makefile = [l if not l.startswith("test_all") else l.rstrip() + " test_" + module_name for l in f.readlines() ]
    makefile.append( makefile_template.format( MODULE_HIERARCHY="/".join(module_hierarchy), MODULE_NAME=module_name) )

  with open(os.path.join( script_dir, "Makefile"), 'w' ) as f:
    f.write( "".join(makefile) )

