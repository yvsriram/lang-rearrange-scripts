#!/bin/bash

export EXP_CONFIG=ovmm/rl_cont_skill.yaml
export ENVS=16
export GPUS_PER_NODE=8
export NODES=2

export INPUTS=goal_recep_depth
export OBS_KEYS="['head_depth','goal_receptacle','joint','is_holding','object_embedding','goal_recep_segmentation']"


export EPS_KEY="new_train"
export DATA_PATH="data/datasets/ovmm/train/episodes.json.gz"
export OVERFIT=false
export SPARSE_REWARD=false

export MAX_EPISODE_STEPS=350
export MAX_SURFACE_STEPS=20
export CONSTRAINT_BASE_IN_MANIP_MODE=false
export STATIC=false
export COLLISIONS_PEN=0.0
export COLLISIONS_END_PEN=0.0
export MAX_COLLS=-1 #0 # -1
export NORMALIZE_VISUAL_INPUTS=true
if [ $STATIC = true ]; then
    export SKILL="static_place"
else
    export SKILL="place"
fi

export PRETRAINED=false
# export PRETRAINED_PATH="data/new_checkpoints/place/input_goal_recep_depth_16x4x1_envs_new_train_no_colls_term_no_augs_no_vel_thresh_stability_0_drop_pen_once_True_sparse_true_max_episode_steps_350_max_surface_steps_20_constraint_base_manip_mode_false_pub_branch/ckpt.9.pth"

export PRETRAINED_PATH="data/new_checkpoints/place/input_goal_recep_depth_16x1x1_envs_new_train_no_colls_term_no_augs_no_vel_thresh_stability_0_drop_pen_once_True_sparse_false_max_episode_steps_350_max_surface_steps_20_constraint_base_manip_mode_false_pub_branch/ckpt.4.pth"


export EXP_NAME=${SKILL}/input_${INPUTS}_${ENVS}x${GPUS_PER_NODE}x${NODES}_envs_${EPS_KEY}_no_augs_stability_0_drop_pen_once_True_sparse_${SPARSE_REWARD}_max_surface_steps_${MAX_SURFACE_STEPS}_constraint_base_manip_mode_${CONSTRAINT_BASE_IN_MANIP_MODE}_vel_constraints_coll_pen_${COLLISIONS_PEN}_${COLLISIONS_END_PEN}_end_pen_max_${MAX_COLLS}_colls



if [ $OVERFIT = true ]; then
    export EXP_NAME="${EXP_NAME}_overfit"
fi




export WB_GROUP=cat_${SKILL}

export MORE_OPTIONS="benchmark/ovmm=${SKILL}"
export MORE_OPTIONS="${MORE_OPTIONS} habitat.dataset.split=train"


if [ $NORMALIZE_VISUAL_INPUTS = true ]; then
    export MORE_OPTIONS="${MORE_OPTIONS} habitat_baselines.rl.ddppo.normalize_visual_inputs=True"
else
    export MORE_OPTIONS="${MORE_OPTIONS} habitat_baselines.rl.ddppo.normalize_visual_inputs=False"
fi

export MORE_OPTIONS="${MORE_OPTIONS} habitat_baselines.total_num_steps=1.0e9"

export MORE_OPTIONS="${MORE_OPTIONS} habitat.task.measurements.ovmm_place_reward.stability_reward=0.0 habitat.task.measurements.ovmm_place_reward.navmesh_violate_pen=0.0"
export MORE_OPTIONS="${MORE_OPTIONS} habitat.environment.max_episode_steps=${MAX_EPISODE_STEPS}"

# do not terminate on collisions
export MORE_OPTIONS="${MORE_OPTIONS} habitat.task.measurements.ovmm_place_reward.robot_collisions_pen=${COLLISIONS_PEN} habitat.task.measurements.ovmm_place_reward.robot_collisions_end_pen=${COLLISIONS_END_PEN} habitat.task.measurements.robot_collisions_terminate.max_num_collisions=${MAX_COLLS}"

