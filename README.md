Object rearrangement scripts
==============================

## Download 
Clone this repository and place it inside your `habitat-lab/`. directory

## Commands
1. **Setup episodes**: Download the floorplanner episodes from [here](https://drive.google.com/drive/folders/1caFggwzhCKlYqVKCQ9vBPZuTGRptq0sm?usp=share_link).


2. **Generate text embeddings**: 

    ```
    python lang-rearrange-scripts/misc/get_llm_embeddings.py
    ```
    Alternatively, download `clip_embeddings.pickle` from [here](https://drive.google.com/file/d/1sSDSKZgYeIPPk8OM4oWhLtAf4Z-zjAVy/view?usp=share_link) and place it inside the `habitat-lab` directory.

        Note: Currently, the script doesn't generate embeddings for all objects. Please directly download.

3. **Download assets**
    Download the floorplanner test scene from [here](https://drive.google.com/drive/folders/1TrxG3Y1lS5Vys_KohultyI7brBkCR6fn?usp=share_link) and extract it inside `data`.
    Download GSO and ABO objects following these [instructions](https://drive.google.com/drive/folders/1Qs99bMMC7ZpZwksZYDC_IkNqK_IB6ONU?usp=sharing).

3. **Train category-conditioned pick policy**
    ```
    ./lang-rearrange-scripts/slurm_scripts/obj_rearrange/pick/cat_pick.sh
    ```


