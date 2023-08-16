#!/usr/bin/env bash

START=$(date +%s.%N)

#	Collect environmental variables
if [ -z "${REPIC_TRAIN_MRC}" ]; then REPIC_TRAIN_MRC=0; fi
if [ -z "${REPIC_TEST_MRC}" ]; then REPIC_TEST_MRC=0; fi
if [ -z "${REPIC_VAL_MRC}" ]; then REPIC_VAL_MRC=0; fi
if [ -z "${REPIC_TRAIN_COORD}" ]; then REPIC_TRAIN_COORD=0; fi
if [ -z "${REPIC_TEST_COORD}" ]; then REPIC_TEST_COORD=0; fi
if [ -z "${REPIC_VAL_COORD}" ]; then REPIC_VAL_COORD=0; fi
if [ -z "${REPIC_LABEL_TYPE}" ]; then REPIC_LABEL_TYPE="box"; fi
if [ -z "${REPIC_BOX_SIZE}" ]; then REPIC_BOX_SIZE=0; fi
if [ -z "${REPIC_OUT_DIR}" ]; then REPIC_OUT_DIR=0; fi
if [ -z "${REPIC_UTILS}" ]; then REPIC_UTILS=0; fi
if [ -z "${EPICKER_ENV}" ]; then EPICKER_ENV="epicker"; fi
if [ -z "${EPICKER_DIR}" ]; then EPICKER_DIR="./EPicker"; fi
if [ -z "${EPICKER_MODEL}" ]; then EPICKER_MODEL=None; fi

eval "$(conda shell.bash hook)"
conda activate ${EPICKER_ENV}

# Run EPicker training script
${EPICKER_DIR}/bin/epicker_train.sh \
  --exp_id=${REPIC_OUT_DIR} \
  --training_data=${REPIC_TRAIN_MRC} \
  --testing_data=${REPIC_TEST_MRC} \
  --validation_data=${REPIC_VAL_MRC} \
  --training_label=${REPIC_TRAIN_COORD} \
  --testing_label=${REPIC_TEST_COORD} \
  --validation_label=${REPIC_VAL_COORD} \
  --label_type=${REPIC_LABEL_TYPE} \
  --load_model=${EPICKER_MODEL}

conda deactivate

#	save runtime to storage
END=$(date +%s.%N)
DIFF=$(echo "${END} - ${START}" | bc -l)
LABEL=$(basename ${REPIC_MRC_DIR} | sed -E 's/_[0-9]+//g')
COUNT=$(ls ${REPIC_MRC_DIR}/*.mrc | wc -l)
echo -e """start\tend\tdifference\tN
${START}\t${END}\t${DIFF}\t${COUNT}""" >${REPIC_OUT_DIR}/run_epicker_runtime_${LABEL}.tsv
