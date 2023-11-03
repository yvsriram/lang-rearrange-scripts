#!/bin/bash

export CONT_ACTIONS=false
if [ $CONT_ACTIONS = true ]; then
    export EXP_CONFIG=ovmm/rl_cont_skill.yaml
else
    export EXP_CONFIG=ovmm/rl_discrete_skill.yaml
fi
export ENVS=16
export NODES=2
export GPUS_PER_NODE=8

export EXPLORE_REWARD=0.0
export NO_AUGS=false
export NAVMESH_PEN=0.0
export OVERFIT=false
export DROPOUT=0.0
export NORMALIZE_VISUAL_INPUTS=false
export PRETRAINED=true
export COLLISIONS_PEN=0.5
export COLLISIONS_END_PEN=0.5
export MAX_COLLS=-1 #0 # -1
export CONSTRAINT_BASE_IN_MANIP_MODE=true
# export PRETRAINED_PATH="data/new_checkpoints/multi_task/input_complete_obs_space_16x1x4_envs_new_train_no_augs_false_navmesh_pen_0.0_cont_actions_false_place_only_max_-1_colls_constraint_base_true_STATIC_dropout_0.0/latest.pth"

export PRETRAINED_PATH="data/new_checkpoints/multi_task/input_complete_obs_space_16x8x2_envs_new_train_no_augs_false_navmesh_pen_0.0_cont_actions_false_place_only_max_-1_colls_constraint_base_true_STATIC_dropout_0.0/latest.pth"

export EPS_KEY="new_train"
export DATA_PATH="data/datasets/ovmm/train/episodes.json.gz"

export ALLOWED_SKILLS="['place']"

if [ $OVERFIT = true ]; then
    export EPS_KEY="new_train_single_scene"
    export DATA_PATH="data/datasets/ovmm/train/content/102344022.json.gz"
fi

export INPUTS=complete_obs_space #goal_recep_depth
# export OBS_KEYS="['head_depth','object_embedding','start_recep_segmentation','object_segmentation','receptacle_segmentation','start_receptacle','robot_start_gps','robot_start_compass','current_skill_id']"

export MUST_FACE=true
export CALL_STOP=true
export EXP_NAME=multi_task/input_${INPUTS}_${ENVS}x${GPUS_PER_NODE}x${NODES}_envs_${EPS_KEY}_no_augs_${NO_AUGS}_navmesh_pen_${NAVMESH_PEN}_cont_actions_${CONT_ACTIONS}_place_only_max_${MAX_COLLS}_colls_constraint_base_${CONSTRAINT_BASE_IN_MANIP_MODE}_STATIC_colls_pen_${COLLISIONS_PEN}




if [ $CONT_ACTIONS = true ]; then
    export MORE_OPTIONS="benchmark/ovmm=multi_task"
else
    # DO NOT HAVE THIS VERSION
    export MORE_OPTIONS="benchmark/ovmm=multi_task_discrete"
fi

export MORE_OPTIONS="${MORE_OPTIONS} habitat.dataset.split=train"

export MORE_OPTIONS="${MORE_OPTIONS} habitat.task.allowed_skills=${ALLOWED_SKILLS}"
export MORE_OPTIONS="${MORE_OPTIONS} habitat_baselines.rl.policy.num_value_heads=4"

## STATIC PLACE PARAMS
export MORE_OPTIONS="${MORE_OPTIONS} habitat/task/ovmm=multi_task_discrete_stationary habitat.task.base_angle_noise=0.0873 habitat.task.start_in_manip_mode=True "

if [ $NO_AUGS = true ]; then
    export MORE_OPTIONS="${MORE_OPTIONS} habitat.task.lab_sensors.ovmm_nav_goal_segmentation_sensor.blank_out_prob=0.0 habitat.task.lab_sensors.receptacle_segmentation_sensor.blank_out_prob=0.0"
else
    export MORE_OPTIONS="${MORE_OPTIONS} habitat.task.lab_sensors.ovmm_nav_goal_segmentation_sensor.blank_out_prob=${DROPOUT} habitat.task.lab_sensors.receptacle_segmentation_sensor.blank_out_prob=${DROPOUT}"
    export EXP_NAME="${EXP_NAME}_dropout_${DROPOUT}"
fi

export MORE_OPTIONS="${MORE_OPTIONS} habitat.task.measurements.ovmm_place_reward.robot_collisions_pen=${COLLISIONS_PEN} habitat.task.measurements.ovmm_place_reward.robot_collisions_end_pen=${COLLISIONS_END_PEN} habitat.task.measurements.robot_collisions_terminate.max_num_collisions=${MAX_COLLS}"


