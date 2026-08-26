#!/bin/bash

set -e

echo "=========================================="
echo " AES-128 Accelerator - OpenROAD Flow"
echo " SKY130HS"
echo "=========================================="

#---------------------------------------------------------
# Project paths
#---------------------------------------------------------

PROJECT=$(cd "$(dirname "$0")" && pwd)

ORFS="$HOME/PDK/OpenROAD-flow-scripts/flow"

DESIGN="aes128"
PLATFORM="sky130hs"

DEST="$PROJECT/synth/sky130hs/openroad"

DESIGN_DIR="$ORFS/designs/$PLATFORM/$DESIGN"


#---------------------------------------------------------
# Tool paths
#---------------------------------------------------------

OPENROAD_EXE="$HOME/OpenROAD/build/bin/openroad"
YOSYS_EXE="/opt/homebrew/bin/yosys"
KLAYOUT_CMD="/Applications/KLayout/klayout.app/Contents/MacOS/klayout"


#---------------------------------------------------------
# Check tools
#---------------------------------------------------------

echo
echo "Checking tools..."

if [ ! -x "$OPENROAD_EXE" ]; then
    echo "ERROR: OpenROAD executable not found:"
    echo "$OPENROAD_EXE"
    exit 1
fi

if [ ! -x "$YOSYS_EXE" ]; then
    echo "ERROR: Yosys executable not found:"
    echo "$YOSYS_EXE"
    exit 1
fi

if [ ! -x "$KLAYOUT_CMD" ]; then
    echo "ERROR: KLayout executable not found:"
    echo "$KLAYOUT_CMD"
    exit 1
fi

echo "OpenROAD : $OPENROAD_EXE"
echo "Yosys    : $YOSYS_EXE"
echo "KLayout  : $KLAYOUT_CMD"
echo "ORFS     : $ORFS"


#---------------------------------------------------------
# Clean previous physical-design outputs
#---------------------------------------------------------

echo
echo "Cleaning previous physical-design results..."

rm -rf "$DEST"

mkdir -p "$DEST/results"
mkdir -p "$DEST/reports"
mkdir -p "$DEST/logs"
mkdir -p "$DEST/gds"


#---------------------------------------------------------
# Update ORFS design files
#---------------------------------------------------------

echo
echo "=========================================="
echo " Updating OpenROAD Design Files"
echo "=========================================="

mkdir -p "$DESIGN_DIR"

# Copy all current AES RTL
cp "$PROJECT/rtl/"*.sv "$DESIGN_DIR/"

# Copy SKY130HS timing constraints
cp "$PROJECT/constraints/sky130hs_aes_core.sdc" \
   "$DESIGN_DIR/constraint.sdc"

echo
echo "RTL files:"
ls "$DESIGN_DIR/"*.sv

echo
echo "Constraint:"
ls -l "$DESIGN_DIR/constraint.sdc"


#---------------------------------------------------------
# Check ORFS configuration
#---------------------------------------------------------

if [ ! -f "$DESIGN_DIR/config.mk" ]; then
    echo
    echo "ERROR: ORFS config.mk not found:"
    echo "$DESIGN_DIR/config.mk"
    exit 1
fi


#---------------------------------------------------------
# Run OpenROAD-flow-scripts
#---------------------------------------------------------

echo
echo "=========================================="
echo " Running OpenROAD Flow"
echo "=========================================="

make -C "$ORFS" \
    OPENROAD_EXE="$OPENROAD_EXE" \
    YOSYS_EXE="$YOSYS_EXE" \
    KLAYOUT_CMD="$KLAYOUT_CMD" \
    DESIGN_CONFIG="./designs/$PLATFORM/$DESIGN/config.mk"


STATUS=$?


#---------------------------------------------------------
# Check result
#---------------------------------------------------------

if [ $STATUS -ne 0 ]; then

    echo
    echo "=========================================="
    echo " OpenROAD Flow FAILED"
    echo "=========================================="

    exit $STATUS

fi


#---------------------------------------------------------
# ORFS output locations
#---------------------------------------------------------

RESULTS="$ORFS/results/$PLATFORM/$DESIGN/base"
REPORTS="$ORFS/reports/$PLATFORM/$DESIGN/base"
LOGS="$ORFS/logs/$PLATFORM/$DESIGN/base"


#---------------------------------------------------------
# Copy results
#---------------------------------------------------------

echo
echo "=========================================="
echo " Copying OpenROAD Outputs"
echo "=========================================="

if [ -d "$RESULTS" ]; then
    cp -r "$RESULTS/"* "$DEST/results/" 2>/dev/null || true
fi

if [ -d "$REPORTS" ]; then
    cp -r "$REPORTS/"* "$DEST/reports/" 2>/dev/null || true
fi

if [ -d "$LOGS" ]; then
    cp -r "$LOGS/"* "$DEST/logs/" 2>/dev/null || true
fi


#---------------------------------------------------------
# Copy final GDS
#---------------------------------------------------------

if [ -f "$RESULTS/6_final.gds" ]; then

    cp "$RESULTS/6_final.gds" \
       "$DEST/gds/aes128_sky130hs.gds"

    echo
    echo "GDS generated:"
    echo "$DEST/gds/aes128_sky130hs.gds"

else

    echo
    echo "WARNING: Final GDS was not found."

fi


#---------------------------------------------------------
# Finished
#---------------------------------------------------------

echo
echo "=========================================="
echo " OpenROAD Flow Completed Successfully"
echo "=========================================="

echo
echo "Physical Design : $DEST"
echo "Results         : $DEST/results"
echo "Reports         : $DEST/reports"
echo "Logs            : $DEST/logs"
echo "GDS             : $DEST/gds"

echo
