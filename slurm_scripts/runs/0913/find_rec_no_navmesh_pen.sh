#!/bin/bash

export CONT_ACTIONS=false
if [ $CONT_ACTIONS = true ]; then
export EXP_CONFIG=ovmm/rl_cont_skill.yaml
else
export EXP_CONFIG=ovmm/rl_discrete_skill.yaml
fi
export ENVS=16
export GPUS_PER_NODE=8
export NODES=2
export INPUTS=goal_recep_depth
export OBS_KEYS="['head_depth','ovmm_nav_goal_segmentation','receptacle_segmentation','goal_receptacle','robot_start_gps','robot_start_compass']"

export NAVMESH_PEN=0.0
export EPS_KEY="new_train"
export DATA_PATH="data/datasets/ovmm/train/episodes.json.gz"
export EXPLORE_REWARD=0.0
export NO_AUGS=true

export MUST_FACE=true
export CALL_STOP=true

export EXP_NAME=find_rec/input_${INPUTS}_${ENVS}x${GPUS_PER_NODE}x${NODES}_envs_${EPS_KEY}_explore_reward_${EXPLORE_REWARD}_no_augs_${NO_AUGS}_navmesh_pen_${NAVMESH_PEN}_cont_actions_${CONT_ACTIONS}_must_call_stop_${CALL_STOP}_must_face_${MUST_FACE}_remove_iou


mkdir -p slurm_logs/${EXP_NAME}
export HABITAT_SIM_LOG=quiet
export WB_RUN_NAME=${EXP_NAME}
export WB_GROUP=find_rec

if [ $CONT_ACTIONS = true ]; then
export MORE_OPTIONS="benchmark/ovmm=nav_to_rec"
export MORE_OPTIONS="habitat/task/ovmm=nav_to_rec_cont"
else
export MORE_OPTIONS="benchmark/ovmm=nav_to_rec"
fi

export MORE_OPTIONS="${MORE_OPTIONS} habitat.dataset.split=train"


export MORE_OPTIONS="${MORE_OPTIONS} habitat_baselines.trainer_name=ddppo habitat_baselines.total_num_steps=4.0e8 habitat.task.measurements.ovmm_nav_to_obj_reward.navmesh_violate_pen=$NAVMESH_PEN"

export MORE_OPTIONS="${MORE_OPTIONS} habitat.task.measurements.ovmm_nav_to_obj_success.min_object_coverage_iou=-1"

if [ $NO_AUGS = true ]; then
export MORE_OPTIONS="${MORE_OPTIONS} habitat.task.lab_sensors.ovmm_nav_goal_segmentation_sensor.blank_out_prob=0.0 habitat.task.lab_sensors.receptacle_segmentation_sensor.blank_out_prob=0.0 habitat.task.base_angle_noise=0.0"
fi

if [ $MUST_FACE = false ]; then
export MORE_OPTIONS="${MORE_OPTIONS} habitat.task.measurements.ovmm_nav_to_obj_success.must_look_at_targ=False  habitat.task.measurements.ovmm_nav_to_obj_reward.should_reward_turn=False"
fi

if [ $CALL_STOP = false ]; then
export MORE_OPTIONS="${MORE_OPTIONS} habitat.task.measurements.ovmm_nav_to_obj_success.must_call_stop=False"
fi
export MORE_OPTIONS="${MORE_OPTIONS} habitat.task.measurements.ovmm_nav_to_obj_reward.explore_reward=${EXPLORE_REWARD}"

echo $EXP_NAME

sbatch --gpus $((NODES*GPUS_PER_NODE)) --ntasks-per-node ${GPUS_PER_NODE} --nodes ${NODES}  --error slurm_logs/${EXP_NAME}/err --output slurm_logs/${EXP_NAME}/out lang-rearrange-scripts/slurm_scripts/default_slurm.sh

ENVS=1
export EXP_NAME=${EXP_NAME}_debug_
python -u -m habitat_baselines.run  \
    --config-name ${EXP_CONFIG} habitat_baselines.evaluate=False habitat_baselines.tensorboard_dir="tb/${EXP_NAME}/" \
    habitat_baselines.video_dir=video_dir/${EXP_NAME}/ habitat_baselines.eval_ckpt_path_dir="data/new_checkpoints/${EXP_NAME}/" \
    habitat_baselines.checkpoint_folder="data/new_checkpoints/${EXP_NAME}/" habitat.gym.obs_keys=${OBS_KEYS} \
    habitat_baselines.wb.group=${WB_GROUP} habitat_baselines.wb.run_name=${WB_RUN_NAME} \
    habitat_baselines.num_environments=${ENVS} habitat.dataset.data_path=${DATA_PATH} \
    ${MORE_OPTIONS} habitat_baselines.writer_type=wb habitat_baselines.wb.entity=yvsriram habitat_baselines.wb.project_name=main_2212 habitat_baselines.rl.ppo.num_mini_batch=1 habitat_baselines.load_resume_state_config=False
