python -u -m habitat_baselines.run --config-name ovmm/rl_cont_skill.yaml habitat_baselines.evaluate=False habitat_baselines.tensorboard_dir=tb/place/input_goal_recep_depth_16x1x8_envs_new_train_no_augs_stability_0_drop_pen_once_True_sparse_true_max_surface_steps_20_constraint_base_manip_mode_false_vel_constraints_coll_pen_0.0_0.0_end_pen_max_-1_colls_again_robust_2m/ habitat_baselines.video_dir=video_dir/place/input_goal_recep_depth_16x1x8_envs_new_train_no_augs_stability_0_drop_pen_once_True_sparse_true_max_surface_steps_20_constraint_base_manip_mode_false_vel_constraints_coll_pen_0.0_0.0_end_pen_max_-1_colls_again_robust_2m/ habitat_baselines.eval_ckpt_path_dir=data/new_checkpoints/place/input_goal_recep_depth_16x1x8_envs_new_train_no_augs_stability_0_drop_pen_once_True_sparse_true_max_surface_steps_20_constraint_base_manip_mode_false_vel_constraints_coll_pen_0.0_0.0_end_pen_max_-1_colls_again_robust_2m/ habitat_baselines.checkpoint_folder=data/new_checkpoints/place/input_goal_recep_depth_16x1x8_envs_new_train_no_augs_stability_0_drop_pen_once_True_sparse_true_max_surface_steps_20_constraint_base_manip_mode_false_vel_constraints_coll_pen_0.0_0.0_end_pen_max_-1_colls_again_robust_2m/ habitat.gym.obs_keys=['head_depth','goal_receptacle','joint','is_holding','object_embedding','goal_recep_segmentation'] habitat_baselines.wb.group=cat_place habitat_baselines.wb.run_name=place/input_goal_recep_depth_16x1x8_envs_new_train_no_augs_stability_0_drop_pen_once_True_sparse_true_max_surface_steps_20_constraint_base_manip_mode_false_vel_constraints_coll_pen_0.0_0.0_end_pen_max_-1_colls_again_robust_2m habitat_baselines.num_environments=16 habitat.dataset.data_path=data/datasets/ovmm/train/episodes.json.gz habitat_baselines.wb.entity=language-rearrangement habitat_baselines.wb.project_name=e2e-ovmm-small-scale benchmark/ovmm=place habitat.dataset.split=train habitat.task.spawn_reference=target habitat.task.spawn_max_dist_to_obj=2.0 habitat_baselines.rl.ddppo.normalize_visual_inputs=False habitat_baselines.total_num_steps=1.0e9 habitat.task.measurements.ovmm_place_reward.stability_reward=0.0 habitat.task.measurements.ovmm_place_reward.navmesh_violate_pen=0.0 habitat.environment.max_episode_steps=350 habitat.task.measurements.ovmm_place_reward.robot_collisions_pen=0.0 habitat.task.measurements.ovmm_place_reward.robot_collisions_end_pen=0.0 habitat.task.measurements.robot_collisions_terminate.max_num_collisions=-1 habitat.task.measurements.force_terminate.max_accum_force=-1 habitat.task.measurements.force_terminate.max_instant_force=-1 habitat.task.measurements.ovmm_place_reward.max_steps_to_reach_surface=20 habitat_baselines.trainer_name=ddppo habitat.task.measurements.ovmm_place_reward.penalize_wrong_drop_once=True habitat.task.actions.base_velocity.constraint_base_in_manip_mode=False habitat.task.measurements.ovmm_place_reward.sparse_reward=true habitat_baselines.writer_type=wb
