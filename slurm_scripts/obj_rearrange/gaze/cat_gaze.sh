#!/bin/bash

export EXP_CONFIG=habitat-baselines/habitat_baselines/config/rearrange/rl_skill.yaml

export ENVS=16
export GPUS=8

export INPUTS=obj_emb_seg_depth
export OBS_KEYS="['robot_head_depth','start_receptacle','start_recep_segmentation','object_segmentation','object_embedding','joint','is_holding']"


export EPS_KEY="v3_train"
export DATA_PATH="data/episodes/rearrange/v3/train/cat_npz-exp-filtered-v2.json.gz"


export gaze_distance=0.8

# turned off by default
angle_reward_dist=0.0
angle_reward_scale=1.0


mkdir -p slurm_logs/${EXP_NAME}
export HABITAT_SIM_LOG=quiet
export WB_RUN_NAME=${EXP_NAME}
export WB_GROUP=gaze
export MORE_OPTIONS="benchmark/rearrange=cat_gaze"


export MORE_OPTIONS="${MORE_OPTIONS} habitat.task.actions.arm_action.gaze_distance_range=[0.1,${gaze_distance}]"

export MORE_OPTIONS="${MORE_OPTIONS} habitat.task.measurements.pick_reward.angle_reward_min_dist=${angle_reward_dist} habitat.task.measurements.pick_reward.angle_reward_scale=${angle_reward_scale}"


export MORE_OPTIONS="${MORE_OPTIONS} habitat_baselines.trainer_name=ddppo"

export EXP_NAME=gaze/input_${INPUTS}_${ENVS}x${GPUS}_envs_${EPS_KEY}-wrng_grsp_shld_end-updtd_tilt_delta

export EXP_NAME="${EXP_NAME}_angle_reward_dist-${angle_reward_dist}_scale-${angle_reward_scale}"
export EXP_NAME="${EXP_NAME}-success_dist_${gaze_distance}"

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