if [ $MUST_FACE = false ]; then
    export MORE_OPTIONS="${MORE_OPTIONS} habitat.task.measurements.ovmm_nav_to_obj_success.must_look_at_targ=False  habitat.task.measurements.ovmm_nav_to_obj_reward.should_reward_turn=False"
fi

if [ $CALL_STOP = false ]; then
    export MORE_OPTIONS="${MORE_OPTIONS} habitat.task.measurements.ovmm_nav_to_obj_success.must_call_stop=False"
else
    export MORE_OPTIONS="${MORE_OPTIONS} habitat.task.measurements.ovmm_nav_to_obj_success.min_object_coverage_iou=-1"
fi

if [ $NORMALIZE_VISUAL_INPUTS = true ]; then
    export MORE_OPTIONS="${MORE_OPTIONS} habitat_baselines.rl.ddppo.normalize_visual_inputs=True"
else
    export MORE_OPTIONS="${MORE_OPTIONS} habitat_baselines.rl.ddppo.normalize_visual_inputs=False"
fi

# export MORE_OPTIONS="${MORE_OPTIONS} habitat.task.actions.move_forward.constraint_base_in_manip_mode=${CONSTRAINT_BASE_IN_MANIP_MODE} habitat.task.actions.turn_left.constraint_base_in_manip_mode=${CONSTRAINT_BASE_IN_MANIP_MODE} habitat.task.actions.turn_right.constraint_base_in_manip_mode=${CONSTRAINT_BASE_IN_MANIP_MODE}"


# export MORE_OPTIONS="${MORE_OPTIONS} habitat.task.measurements.ovmm_nav_to_obj_reward.explore_reward=${EXPLORE_REWARD}"

# export MORE_OPTIONS="${MORE_OPTIONS} habitat.task.success_measure=nav_to_pos_succ habitat.task.measurements.ovmm_nav_to_obj_reward.should_reward_turn=False"

export MORE_OPTIONS="${MORE_OPTIONS} habitat_baselines.trainer_name=ddppo habitat_baselines.total_num_steps=4.0e8  habitat.task.measurements.ovmm_nav_to_obj_reward.navmesh_violate_pen=$NAVMESH_PEN"

if [ $PRETRAINED = true ]; then
    export MORE_OPTIONS="${MORE_OPTIONS} habitat_baselines.rl.ddppo.pretrained_weights=${PRETRAINED_PATH} habitat_baselines.rl.ddppo.pretrained=True"
    export EXP_NAME="${EXP_NAME}_pretrained_warm_start"
fi

if [ $OVERFIT = true ]; then
    export MORE_OPTIONS="${MORE_OPTIONS} habitat.dataset.episode_indices_range=[0,1]"
    export EXP_NAME="${EXP_NAME}_overfit"
fi


mkdir -p slurm_logs/${EXP_NAME}
export HABITAT_SIM_LOG=quiet

export WB_RUN_NAME=${EXP_NAME}
export WB_GROUP=multi_task


echo $EXP_NAME

sbatch  --gpus $((NODES*GPUS_PER_NODE)) --ntasks-per-node ${GPUS_PER_NODE} --nodes ${NODES} --error slurm_logs/${EXP_NAME}/err --output slurm_logs/${EXP_NAME}/out lang-rearrange-scripts/slurm_scripts/basic_slurm.sh

# ENVS=1
# export EXP_NAME=${EXP_NAME}_debug_more_actions_
# python -u -m habitat_baselines.run  \
#     --config-name ${EXP_CONFIG} habitat_baselines.evaluate=False habitat_baselines.tensorboard_dir="tb/${EXP_NAME}/" \
#     habitat_baselines.video_dir=video_dir/${EXP_NAME}/ habitat_baselines.eval_ckpt_path_dir="data/new_checkpoints/${EXP_NAME}/" \
#     habitat_baselines.checkpoint_folder="data/new_checkpoints/${EXP_NAME}/" \
#     habitat_baselines.wb.group=${WB_GROUP} habitat_baselines.wb.run_name=${WB_RUN_NAME} \
#     habitat_baselines.num_environments=${ENVS} habitat.dataset.data_path=${DATA_PATH} \
#     ${MORE_OPTIONS} habitat_baselines.writer_type=wb habitat_baselines.wb.entity=yvsriram habitat_baselines.wb.project_name=main_2212   \
#     habitat_baselines.rl.ppo.num_mini_batch=1 #habitat_baselines.load_resume_state_config=False