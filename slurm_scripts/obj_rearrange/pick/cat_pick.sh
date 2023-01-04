#!/bin/bash

export EXP_CONFIG=habitat-baselines/habitat_baselines/config/rearrange/rl_skill.yaml
export ENVS=16
export GPUS=4

export INPUTS=obj_category_rgbd
export OBS_KEYS="['robot_head_depth','robot_head_rgb','object_category','joint','is_holding','relative_resting_position']"

export DATA_PATH="data/datasets/replica_cad/rearrange/v1/\{split\}/categorical_rearrange_easy.json.gz"
export EPS_KEY="regular"

export EXP_NAME=pick/default_input_${INPUTS}_${ENVS}x${GPUS}_envs_pass_priors_${EPS_KEY}
mkdir -p slurm_logs/${EXP_NAME}
export HABITAT_SIM_LOG=quiet
export WB_RUN_NAME=${EXP_NAME}
export WB_GROUP=pick
export MORE_OPTIONS="benchmark/rearrange=cat_pick"
#export MORE_OPTIONS="${MORE_OPTIONS} habitat_baselines.trainer_name=ddppo"
#export MORE_OPTIONS="${MORE_OPTIONS} habitat_baselines.rl.ddppo.pretrained_encoder=True habitat_baselines.rl.policy.ovrl=True habitat_baselines.rl.ddppo.pretrained_weights=resnet50_32bp_ovrl.pth habitat_baselines.rl.ddppo.backbone=resnet50"

sbatch --gpus ${GPUS} --ntasks-per-node ${GPUS} --error slurm_logs/${EXP_NAME}/err --output slurm_logs/${EXP_NAME}/out lang-rearrange-scripts/slurm_scripts/multi_node_slurm.sh
