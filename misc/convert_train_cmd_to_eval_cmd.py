import argparse
import re
import os

def main():
    # Parse arguments to read the file containing command
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--command-path", type=str, default="commands/find_rec_16x4.sh"
    )
    parser.add_argument(
        "--eval_key", type=str, default="eval_40M"
    )
    parser.add_argument("--evaluate-all", action='store_true')
    parser.set_defaults(evaluate_all=False)
    args = parser.parse_args()

    f = open(args.command_path, 'r')
    cmd = f.read().strip().lstrip()
    print(args.command_path)
    pattern=r"[a-zA-Z0-9_/.-]*"
    cmd = re.sub(f"evaluate={pattern}", "evaluate=True", cmd)
    cmd = re.sub(f"--run-type {pattern}", "--run-type eval", cmd)
    cmd = re.sub(f"wb.entity={pattern}", 'wb.entity=language-rearrangement', cmd)
    cmd = re.sub(f'wb.project_name={pattern}', 'wb.project_name=e2e-ovmm-eval', cmd)
    cmd = re.sub(f'data_path=data/datasets/ovmm/{pattern}/episodes.json.gz', 'data_path=data/datasets/ovmm/val/episodes.json.gz', cmd)
    cmd = re.sub(f'viewpoints_matrix_path=data/datasets/ovmm/{pattern}/viewpoints.npy', 'viewpoints_matrix_path=data/datasets/ovmm/val/viewpoints.npy', cmd)
    cmd = re.sub(f'transformations_matrix_path=data/datasets/ovmm/{pattern}/transformations.npy', 'transformations_matrix_path=data/datasets/ovmm/val/transformations.npy', cmd)
    cmd = re.sub(f'split={pattern}', 'split=val', cmd)
    if 'habitat.dataset.split' not in cmd:
        cmd += ' habitat.dataset.split=val'
    cmd = re.sub(f'num_environments=16', 'num_environments=12', cmd)
    cmd += ' habitat.simulator.requires_textures=False'
    cmd += ' habitat_baselines.load_resume_state_config=False'
    if not args.evaluate_all:
        cmd = re.sub(f'habitat_baselines.eval_ckpt_path_dir=({pattern})', r'habitat_pobaselines.eval_ckpt_path_dir=\1/latest.pth', cmd)
    cmd = re.sub(f'habitat_baselines.checkpoint_folder=({pattern})', rf'habitat_baselines.checkpoint_folder=\1/{args.eval_key}', cmd)
    cmd = re.sub(f'habitat_baselines.video_dir=({pattern})', rf'habitat_baselines.video_dir=\1/{args.eval_key}', cmd)
    os.system(f"exec {cmd}")

if __name__ == "__main__":
    main()

