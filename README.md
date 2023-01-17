Object rearrangement scripts
==============================

## Download 
Clone this repository and place it inside your `habitat-lab/`. directory (please use code from [here](https://github.com/facebookresearch/habitat-lab/pull/1050)).

## Commands
1. **Setup episodes**: Download the floorplanner episodes from [here](https://drive.google.com/drive/folders/1caFggwzhCKlYqVKCQ9vBPZuTGRptq0sm?usp=share_link).

When training skills, add  `habitat.dataset.data_path=path/to/episodes.json.gz` to point to the location of downloaded episodes.

There are three versions of the episodes:

| Name | Number of episodes | Scenes | Split | Object sources | Number of categories | Categories balanced? 
|------|--------------------|---|---|---|---|---|
| [cat_split_1_test_scene_40k_old.json.gz](https://drive.google.com/file/d/1CsYImrBE5QdxM_qLbnzEx0j0NliUPVtT/view?usp=sharing)      | 40k       |  1 test scene | [split_1](https://github.com/facebookresearch/habitat-lab/blob/59d3e735bfaac954bf89353ebd3c86d1feb9d871/habitat-lab/habitat/datasets/rearrange/configs/rearrange_floorplanner.yaml) | GSO  | 16 | No |
| [cat_split_1_test_scene_10k.json.gz](https://drive.google.com/file/d/12CcEEzaqpIuyh1Vr9uhEAWAEkvktT1qK/view?usp=share_link)   | 10k        |  1 test scene |[split_1](https://github.com/facebookresearch/habitat-lab/blob/59d3e735bfaac954bf89353ebd3c86d1feb9d871/habitat-lab/habitat/datasets/rearrange/configs/rearrange_floorplanner.yaml)|GSO and ABO | 19 | Yes |
|[cat_split_1_3_scenes_7k.json.gz](https://drive.google.com/file/d/1zyPBdkGYfouShztKxnJtXYIPFaWdvyoN/view?usp=share_link) | 7k | 3 train scenes|[split_1](https://github.com/facebookresearch/habitat-lab/blob/59d3e735bfaac954bf89353ebd3c86d1feb9d871/habitat-lab/habitat/datasets/rearrange/configs/rearrange_floorplanner.yaml) |  GSO and  ABO | 19 | Yes    |

2. **Generate text embeddings**: 

Download `clip_embeddings.pickle` from [here](https://drive.google.com/file/d/1sSDSKZgYeIPPk8OM4oWhLtAf4Z-zjAVy/view?usp=share_link) and place it inside the `habitat-lab` directory.

        
3. **Download assets**
    Download the floorplanner test scene from [here](https://drive.google.com/drive/folders/1TrxG3Y1lS5Vys_KohultyI7brBkCR6fn?usp=share_link) and extract it inside `data`.

    Download the "mini" floorplanner dataset with 3 training and 1 val scene from [here](https://drive.google.com/drive/folders/13tA7mU2fW3Z-PPliSeMCFxV8hwmmE36c).
    Download GSO and ABO objects following these [instructions](https://drive.google.com/drive/folders/1Qs99bMMC7ZpZwksZYDC_IkNqK_IB6ONU?usp=sharing).

3. **Train category-conditioned pick policy**
    ```
    ./lang-rearrange-scripts/slurm_scripts/obj_rearrange/pick/cat_pick.sh
    ```


