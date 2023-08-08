# Untested, to be incorporated into REPIC script

# Train set prediction
export REPIC_MRC_DIR=${REPIC_TRAIN_MRC}
export REPIC_OUT_DIR=${SUB_DIR}/${LABEL}/epicker
mkdir -p ${REPIC_OUT_DIR}/BOX/{train,val,test}

rm -rf ${REPIC_OUT_DIR}/*
bash ${REPIC}/iterative_particle_picking/run_epicker.sh &>${REPIC_OUT_DIR}/iter_train.log
python ${REPIC_UTILS}/coord_converter.py ${REPIC_OUT_DIR}/* ${REPIC_OUT_DIR}/BOX/train/ -f box -t box -b ${REPIC_BOX_SIZE} --round 0 --force &>${REPIC_OUT_DIR}/convert_train.log

#  Val set prediction
export REPIC_MRC_DIR=${REPIC_VAL_MRC}
rm -rf ${REPIC_OUT_DIR}/*
bash ${REPIC}/iterative_particle_picking/run_epicker.sh &>${REPIC_OUT_DIR}/iter_val.log
python ${REPIC_UTILS}/coord_converter.py ${REPIC_OUT_DIR}/* ${REPIC_OUT_DIR}/BOX/val/ -f box -t box -b ${REPIC_BOX_SIZE} --round 0 --force &>${REPIC_OUT_DIR}/convert_val.log

#  Test set prediction
export REPIC_MRC_DIR=${REPIC_TEST_MRC}
rm -rf ${REPIC_OUT_DIR}/*
bash ${REPIC}/iterative_particle_picking/run_epicker.sh &>${REPIC_OUT_DIR}/iter_test.log
python ${REPIC_UTILS}/coord_converter.py ${REPIC_OUT_DIR}/* ${REPIC_OUT_DIR}/BOX/test/ -f box -t box -b ${REPIC_BOX_SIZE} --round 0 --force &>${REPIC_OUT_DIR}/convert_test.log

if ${GET_SCORE}; then
  python ${REPIC_UTILS}/score_detections.py -g ${REPIC_COORD}/train/${LABEL}/*.box -p ${REPIC_OUT_DIR}/BOX/train/*.box -c 0 &>${REPIC_OUT_DIR}/score_train.log
  python ${REPIC_UTILS}/score_detections.py -g ${REPIC_COORD}/val/*.box -p ${REPIC_OUT_DIR}/BOX/val/*.box -c 0 &>${REPIC_OUT_DIR}/score_val.log
  python ${REPIC_UTILS}/score_detections.py -g ${REPIC_COORD}/test/*.box -p ${REPIC_OUT_DIR}/BOX/test/*.box -c 0 &>${REPIC_OUT_DIR}/score_test.log
fi
