#!/bin/bash

export EXP_CONFIG=ovmm/rl_skill.yaml
export ENVS=16
export NODES=8
export GPUS=8

export INPUTS=goal_recep_depth
export OBS_KEYS="['head_depth','goal_receptacle','joint','is_holding','object_embedding','goal_recep_segmentation']"


export EPS_KEY="v4_train"
# export DATA_PATH="data/episodes/rearrange/v4/train/cat_npz-exp.json.gz"
export DATA_PATH="data/datasets/ovmm/train/episodes.json.gz"

export EXP_NAME=place/input_${INPUTS}_${ENVS}x${GPUS}x${NODES}_envs_${EPS_KEY}_stability_checks_start_in_nav_mode_with_manip_action_penalty_test_add_penalities_new_again


mkdir -p slurm_logs/${EXP_NAME}
export HABITAT_SIM_LOG=quiet
export WB_RUN_NAME=${EXP_NAME}
export WB_GROUP=cat_place

export MORE_OPTIONS="benchmark/ovmm=place"
export MORE_OPTIONS="${MORE_OPTIONS} habitat.dataset.split=train"


export MORE_OPTIONS="${MORE_OPTIONS}   habitat.task.measurements.ovmm_place_reward.stability_reward=1 habitat.task.measurements.ovmm_place_reward.navmesh_violate_pen=0.0"
export MORE_OPTIONS="${MORE_OPTIONS} habitat_baselines.trainer_name=ddppo "

# export MORE_OPTIONS="${MORE_OPTIONS} habitat.task.measurements.ovmm_place_reward.sparse_reward=False habitat.task.measurements.ovmm_place_reward.max_steps_to_reach_surface=20"
# export EXP_NAME=${EXP_NAME}_sparse_reward_False_max_steps_to_reach_surface_20
echo $EXP_NAME

sbatch --gpus ${GPUS} --ntasks-per-node ${GPUS} --nodes ${NODES} --error slurm_logs/${EXP_NAME}/err --output slurm_logs/${EXP_NAME}/out lang-rearrange-scripts/slurm_scripts/default_slurm.sh

# python speed_profile.py --cfg-path habitat-lab/habitat/config/benchmark/rearrange/cat_nav_to_rec.yaml habitat.dataset.data_path=data/episodes/rearrange/v4/val/cat_npz-exp.json.gz habitat.dataset.split=val 
# ENVS=1
# export EXP_NAME=${EXP_NAME}_debug
# python -u -m habitat_baselines.run  \
#     --config-name ${EXP_CONFIG} habitat_baselines.evaluate=False habitat_baselines.tensorboard_dir="tb/${EXP_NAME}/" \
#     habitat_baselines.video_dir=video_dir/${EXP_NAME}/ habitat_baselines.eval_ckpt_path_dir="data/new_checkpoints/${EXP_NAME}/" \
#     habitat_baselines.checkpoint_folder="data/new_checkpoints/${EXP_NAME}/" habitat.gym.obs_keys=${OBS_KEYS} \
#     habitat_baselines.wb.group=${WB_GROUP} habitat_baselines.wb.run_name=${WB_RUN_NAME} \
#     habitat_baselines.num_environments=${ENVS} habitat.dataset.data_path=${DATA_PATH} \
#     ${MORE_OPTIONS} habitat_baselines.writer_type=wb habitat_baselines.wb.entity=language-rearrangement habitat_baselines.wb.project_name=main_2212 habitat_baselines.rl.ppo.num_mini_batch=1 habitat_baselines.load_resume_state_config=False
