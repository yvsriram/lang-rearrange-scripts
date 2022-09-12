Object rearrangement scripts
==============================

## Download 
Clone this repository and place it inside your `habitat-lab/`. directory

## Commands
1. **Setup episodes**: Copy the episodes and episode inits inside `lang-rearrange-scripts/datasets/data` to `data/datasets/replica_cad/rearrange/v1/train/`.

    Alternatively, generate episodes using:
    ```
    python lang-rearrange-scripts/datasets/add_cat_fields_to_episodes.py
    ```

2. **Train category-conditioned pick policy**
    ```
    ./lang-rearrange-scripts/slurm_scripts/obj_rearrange/pick/cat_pick.sh
    ```
