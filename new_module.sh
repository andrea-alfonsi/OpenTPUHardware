#!/bin/bash

SCRIPT="$0"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
INPUT_MODULE="$1"


if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
  echo "$0 MODULE_HIERARCHY"
  echo ""
  echo "Generate all the files for the delepment of a new module"
  echo
  echo "Arguments:"
  echo "MODULE_HIERARCH.  Example core.processing_elements.basic_pe"
  echo ""
  echo ""
  exit 0;
fi

if [[ -z "$INPUT_MODULE" ]]; then
    echo "MODULE_HIERARCHY is mandatory. Example core.processing_elements.basic_pe"
    echo "Run $0 --help to get more infos"
    exit 1
fi

MODULE_NAME=$( echo "$INPUT_MODULE" | awk '{split($0,a,"."); print a[length(a)]}')
MODULE_HIERARCHY=$( echo "$INPUT_MODULE" | awk '{sub(".[^.]+$","")} 1' | tr "." "/" )

# Create the file with the module definition
# Todo add a template parameter to start with the provided template
mkdir -p ${SCRIPT_DIR}/rtl/${MODULE_HIERARCHY}
echo -e "module ${MODULE_NAME} #() ();\nendmodule" > ${SCRIPT_DIR}/rtl/${MODULE_HIERARCHY}/${MODULE_NAME}.sv

# Create the file for the automatic tests
mkdir -p ${SCRIPT_DIR}/sim/${MODULE_HIERARCHY}/${MODULE_NAME}
echo -e "module ${MODULE_NAME}_tb;\nendmodule" > ${SCRIPT_DIR}/sim/${MODULE_HIERARCHY}/${MODULE_NAME}/${MODULE_NAME}_tb.sv

# Add test in make test_all in Makefile
sed -i "/^test_all/ s/$/ test_${MODULE_NAME}/" ${SCRIPT_DIR}/Makefile

# Add the instruction to the Makefile
echo -e "\n\n\
.PHONY: test_${MODULE_NAME}\n\
test_${MODULE_NAME}:\n\
\t@mkdir -p build\n\
\t\${COMPILER} -o \${TARGET_DIR}/${MODULE_NAME}_tb.test sim/${MODULE_HIERARCHY}/${MODULE_NAME}/${MODULE_NAME}_tb.sv\n\
\t\${INTERPRETER} \${TARGET_DIR}/${MODULE_NAME}_tb.test" >> ${SCRIPT_DIR}/Makefile

