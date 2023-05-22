#!/bin/bash

export EXP_CONFIG=habitat-baselines/habitat_baselines/config/rearrange/rl_skill.yaml
export ENVS=16
export GPUS=8

export INPUTS=goal_recep_depth
export OBS_KEYS="['robot_head_depth','goal_receptacle','joint','is_holding','object_embedding','goal_recep_segmentation']"



export EPS_KEY="v3_train"
export DATA_PATH="data/episodes/rearrange/v3/train/cat_npz-exp-filtered-v2.json.gz"

export EXP_NAME=place/input_${INPUTS}_${ENVS}x${GPUS}_envs_${EPS_KEY}_relaxed_version_with_stability_checks_start_in_nav_mode_with_manip_action_no_navmesh_penalty_new_reward_stability_0.05_pass_goal_seg


mkdir -p slurm_logs/${EXP_NAME}
export HABITAT_SIM_LOG=quiet
export WB_RUN_NAME=${EXP_NAME}
export WB_GROUP=place

export MORE_OPTIONS="benchmark/rearrange=cat_place"
export MORE_OPTIONS="${MORE_OPTIONS} habitat.dataset.split=train"


export MORE_OPTIONS="${MORE_OPTIONS} habitat.task.measurements.ovmm_place_reward.navmesh_violate_pen=0.0 habitat.task.measurements.ovmm_place_reward.stability_reward=0.05"

export MORE_OPTIONS="${MORE_OPTIONS} habitat_baselines.trainer_name=ddppo "

sbatch --gpus ${GPUS} --ntasks-per-node ${GPUS} --error slurm_logs/${EXP_NAME}/err --output slurm_logs/${EXP_NAME}/out lang-rearrange-scripts/slurm_scripts/multi_node_slurm.sh

# ENVS=2
# export EXP_NAME=${EXP_NAME}_debug
# python -u -m habitat_baselines.run  \
#     --exp-config ${EXP_CONFIG} --run-type train habitat_baselines.tensorboard_dir="tb/${EXP_NAME}/" \
#     habitat_baselines.video_dir=video_dir/${EXP_NAME}/ habitat_baselines.eval_ckpt_path_dir="data/new_checkpoints/${EXP_NAME}/" \
#     habitat_baselines.checkpoint_folder="data/new_checkpoints/${EXP_NAME}/" habitat.gym.obs_keys=${OBS_KEYS} \
#     habitat_baselines.wb.group=${WB_GROUP} habitat_baselines.wb.run_name=${WB_RUN_NAME} \
#     habitat_baselines.num_environments=${ENVS} habitat.dataset.data_path=${DATA_PATH} \
#     ${MORE_OPTIONS} habitat_baselines.writer_type=wb habitat_baselines.wb.entity=language-rearrangement habitat_baselines.wb.project_name=main_2212 habitat_baselines.rl.ppo.num_mini_batch=1