# no force terminate
export MORE_OPTIONS="${MORE_OPTIONS} habitat.task.measurements.force_terminate.max_accum_force=-1 habitat.task.measurements.force_terminate.max_instant_force=-1"

export MORE_OPTIONS="${MORE_OPTIONS} habitat.task.measurements.ovmm_place_reward.max_steps_to_reach_surface=${MAX_SURFACE_STEPS}"

export MORE_OPTIONS="${MORE_OPTIONS} habitat_baselines.trainer_name=ddppo"

echo $EXP_NAME
export MORE_OPTIONS="${MORE_OPTIONS} habitat.task.measurements.ovmm_place_reward.penalize_wrong_drop_once=True"
if [ $CONSTRAINT_BASE_IN_MANIP_MODE = true ]; then
    export MORE_OPTIONS="${MORE_OPTIONS} habitat.task.actions.base_velocity.constraint_base_in_manip_mode=True"
elif [ $SKILL = "place" ]; then
    export MORE_OPTIONS="${MORE_OPTIONS} habitat.task.actions.base_velocity.constraint_base_in_manip_mode=False"
fi
# python speed_profile.py --cfg-path habitat-lab/habitat/config/benchmark/rearrange/cat_nav_to_rec.yaml habitat.dataset.data_path=data/episodes/rearrange/v4/val/cat_npz-exp.json.gz habitat.dataset.split=val 

if [ $PRETRAINED = true ]; then
    export MORE_OPTIONS="${MORE_OPTIONS} habitat_baselines.rl.ddppo.pretrained_weights=${PRETRAINED_PATH} habitat_baselines.rl.ddppo.pretrained=True"
    export EXP_NAME="${EXP_NAME}_pretrained_warm_start"
fi

if [ $OVERFIT = true ]; then
    export MORE_OPTIONS="${MORE_OPTIONS} habitat.dataset.episode_indices_range=[0,1]"
    export DATA_PATH="data/datasets/ovmm/train/content/102344022.json.gz"
fi

if [ $SPARSE_REWARD = true ]; then
    export MORE_OPTIONS="${MORE_OPTIONS} habitat.task.measurements.ovmm_place_reward.sparse_reward=${SPARSE_REWARD}"
fi


mkdir -p slurm_logs/${EXP_NAME}
export HABITAT_SIM_LOG=quiet
export WB_RUN_NAME=${EXP_NAME}

sbatch --gpus $((NODES*GPUS_PER_NODE)) --ntasks-per-node ${GPUS_PER_NODE} --nodes ${NODES} --error slurm_logs/${EXP_NAME}/err --output slurm_logs/${EXP_NAME}/out lang-rearrange-scripts/slurm_scripts/default_slurm.sh


# ENVS=1
# export EXP_NAME=${EXP_NAME}_debug 
# python -u -m habitat_baselines.run  \
#     --config-name ${EXP_CONFIG} habitat_baselines.evaluate=False habitat_baselines.tensorboard_dir="tb/${EXP_NAME}/" \
#     habitat_baselines.video_dir=video_dir/${EXP_NAME}/ habitat_baselines.eval_ckpt_path_dir="data/new_checkpoints/${EXP_NAME}/" \
#     habitat_baselines.checkpoint_folder="data/new_checkpoints/${EXP_NAME}/" habitat.gym.obs_keys=${OBS_KEYS} \
#     habitat_baselines.wb.group=${WB_GROUP} habitat_baselines.wb.run_name=${WB_RUN_NAME} \
#     habitat_baselines.num_environments=${ENVS} habitat.dataset.data_path=${DATA_PATH} \
#     ${MORE_OPTIONS} habitat_baselines.writer_type=wb habitat_baselines.wb.entity=language-rearrangement habitat_baselines.wb.project_name=main_2212 habitat_baselines.load_resume_state_config=False habitat_baselines.rl.ppo.num_mini_batch=1 #h
 