#!/bin/bash

export EXP_CONFIG=ovmm/rl_discrete_skill.yaml
export ENVS=16
export NODES=2
export GPUS_PER_NODE=8
export INPUTS=goal_recep_depth
export OBS_KEYS="['head_depth','object_embedding','ovmm_nav_goal_segmentation','receptacle_segmentation','start_receptacle','robot_start_gps','robot_start_compass']"
export EXPLORE_REWARD=5.0
export NO_AUGS=true


export EPS_KEY="new_train"
export DATA_PATH="data/datasets/ovmm/train/episodes.json.gz"


export EXP_NAME=find_obj/input_${INPUTS}_${ENVS}x${GPUS_PER_NODE}x${NODES}_envs_${EPS_KEY}_explore_reward_${EXPLORE_REWARD}_no_augs_${NO_AUGS}

mkdir -p slurm_logs/${EXP_NAME}
export HABITAT_SIM_LOG=quiet
export WB_RUN_NAME=${EXP_NAME}
export WB_GROUP=find_obj

export MORE_OPTIONS="benchmark/ovmm=nav_to_obj"
export MORE_OPTIONS="${MORE_OPTIONS} habitat.dataset.split=train"


if [ $NO_AUGS = true ]; then
export MORE_OPTIONS="${MORE_OPTIONS} habitat.task.lab_sensors.ovmm_nav_goal_segmentation_sensor.blank_out_prob=0.0 habitat.task.lab_sensors.receptacle_segmentation_sensor.blank_out_prob=0.0"
fi

export MORE_OPTIONS="${MORE_OPTIONS} habitat.task.measurements.ovmm_nav_to_obj_reward.explore_reward=${EXPLORE_REWARD}"



export MORE_OPTIONS="${MORE_OPTIONS} habitat_baselines.trainer_name=ddppo habitat_baselines.total_num_steps=4.0e8"

echo $EXP_NAME

sbatch  --gpus $((NODES*GPUS_PER_NODE)) --ntasks-per-node ${GPUS_PER_NODE} --nodes ${NODES} --error slurm_logs/${EXP_NAME}/err --output slurm_logs/${EXP_NAME}/out lang-rearrange-scripts/slurm_scripts/default_slurm.sh

# ENVS=1
# export EXP_NAME=${EXP_NAME}_debug
# python -u -m habitat_baselines.run  \
#     --config-name ${EXP_CONFIG} habitat_baselines.evaluate=False habitat_baselines.tensorboard_dir="tb/${EXP_NAME}/" \
#     habitat_baselines.video_dir=video_dir/${EXP_NAME}/ habitat_baselines.eval_ckpt_path_dir="data/new_checkpoints/${EXP_NAME}/" \
#     habitat_baselines.checkpoint_folder="data/new_checkpoints/${EXP_NAME}/" habitat.gym.obs_keys=${OBS_KEYS} \
#     habitat_baselines.wb.group=${WB_GROUP} habitat_baselines.wb.run_name=${WB_RUN_NAME} \
#     habitat_baselines.num_environments=${ENVS} habitat.dataset.data_path=${DATA_PATH} \
#     ${MORE_OPTIONS} habitat_baselines.writer_type=wb habitat_baselines.wb.entity=yvsriram habitat_baselines.wb.project_name=main_2212 habitat_baselines.rl.ppo.num_mini_batch=1 habitat_baselines.load_resume_state_config=False
