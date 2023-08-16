#!/usr/bin/env bash

#	track runtime
START=$(date +%s.%N)

#	Collect environmental variables
if [ -z "${REPIC_MRC_DIR}" ]; then REPIC_MRC_DIR=0; fi
if [ -z "${REPIC_BOX_SIZE}" ]; then REPIC_BOX_SIZE=0; fi
if [ -z "${REPIC_OUT_DIR}" ]; then REPIC_OUT_DIR=0; fi
if [ -z "${REPIC_UTILS}" ]; then REPIC_UTILS=0; fi
if [ -z "${EPICKER_ENV}" ]; then EPICKER_ENV="epicker"; fi
if [ -z "${EPICKER_DIR}" ]; then EPICKER_DIR="./EPicker"; fi
if [ -z "${EPICKER_MODEL}" ]; then :; fi

eval "$(conda shell.bash hook)"
conda activate ${EPICKER_ENV}

# Run EPicker picking script
${EPICKER_DIR}/bin/epicker.sh \
  --data=${REPIC_MRC_DIR} \
  --load_model=${EPICKER_MODEL} \
  --output=${REPIC_OUT_DIR}/output \
  --output_type="box"

conda deactivate

#	save runtime to storage
END=$(date +%s.%N)
DIFF=$(echo "${END} - ${START}" | bc -l)
LABEL=$(basename ${REPIC_MRC_DIR} | sed -E 's/_[0-9]+//g')
COUNT=$(ls ${REPIC_MRC_DIR}/*.mrc | wc -l)
echo -e """start\tend\tdifference\tN
${START}\t${END}\t${DIFF}\t${COUNT}""" >${REPIC_OUT_DIR}/run_epicker_runtime_${LABEL}.tsv
