#!/bin/bash

export EXP_CONFIG=ovmm/rl_cont_skill.yaml

export ENVS=16
export GPUS_PER_NODE=1
export NODES=8

export INPUTS=obj_emb_seg_depth
export OBS_KEYS="['head_depth','start_receptacle','start_recep_segmentation','object_segmentation','object_embedding','joint']"


export EPS_KEY="new_train"
# export DATA_PATH="data/episodes/rearrange/v3/train/cat_npz-exp-filtered-v2.json.gz"
export DATA_PATH="data/datasets/ovmm/train/episodes.json.gz"


export gaze_distance=0.8

# turned off by default
angle_reward_dist=0.0
angle_reward_scale=1.0


export HABITAT_SIM_LOG=quiet
export WB_GROUP=gaze
export MORE_OPTIONS="benchmark/ovmm=gaze"
export MORE_OPTIONS="${MORE_OPTIONS} habitat_baselines.total_num_steps=1.0e9"

export MORE_OPTIONS="${MORE_OPTIONS} habitat.task.actions.arm_action.gaze_distance_range=[0.1,${gaze_distance}]"

export MORE_OPTIONS="${MORE_OPTIONS} habitat.task.measurements.pick_reward.angle_reward_min_dist=${angle_reward_dist} habitat.task.measurements.pick_reward.angle_reward_scale=${angle_reward_scale}"_again


export NO_AUGS=True

export MORE_OPTIONS="${MORE_OPTIONS} habitat_baselines.trainer_name=ddppo habitat.dataset.split=train"

export EXP_NAME=gaze/input_${INPUTS}_${ENVS}x${GPUS}x${NODES}_envs_${EPS_KEY}

export EXP_NAME="${EXP_NAME}_angle_reward_dist-${angle_reward_dist}_scale-${angle_reward_scale}"
export EXP_NAME="${EXP_NAME}-success_dist_${gaze_distance}"_no_augs_${NO_AUGS}_train_long

if [ $NO_AUGS = true ]; then
export MORE_OPTIONS="${MORE_OPTIONS} habitat.task.lab_sensors.object_segmentation_sensor.blank_out_prob=0.0 habitat.task.lab_sensors.start_recep_segmentation_sensor.blank_out_prob=0.0 habitat.task.base_angle_noise=0.0"
fi

mkdir -p slurm_logs/${EXP_NAME}
export WB_RUN_NAME=${EXP_NAME}

sbatch --gpus a40:$((NODES*GPUS_PER_NODE)) --ntasks-per-node ${GPUS_PER_NODE} --nodes ${NODES} --error slurm_logs/${EXP_NAME}/err --output slurm_logs/${EXP_NAME}/out lang-rearrange-scripts/slurm_scripts/default_slurm.sh


# ENVS=1
# export EXP_NAME=${EXP_NAME}_debug_
# python -u -m habitat_baselines.run  \
#     --config-name ${EXP_CONFIG} habitat_baselines.evaluate=False habitat_baselines.tensorboard_dir="tb/${EXP_NAME}/" \
#     habitat_baselines.video_dir=video_dir/${EXP_NAME}/ habitat_baselines.eval_ckpt_path_dir="data/new_checkpoints/${EXP_NAME}/" \
#     habitat_baselines.checkpoint_folder="data/new_checkpoints/${EXP_NAME}/" habitat.gym.obs_keys=${OBS_KEYS} \
#     habitat_baselines.wb.group=${WB_GROUP} habitat_baselines.wb.run_name=${WB_RUN_NAME} \
#     habitat_baselines.num_environments=${ENVS} habitat.dataset.data_path=${DATA_PATH} \
#     ${MORE_OPTIONS} habitat_baselines.writer_type=wb habitat_baselines.wb.entity=yvsriram habitat_baselines.wb.project_name=main_2212 habitat_baselines.rl.ppo.num_mini_batch=1 
