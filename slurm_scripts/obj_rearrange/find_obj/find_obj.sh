#!/bin/bash

export EXP_CONFIG=ovmm/rl_discrete_skill.yaml
export ENVS=16
export GPUS=8
export NODES=2
export INPUTS=goal_recep_depth
export OBS_KEYS="['head_depth','object_embedding','ovmm_nav_goal_segmentation','receptacle_segmentation','start_receptacle','robot_start_gps','robot_start_compass']"


export EPS_KEY="new_train"
export DATA_PATH="data/datasets/ovmm/train/episodes.json.gz"

export EXP_NAME=find_obj/input_${INPUTS}_${ENVS}x${GPUS}x${NODES}_envs_${EPS_KEY}


mkdir -p slurm_logs/${EXP_NAME}
export HABITAT_SIM_LOG=quiet
export WB_RUN_NAME=${EXP_NAME}
export WB_GROUP=cat_place

export MORE_OPTIONS="benchmark/ovmm=nav_to_obj"
export MORE_OPTIONS="${MORE_OPTIONS} habitat.dataset.split=train"


export MORE_OPTIONS="${MORE_OPTIONS} habitat_baselines.trainer_name=ddppo habitat_baselines.total_num_steps=4.0e8"

echo $EXP_NAME

sbatch --gpus ${GPUS} --ntasks-per-node ${GPUS} --nodes ${NODES} --error slurm_logs/${EXP_NAME}/err --output slurm_logs/${EXP_NAME}/out lang-rearrange-scripts/slurm_scripts/default_slurm.sh

# ENVS=1
# export EXP_NAME=${EXP_NAME}_debug
# python -u -m habitat_baselines.run  \
#     --config-name ${EXP_CONFIG} habitat_baselines.evaluate=False habitat_baselines.tensorboard_dir="tb/${EXP_NAME}/" \
#     habitat_baselines.video_dir=video_dir/${EXP_NAME}/ habitat_baselines.eval_ckpt_path_dir="data/new_checkpoints/${EXP_NAME}/" \
#     habitat_baselines.checkpoint_folder="data/new_checkpoints/${EXP_NAME}/" habitat.gym.obs_keys=${OBS_KEYS} \
#     habitat_baselines.wb.group=${WB_GROUP} habitat_baselines.wb.run_name=${WB_RUN_NAME} \
#     habitat_baselines.num_environments=${ENVS} habitat.dataset.data_path=${DATA_PATH} \
#     ${MORE_OPTIONS} habitat_baselines.writer_type=wb habitat_baselines.wb.entity=yvsriram habitat_baselines.wb.project_name=main_2212 habitat_baselines.rl.ppo.num_mini_batch=1 habitat_baselines.load_resume_state_config=False
