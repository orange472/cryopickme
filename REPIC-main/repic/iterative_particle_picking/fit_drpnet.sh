#!/usr/bin/env bash
#
#   fit_drpnet.sh - fits DRPnet model to consensus particles
#   author: Leo deJong
#

# Track runtime
START=$(date +%s.%N)

# Collect environmental variables
if [ -z "${REPIC_TRAIN_MRC}" ]; then REPIC_TRAIN_MRC=0; fi
if [ -z "${REPIC_TRAIN_COORD}" ]; then REPIC_TRAIN_COORD=0; fi
if [ -z "${REPIC_VAL_MRC}" ]; then REPIC_VAL_MRC=0; fi
if [ -z "${REPIC_VAL_COORD}" ]; then REPIC_VAL_COORD=0; fi
if [ -z "${REPIC_BOX_SIZE}" ]; then REPIC_BOX_SIZE=0; fi

if [ -z "${DRPNET_DIR}" ]; then DRPNET_DIR="./DRPnet-master"; fi
if [ -z "${REPIC_OUT_DIR}" ]; then REPIC_OUT_DIR=0; fi

#if [ -z "${REPIC_UTILS}" ]; then REPIC_UTILS=0; fi

if [ -z "${DRPNET_PARAMS_TXT}" ]; then DRPNET_PARAMS_TXT="inputparams/splitparams.txt"; fi


#delete trained models if they exist
if [ -f "${DRPNET_DIR}/models/trained_cnet_1.mat" ]; then
    rm -f "${DRPNET_DIR}/models/trained_cnet_1.mat"
fi

if [ -f "${DRPNET_DIR}/models/trained_cnet_2.mat" ]; then
    rm -f "${DRPNET_DIR}/models/trained_cnet_2.mat"
fi

module load MATLAB/2022a

matlab -nosplash -noFigureWindows << EOF
cd ${DRPNET_DIR}

cd train_detection
GetDetectionTrainingSamples_bin('${REPIC_TRAIN_COORD}', '${REPIC_TRAIN_MRC}', '${REPIC_VAL_COORD}', '${REPIC_VAL_MRC}', '../${DRPNET_PARAMS_TXT}', '${REPIC_BOX_SIZE}') 
Train_Detection_Network
cd ..
trainsecondnetwork('${REPIC_TRAIN_MRC}', '${REPIC_VAL_MRC}', '${REPIC_MRC_DIR}', '${DRPNET_PARAMS_TXT}', '${REPIC_BOX_SIZE}')

EOF

END=$(date +%s.%N)
DIFF=$( echo "${END} - ${START}" | bc -l )
TRAIN=$( ls ${REPIC_TRAIN_MRC}/*.mrc | wc -l )
#echo -e "start\tend\tdifference\ttrain_N\n${START}\t${END}\t${DIFF}\t${TRAIN}" >  ${REPIC_OUT_DIR}/fit_drpnet_runtime.tsv
