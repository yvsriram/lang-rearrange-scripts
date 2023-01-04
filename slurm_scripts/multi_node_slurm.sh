#!/bin/bash
#SBATCH --job-name=l_re
#SBATCH --nodes 1
#SBATCH --cpus-per-task 10
#SBATCH --signal=USR1@90
#SBATCH --requeue
#SBATCH --mem=60GB
#SBATCH --time=72:00:00
#SBATCH --partition=dev

export HABITAT_SIM_LOG=quiet

MAIN_ADDR=$(scontrol show hostnames "${SLURM_JOB_NODELIST}" | head -n 1)
echo $MAIN_ADDR
echo $EXP_NAME

set -x
srun python -u -m habitat_baselines.run  \
    --exp-config ${EXP_CONFIG} --run-type train habitat_baselines.tensorboard_dir="tb/${EXP_NAME}/" \
    habitat_baselines.video_dir=video_dir/${EXP_NAME}/ habitat_baselines.eval_ckpt_path_dir="data/new_checkpoints/${EXP_NAME}/" \
    habitat_baselines.checkpoint_folder="data/new_checkpoints/${EXP_NAME}/" habitat.gym.obs_keys=${OBS_KEYS} \
    habitat_baselines.wb.group=${WB_GROUP} habitat_baselines.wb.run_name=${WB_RUN_NAME} \
    habitat_baselines.num_environments=${ENVS} habitat.dataset.data_path=${DATA_PATH} \
    ${MORE_OPTIONS} habitat_baselines.writer_type=wb
