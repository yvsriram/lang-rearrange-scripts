#!/bin/bash

export EXP_CONFIG=habitat_baselines/config/obj_rearrange/ddppo_pick.yaml
export VIS_RES=256
export ENVS=16
export GPUS=8
export EXP_NAME=cat_pick_dev/visual_priors/new_inits/geo_rearrange_easy_rgbd_${VIS_RES}_res_${ENVS}x${GPUS}_envs
mkdir -p slurm_logs/${EXP_NAME}
export SENSORS="['HEAD_DEPTH_SENSOR','HEAD_RGB_SENSOR']"
export OBS_KEYS="['robot_head_depth','robot_head_rgb','joint','is_holding','obj_start_sensor','relative_resting_position']"
export DATA_PATH=data/datasets/replica_cad/rearrange/v1/{split}/categorical_rearrange_easy.json.gz
export HABITAT_SIM_LOG=quiet

sbatch --gpus ${GPUS} --ntasks-per-node ${GPUS} --error slurm_logs/${EXP_NAME}/err --output slurm_logs/${EXP_NAME}/out lang-rearrange-scripts/slurm_scripts/multi_node_slurm.sh