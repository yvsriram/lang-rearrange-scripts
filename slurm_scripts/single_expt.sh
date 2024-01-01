#!/bin/zsh
#SBATCH -J test
#SBATCH -G a40:1
#SBATCH -c 10
#SBATCH -p overcap
# #SBATCH -x conroy,major,xaea-12,consu,hk47,spot,crushinator,kitt,uniblab,heistotron,voltron
#SBATCH --ntasks-per-node 1
#SBATCH --qos short
# #SBATCH --account overcap
# #SBATCH --constraint "a40|rtx_6000"


source ~/.bashrc
conda activate /srv/flash1/syenamandra3/conda_envs/ovmm_main_merge
export HABITAT_SIM_LOG=quiet
echo $episodes
python projects/habitat_ovmm/eval_baselines_agent.py --baseline_config_path $config --env_config_path $env_config habitat.dataset.episode_indices_range="[$episode_start,$episode_end]" habitat_baselines.eval_ckpt_path_dir=$exp_name habitat.dataset.split='val' habitat.dataset.transformations_matrix_path=data/datasets/ovmm/val/transformations.npy # habitat.dataset.exclude_episodes_file=datadump/results/${exp_name}/completed_episodes.txt


# python projects/habitat_ovmm/eval_baselines_agent.py habitat.task.pick_init=True habitat.task.episode_init=False habitat.task.base_angle_noise=0 habitat.environment.max_episode_steps=1 habitat.dataset.split=train habitat.task.camera_tilt=-0.7835 habitat.dataset.episode_indices_range="[$episode_start,$episode_end]"
# python projects/habitat_ovmm/eval_dataset.py --baseline_config_path $config habitat.dataset.scene_indices_range="[$episode_start,$episode_end]"   \
	# habitat.task.video_save_folder=datadumps/videos_from_task/${exp_name}_0621_diverse_scenes_level_head_0.3/${episode_start}_${episode_end}  \
	# habitat.dataset.split=train habitat.dataset.data_path=data/episodes/rearrange/v4/train/cat_npz-exp.json.gz habitat.task.episode_init=False # habitat.dataset.episode_indices_range="[$episode_start,$episode_end]" 
	# habitat.dataset.episode_ids="[651,661,113,118,131,119,560,564,572,911,910,1141,1001,1041,131,371,191,622,629,648]" #habitat.environment.max_episode_steps=10
	# habitat.dataset.episode_ids="[0,100,200,300,400,500,1000,2000,5000,10000,15000,20000,25000,30000,35000]" habitat.dataset.split=train habitat.dataset.data_path=data/episodes/rearrange/v4/train/cat_npz-exp.json.gz habitat.task.episode_init=False
	# habitat.dataset.episode_ids="[12,22,114,119,132,120,561,566,570,918,913,1148,1005,1042,136,379,199,611,619,628]" #habitat.environment.max_episode_steps=10
	# habitat.dataset.episode_ids="[619,19,628,97,639,8]"
	# [71,90,97,611,628,646,136,379,131,651,199,239,661,619,19,46]

# other succeed
# [619,19,628,97,639,8]

# ours best clearly succeeds
# habitat.dataset.episode_ids="[136,379,131,651,199,239,661]"



# habitat.dataset.episode_ids="[397,280,651,317]"

# in general for other failures: 397,280,651,317]"


# full heuristic passes
# [89,612,639,408,8,]

# detic passes
# 135,136,769,29,573,

# [71,97,90,611,628,646,619,46,19]


# successes of gt nav, others fail
# "[397,280,651,317,322,465,267]"
# ,]"
# 1061,239,493,31,199
# [538,314,136,379,661,131,335]

# habitat.dataset.episode_ids="[760,740,771,405,34,338,661,722,83,427,819,474,30,376,97,469,683,326,128,175,425,480,516,551,100,168,619,796,457,525]"

#  habitat.dataset.data_path=data/episodes/rearrange/v4/val/cat_npz-exp-filtered-with-init-poses-2.json.gz
