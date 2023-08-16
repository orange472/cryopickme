#!/usr/bin/env bash
#
#   run_drpnet.sh - runs DRPnet model on micrographs
#   author: Leo deJong
#

# Track runtime
START=$(date +%s.%N)

# Collect environmental variables
if [ -z "${REPIC_TRAIN_MRC}" ]; then REPIC_TRAIN_MRC=0; fi
if [ -z "${REPIC_VAL_MRC}" ]; then REPIC_VAL_MRC=0; fi
if [ -z "${REPIC_MRC_DIR}" ]; then REPIC_MRC_DIR=0; fi
if [ -z "${REPIC_BOX_SIZE}" ]; then REPIC_BOX_SIZE=0; fi


if [ -z "${DRPNET_DIR}" ]; then DRPNET_DIR="./DRPnet-master"; fi
if [ -z "${REPIC_OUT_DIR}" ]; then REPIC_OUT_DIR=0; fi
if [ -z "${REPIC_OOB}" ]; then REPIC_OOB=0; fi

#if [ -z "${REPIC_UTILS}" ]; then REPIC_UTILS=0; fi


if [ -z "${DRPNET_PARAMS_TXT}" ]; then DRPNET_PARAMS_TXT="inputparams/splitparams.txt"; fi


module load MATLAB/2022a
matlab -nosplash -noFigureWindows << EOF
cd ${DRPNET_DIR}
pickparticles('${REPIC_TRAIN_MRC}', '${REPIC_VAL_MRC}', '${REPIC_OUT_DIR}', '${REPIC_MRC_DIR}', '${DRPNET_PARAMS_TXT}', '${REPIC_BOX_SIZE}', '${REPIC_OOB}')
EOF

# Save runtime to storage
END=$(date +%s.%N)
DIFF=$( echo "${END} - ${START}" | bc -l )
COUNT=$( ls ${REPIC_MRC_DIR}/*.mrc | wc -l )
#echo -e "start\tend\tdifference\tN\n${START}\t${END}\t${DIFF}\t${COUNT}" > ${REPIC_OUT_DIR}/run_drpnet_runtime.tsv
