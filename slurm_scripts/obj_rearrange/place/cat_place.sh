#!/bin/bash

export EXP_CONFIG=habitat-baselines/habitat_baselines/config/rearrange/rl_skill.yaml
export ENVS=48
export GPUS=4

export INPUTS=goal_recep_rgb
export OBS_KEYS="['robot_head_rgb','goal_receptacle','joint','is_holding','relative_resting_position']"

export DATA_PATH="data/datasets/floorplanner/v1/\{split\}/cat_split_1_test_scene_10k.json.gz"
export EPS_KEY="fp"

export EXP_NAME=place/input_${INPUTS}_${ENVS}x${GPUS}_envs_${EPS_KEY}
mkdir -p slurm_logs/${EXP_NAME}
export HABITAT_SIM_LOG=quiet
export WB_RUN_NAME=${EXP_NAME}
export WB_GROUP=place
export MORE_OPTIONS="benchmark/rearrange=cat_place"
export MORE_OPTIONS="${MORE_OPTIONS} habitat.task.spawn_max_dists_to_obj=2.5"
export MORE_OPTIONS="${MORE_OPTIONS} habitat_baselines.rl.ddppo.pretrained_encoder=True habitat_baselines.rl.policy.ovrl=True habitat_baselines.rl.ddppo.pretrained_weights=resnet50_32bp_ovrl.pth habitat_baselines.rl.ddppo.backbone=resnet50"

sbatch --gpus ${GPUS} --ntasks-per-node ${GPUS} --error slurm_logs/${EXP_NAME}/err --output slurm_logs/${EXP_NAME}/out lang-rearrange-scripts/slurm_scripts/multi_node_slurm.sh