#!/bin/bash

export CONT_ACTIONS=true
if [ $CONT_ACTIONS = true ]; then
    export EXP_CONFIG=ovmm/rl_cont_skill.yaml
else
    export EXP_CONFIG=ovmm/rl_discrete_skill.yaml
fi
export ENVS=16
export NODES=4
export GPUS_PER_NODE=1

export EXPLORE_REWARD=0.0
export NO_AUGS=false
export NAVMESH_PEN=0.0
export OVERFIT=false
export MAX_SURFACE_STEPS=20
export DROPOUT=0.0
export NORMALIZE_VISUAL_INPUTS=false
export CONSTRAINT_BASE_IN_MANIP_MODE=false
export PRETRAINED=false
export COLL_PEN=0.0
export COLLISIONS_PEN=${COLL_PEN}
export COLLISIONS_END_PEN=${COLL_PEN}
export MAX_COLLS=-1 #0 # -1
export ONLY_NAV=false
export PRETRAINED_PATH="data/new_checkpoints/find_obj/input_goal_recep_depth_16x4x1_envs_new_train_explore_reward_1.0_no_augs_true_navmesh_pen_0.0_cont_actions_false_must_call_stop_true_must_face_true__remove_iou_again/latest.pth"
export SPARSE_REWARD=true
export SKILL_REWARD=0
export EPS_KEY="new_train"
export DATA_PATH="data/datasets/ovmm/train/episodes.json.gz"


if [ $OVERFIT = true ]; then
    export EPS_KEY="new_train_single_scene"
    export DATA_PATH="data/datasets/ovmm/train/content/102344022.json.gz"
fi

export CALL_STOP=false
# export MUST_FACE=true
# export CALL_STOP=true
export EXP_NAME=ovmm_new/input_${INPUTS}_${ENVS}x${GPUS_PER_NODE}x${NODES}_envs_${EPS_KEY}_no_augs_${NO_AUGS}_navmesh_pen_${NAVMESH_PEN}_cont_actions_${CONT_ACTIONS}_v2_max_${MAX_COLLS}_coll_pen_${COLL_PEN}_mobile_place_${ONLY_NAV}_call_stop_${CALL_STOP}_constraint_base_${CONSTRAINT_BASE_IN_MANIP_MODE}_updated_350_steps_wrong_drop_should_end_two_skills_skill_${SKILL_REWARD}

if [ $CONT_ACTIONS = true ]; then
    export MORE_OPTIONS="benchmark/ovmm=end_to_end_train"
elif [ $ONLY_NAV = true ]; then
        export MORE_OPTIONS="benchmark/ovmm=end_to_end_discrete_only_nav"
else
    export MORE_OPTIONS="benchmark/ovmm=end_to_end_discrete"
fi

export MORE_OPTIONS="${MORE_OPTIONS} habitat.dataset.split=train"

export MORE_OPTIONS="${MORE_OPTIONS} habitat.task.success_measure=ovmm_place_success habitat.task.place_init=True habitat.task.skills_completed_at_start=2"

export MORE_OPTIONS="${MORE_OPTIONS} habitat.task.measurements.ovmm_end_to_end_reward.skill_success_reward=${SKILL_REWARD}"

export MORE_OPTIONS="${MORE_OPTIONS} habitat.task.measurements.ovmm_place_reward.penalize_wrong_drop_once=True"
if [ $CONSTRAINT_BASE_IN_MANIP_MODE = true ]; then
    export MORE_OPTIONS="${MORE_OPTIONS} habitat.task.actions.base_velocity.constraint_base_in_manip_mode=True"
else 
    export MORE_OPTIONS="${MORE_OPTIONS} habitat.task.actions.base_velocity.constraint_base_in_manip_mode=False"
fi
export MORE_OPTIONS="${MORE_OPTIONS} habitat.task.measurements.force_terminate.max_accum_force=-1 habitat.task.measurements.force_terminate.max_instant_force=-1"
export MORE_OPTIONS="${MORE_OPTIONS} habitat.task.measurements.ovmm_place_reward.stability_reward=0.0 habitat.task.measurements.ovmm_place_reward.navmesh_violate_pen=${NAVMESH_PEN}"
if [ $NO_AUGS = true ]; then
    export MORE_OPTIONS="${MORE_OPTIONS} habitat.task.lab_sensors.object_segmentation_sensor.blank_out_prob=0.0 habitat.task.lab_sensors.start_recep_segmentation_sensor.blank_out_prob=0.0 habitat.task.lab_sensors.goal_recep_segmentation_sensor.blank_out_prob=0.0"
else
    export MORE_OPTIONS="${MORE_OPTIONS} habitat.task.lab_sensors.object_segmentation_sensor.blank_out_prob=${DROPOUT} habitat.task.lab_sensors.start_recep_segmentation_sensor.blank_out_prob=${DROPOUT} habitat.task.lab_sensors.goal_recep_segmentation_sensor.blank_out_prob=${DROPOUT}"
    export EXP_NAME="${EXP_NAME}_dropout_${DROPOUT}"
fi
# if [ $MUST_FACE = false ]; then
#     export MORE_OPTIONS="${MORE_OPTIONS} habitat.task.measurements.ovmm_nav_to_obj_success.must_look_at_targ=False  habitat.task.measurements.ovmm_nav_to_obj_reward.should_reward_turn=False"
# fi

