#!/bin/bash
#SBATCH --job-name=l_re
#SBATCH --cpus-per-task 16
#SBATCH --constraint="a40"
#SBATCH --signal=USR1@90
#SBATCH --requeue
#SBATCH --partition=short
#SBATCH -x conroy,cheetah
#SBATCH --account=cvmlp-lab
# #SBATCH --mem-per-cpu=500MB
# #SBATCH --mem=60GB
# #SBATCH --time=72:00:00


source ~/.bashrc
conda activate /srv/flash1/syenamandra3/conda_envs/ovmm_0523

export HABITAT_SIM_LOG=quiet

MAIN_ADDR=$(scontrol show hostnames "${SLURM_JOB_NODELIST}" | head -n 1)
echo $MAIN_ADDR
echo $EXP_NAME

set -x
srun python -u -m torch.distributed.run  -m habitat_baselines.run  \
    --config-name ${EXP_CONFIG} habitat_baselines.evaluate=False habitat_baselines.tensorboard_dir="tb/${EXP_NAME}/" \
    habitat_baselines.video_dir=video_dir/${EXP_NAME}/ habitat_baselines.eval_ckpt_path_dir="data/new_checkpoints/${EXP_NAME}/" \
    habitat_baselines.checkpoint_folder="data/new_checkpoints/${EXP_NAME}/" habitat.gym.obs_keys=${OBS_KEYS} \
    habitat_baselines.wb.group=${WB_GROUP} habitat_baselines.wb.run_name=${WB_RUN_NAME} \
    habitat_baselines.num_environments=${ENVS} habitat.dataset.data_path=${DATA_PATH} \
    habitat_baselines.wb.entity=yvsriram habitat_baselines.wb.project_name=e2e-ovmm ${MORE_OPTIONS} habitat_baselines.writer_type=wb
