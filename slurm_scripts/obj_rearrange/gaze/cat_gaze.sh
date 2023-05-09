#!/bin/bash

export EXP_CONFIG=habitat-baselines/habitat_baselines/config/rearrange/rl_skill.yaml

export ENVS=16
export GPUS=8

export INPUTS=obj_emb_seg_depth
export OBS_KEYS="['robot_head_depth','object_segmentation','object_embedding','joint','is_holding','relative_resting_position']"


export EPS_KEY="v2_fp_minitrain"
export DATA_PATH="data/episodes/rearrange/v2/minitrain/cat_npz-exp-filtered-v2.json.gz"

export EXP_NAME=gaze/input_${INPUTS}_${ENVS}x${GPUS}_envs_${EPS_KEY}_spawn_near_viewpoints


export distance_from=agent
export gaze_distance=1.0

# turned off by default
angle_reward_dist=0.0
angle_reward_scale=1.0


mkdir -p slurm_logs/${EXP_NAME}
export HABITAT_SIM_LOG=quiet
export WB_RUN_NAME=${EXP_NAME}
export WB_GROUP=gaze
export MORE_OPTIONS="benchmark/rearrange=cat_gaze"
export spawn_reference="view_points"
export spawn_reference_sampling="uniform" #"dist_to_center" 



export MORE_OPTIONS="${MORE_OPTIONS} habitat.task.spawn_max_dists_to_obj=0.0 habitat.task.num_spawn_attempts=200 habitat.task.spawn_reference=${spawn_reference} habitat.task.spawn_reference_sampling=${spawn_reference_sampling}"
export MORE_OPTIONS="${MORE_OPTIONS} habitat.task.actions.arm_action.gaze_distance_range=[0.1,${gaze_distance}] habitat.task.actions.arm_action.gaze_distance_from=${distance_from}"

export MORE_OPTIONS="${MORE_OPTIONS} habitat.task.measurements.pick_reward.angle_reward_min_dist=${angle_reward_dist} habitat.task.measurements.pick_reward.angle_reward_scale=${angle_reward_scale}"

export EXP_NAME="${EXP_NAME}_angle_reward_dist_${angle_reward_dist}_scale_${angle_reward_scale}"
export EXP_NAME="${EXP_NAME}_success_dist_${gaze_distance}"

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