# if [ $CALL_STOP = false ]; then
#     export MORE_OPTIONS="${MORE_OPTIONS} habitat.task.measurements.ovmm_nav_to_obj_success.must_call_stop=False"
# else
#     export MORE_OPTIONS="${MORE_OPTIONS} habitat.task.measurements.ovmm_nav_to_obj_success.min_object_coverage_iou=-1"
# fi

if [ $NORMALIZE_VISUAL_INPUTS = true ]; then
    export MORE_OPTIONS="${MORE_OPTIONS} habitat_baselines.rl.ddppo.normalize_visual_inputs=True"
else
    export MORE_OPTIONS="${MORE_OPTIONS} habitat_baselines.rl.ddppo.normalize_visual_inputs=False"
fi


export MORE_OPTIONS="${MORE_OPTIONS} habitat.task.measurements.ovmm_place_reward.max_steps_to_reach_surface=${MAX_SURFACE_STEPS}"

export MORE_OPTIONS="${MORE_OPTIONS} habitat.task.measurements.ovmm_place_reward.robot_collisions_pen=${COLLISIONS_PEN} habitat.task.measurements.ovmm_place_reward.robot_collisions_end_pen=${COLLISIONS_END_PEN} habitat.task.measurements.robot_collisions_terminate.max_num_collisions=${MAX_COLLS}"

# export MORE_OPTIONS="${MORE_OPTIONS} habitat.task.measurements.ovmm_nav_to_obj_reward.explore_reward=${EXPLORE_REWARD}"

# export MORE_OPTIONS="${MORE_OPTIONS} habitat.task.success_measure=nav_to_pos_succ habitat.task.measurements.ovmm_nav_to_obj_reward.should_reward_turn=False"

export MORE_OPTIONS="${MORE_OPTIONS} habitat.task.actions.arm_action.grasp_threshold=-0.8"

export MORE_OPTIONS="${MORE_OPTIONS} habitat_baselines.trainer_name=ddppo habitat_baselines.total_num_steps=1.0e9"

if [ $PRETRAINED = true ]; then
    export MORE_OPTIONS="${MORE_OPTIONS} habitat_baselines.rl.ddppo.pretrained_weights=${PRETRAINED_PATH} habitat_baselines.rl.ddppo.pretrained=True"
    export EXP_NAME="${EXP_NAME}_pretrained_warm_start"
fi

if [ $OVERFIT = true ]; then
    export MORE_OPTIONS="${MORE_OPTIONS} habitat.dataset.episode_indices_range=[0,1]"
    export EXP_NAME="${EXP_NAME}_overfit"
fi


if [ $CALL_STOP = false ]; then
    export MORE_OPTIONS="${MORE_OPTIONS} habitat.task.measurements.nav_orient_to_place_succ.must_call_stop=False"
else
    export MORE_OPTIONS="${MORE_OPTIONS} habitat.task.measurements.nav_orient_to_place_succ.must_call_stop=True"
fi

if [ $SPARSE_REWARD = true ]; then
    export MORE_OPTIONS="${MORE_OPTIONS} habitat.task.measurements.ovmm_place_reward.sparse_reward=${SPARSE_REWARD}"
fi

export MORE_OPTIONS="${MORE_OPTIONS} habitat.task.measurements.ovmm_place_reward.wrong_drop_should_end=True"

export MORE_OPTIONS="${MORE_OPTIONS} habitat.environment.max_episode_steps=350"
export MORE_OPTIONS="${MORE_OPTIONS} habitat_baselines.total_num_steps=1.0e9"

mkdir -p slurm_logs/${EXP_NAME}
export HABITAT_SIM_LOG=quiet

export WB_RUN_NAME=${EXP_NAME}
export WB_GROUP=ovmm_new


echo $EXP_NAME

sbatch  --gpus a40:$((NODES*GPUS_PER_NODE)) --ntasks-per-node ${GPUS_PER_NODE} --nodes ${NODES} --error slurm_logs/${EXP_NAME}/err --output slurm_logs/${EXP_NAME}/out lang-rearrange-scripts/slurm_scripts/basic_slurm.sh

# ENVS=1
# export EXP_NAME=${EXP_NAME}_debug_
# python -u -m habitat_baselines.run  \
#     --config-name ${EXP_CONFIG} habitat_baselines.evaluate=False habitat_baselines.tensorboard_dir="tb/${EXP_NAME}/" \
#     habitat_baselines.video_dir=video_dir/${EXP_NAME}/ habitat_baselines.eval_ckpt_path_dir="data/new_checkpoints/${EXP_NAME}/" \
#     habitat_baselines.checkpoint_folder="data/new_checkpoints/${EXP_NAME}/" \
#     habitat_baselines.wb.group=${WB_GROUP} habitat_baselines.wb.run_name=${WB_RUN_NAME} \
#     habitat_baselines.num_environments=${ENVS} habitat.dataset.data_path=${DATA_PATH} \
#     ${MORE_OPTIONS} habitat_baselines.writer_type=wb habitat_baselines.wb.entity=yvsriram habitat_baselines.wb.project_name=main_2212 \
#     habitat_baselines.rl.ppo.num_mini_batch=1 #habitat_baselines.load_resume_state_config=False