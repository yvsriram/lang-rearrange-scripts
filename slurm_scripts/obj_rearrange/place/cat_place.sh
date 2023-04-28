#!/bin/bash

export EXP_CONFIG=habitat-baselines/habitat_baselines/config/rearrange/rl_skill.yaml
export ENVS=16
export GPUS=4

export INPUTS=goal_recep_depth
export OBS_KEYS="['robot_head_depth','goal_receptacle','joint','is_holding','relative_resting_position']"

export EPS_KEY="fp_minitrain_wo_viewpoints"
export DATA_PATH="data/datasets/new_episodes/mini_cat_rearrange_floorplanner_without_viewpoints.json.gz"


export EXP_NAME=place/input_${INPUTS}_${ENVS}x${GPUS}_envs_${EPS_KEY}_relaxed_version_gloo_backbone


mkdir -p slurm_logs/${EXP_NAME}
export HABITAT_SIM_LOG=quiet
export WB_RUN_NAME=${EXP_NAME}
export WB_GROUP=place
export MORE_OPTIONS="benchmark/rearrange=cat_place"

export MORE_OPTIONS="${MORE_OPTIONS} habitat.task.spawn_max_dists_to_obj=2.5 habitat.task.biased_init=True habitat.task.measurements.place_reward.sparse_reward=False habitat.task.base_angle_noise=0.0 habitat.task.measurements.place_success.ee_resting_success_threshold=100 habitat.task.measurements.place_reward.drop_pen_type=constant habitat.task.measurements.place_reward.drop_pen=2.0"


export MORE_OPTIONS="${MORE_OPTIONS} habitat_baselines.trainer_name=ddppo "

sbatch --gpus ${GPUS} --ntasks-per-node ${GPUS} --error slurm_logs/${EXP_NAME}/err --output slurm_logs/${EXP_NAME}/out lang-rearrange-scripts/slurm_scripts/default_slurm.sh

# ENVS=2
# export EXP_NAME=${EXP_NAME}_debug
# python -u -m habitat_baselines.run  \
#     --exp-config ${EXP_CONFIG} --run-type train habitat_baselines.tensorboard_dir="tb/${EXP_NAME}/" \
#     habitat_baselines.video_dir=video_dir/${EXP_NAME}/ habitat_baselines.eval_ckpt_path_dir="data/new_checkpoints/${EXP_NAME}/" \
#     habitat_baselines.checkpoint_folder="data/new_checkpoints/${EXP_NAME}/" habitat.gym.obs_keys=${OBS_KEYS} \
#     habitat_baselines.wb.group=${WB_GROUP} habitat_baselines.wb.run_name=${WB_RUN_NAME} \
#     habitat_baselines.num_environments=${ENVS} habitat.dataset.data_path=${DATA_PATH} \
#     ${MORE_OPTIONS} habitat_baselines.writer_type=wb habitat_baselines.wb.entity=language-rearrangement habitat_baselines.wb.project_name=main_2212