#!/bin/sh
# Script to run jobs


# iterate over number of episodes, run each job on x* 100 to (x + 1) * 100 episodes, export the tuple (x* 100, (x+1)*100)
# save timestamp as exp_name in YYYYMMDD:HHMMSS format
timestamp=$(date +%Y%m%d:%H%M%S)
# exp_name=r_m_r_n_gt_viz
# exp_name=collection1
#exp_name=ovmm_0931/rl_agent_grounded_sam_again
# exp_name=ovmm_1204/e2e_agent_detic_dropout_0.5
exp_name=ovmm_1220/eval_heuristic_agent
# exp_name=ovmm_1103/rl_agent_ground_truth  
# config=projects/habitat_ovmm/configs/agent/generated/0622-103011/${exp_name}.yaml
# config=projects/habitat_ovmm/configs/agent/rl_nav_heuristic_manip.yaml
# env_config=projects/habitat_ovmm/configs/env/hssd_eval_heuristic_gt.yaml
config=projects/habitat_ovmm/configs/agent/heuristic_agent.yaml
env_config=projects/habitat_ovmm/configs/env/hssd_eval_gt.yaml
# env_config=projects/habitat_ovmm/configs/env/hssd_eval_gt.yaml
#config=projects/habitat_ovmm/configs/agent/rl_agent_with_ckpts_grounded_sam.yaml
#env_config=projects/habitat_ovmm/configs/env/hssd_eval.yaml
# step=3
step=100
# step=50
# step=0
# 
for i in {0..11}; do
# for i in {0..23}; do
	mkdir -p slurm_logs/${exp_name}/
	sbatch --export=episode_start=$((i*step)),episode_end=$((i*step+step)),config=$config,exp_name=$exp_name,env_config=$env_config --output="slurm_logs/${exp_name}/_${i}_${step}_${timestamp}.out" --job-name=${exp_name}_${i}  --error="slurm_logs/${exp_name}/_${i}_${step}_${timestamp}.err" scripts/single_expt.sh
	# episode_start=$((i*step))
	# episode_end=$((i*step+step))
	# python projects/habitat_ovmm/eval_dataset.py --baseline_config_path $config habitat.dataset.episode_indices_range="[$episode_start,$episode_end]" \
	# habitat.task.video_save_folder=datadumps/videos_from_task/${exp_name}_0621_train_right_kinematic_mode_distance_0.7/  \
	# habitat.dataset.episode_ids="[30175,9824,6279,18733,32056,13919,0,24452,29245,10724,7204,19725,33056,13012,4545,26357,22493,1754,15864,27290,23452,2604,16733,28290,21605,5373,9009,31175,17733,8204,11108,34007,20692,3550,12012,14919,929,25357]" habitat.dataset.split=train habitat.dataset.data_path=data/episodes/rearrange/v4/train/cat_npz-exp.json.gz habitat.task.episode_init=False
done
