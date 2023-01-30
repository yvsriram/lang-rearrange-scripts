#!/bin/bash

export EXP_CONFIG=habitat-baselines/habitat_baselines/config/rearrange/rl_skill.yaml
export ENVS=16
export GPUS=8

export INPUTS=obj_category_rgbd
export OBS_KEYS="['robot_head_depth','robot_head_rgb','object_category','joint','is_holding','relative_resting_position']"

export DATA_PATH="data/datasets/floorplanner/v1/\{split\}/cat_split_1_test_scene_10k.json.gz"
export EPS_KEY="fp"

export EXP_NAME=pick/input_${INPUTS}_${ENVS}x${GPUS}_envs_${EPS_KEY}
mkdir -p slurm_logs/${EXP_NAME}
export HABITAT_SIM_LOG=quiet
export WB_RUN_NAME=${EXP_NAME}
export WB_GROUP=pick
export MORE_OPTIONS="benchmark/rearrange=cat_pick"
export MORE_OPTIONS="${MORE_OPTIONS} habitat.task.spawn_max_dists_to_obj=1.5 habitat.task.biased_init=True"
#export MORE_OPTIONS="${MORE_OPTIONS} habitat_baselines.trainer_name=ddppo"
#export MORE_OPTIONS="${MORE_OPTIONS} habitat_baselines.rl.ddppo.pretrained_encoder=True habitat_baselines.rl.policy.ovrl=True habitat_baselines.rl.ddppo.pretrained_weights=resnet50_32bp_ovrl.pth habitat_baselines.rl.ddppo.backbone=resnet50"

ENVS=1
# sbatch --gpus ${GPUS} --ntasks-per-node ${GPUS} --error slurm_logs/${EXP_NAME}/err --output slurm_logs/${EXP_NAME}/out lang-rearrange-scripts/slurm_scripts/multi_node_slurm.sh
python -u -m habitat_baselines.run  \
    --exp-config ${EXP_CONFIG} --run-type train habitat_baselines.tensorboard_dir="tb/${EXP_NAME}/" \
    habitat_baselines.video_dir=video_dir/${EXP_NAME}/ habitat_baselines.eval_ckpt_path_dir="data/new_checkpoints/${EXP_NAME}/" \
    habitat_baselines.checkpoint_folder="data/new_checkpoints/${EXP_NAME}/" habitat.gym.obs_keys=${OBS_KEYS} \
    habitat_baselines.wb.group=${WB_GROUP} habitat_baselines.wb.run_name=${WB_RUN_NAME} \
    habitat_baselines.num_environments=${ENVS} habitat.dataset.data_path=${DATA_PATH} \
    ${MORE_OPTIONS} habitat_baselines.writer_type=wb