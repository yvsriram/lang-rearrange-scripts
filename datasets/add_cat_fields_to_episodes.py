from habitat.core.utils import DatasetFloatJSONEncoder
from tqdm import tqdm
import gzip
import json
import re
import numpy as np
import os.path as osp
import argparse


def fix_rec_name(rec_id):
    """
    Retrieves the receptacle category from id for YCB objects
    """
    rec_id = rec_id.replace("frl_apartment_", "")
    return re.sub(r"_[0-9]+", "", rec_id)


def get_obj_rec_cat_in_eps(episode):
    """
    Returns the category names for the object to be picked up, start and goal receptacles
    """
    obj_cat = list(episode["info"]["object_labels"].keys())[0].split(":")[0][
        4:-1
    ]
    start_rec_cat = fix_rec_name(
        episode["target_receptacles"][0][0].split(":")[0][:-1]
    )
    goal_rec_cat = fix_rec_name(
        episode["goal_receptacles"][0][0].split(":")[0][:-1]
    )
    return obj_cat, start_rec_cat, goal_rec_cat


def get_cats_list(train_episodes_file):
    """
    Extracts the lists of object and receptacle categories from episodes and returns name to id mappings
    """
    episodes = json.load(gzip.open(train_episodes_file))
    obj_cats, rec_cats = set(), set()

    for episode in episodes["episodes"]:
        obj_cat, start_rec_cat, goal_rec_cat = get_obj_rec_cat_in_eps(episode)
        obj_cats.add(obj_cat)
        rec_cats.add(start_rec_cat)
        rec_cats.add(goal_rec_cat)

    obj_cats = sorted(list(obj_cats))
    rec_cats = sorted(list(rec_cats))
    obj_to_id_mapping = {cat: i for i, cat in enumerate(obj_cats)}
    rec_to_id_mapping = {cat: i for i, cat in enumerate(rec_cats)}
    return obj_to_id_mapping, rec_to_id_mapping


def add_cat_fields_to_episodes(episodes_file, obj_to_id, rec_to_id):
    """
    Adds category fields to episodes
    """
    episodes = json.load(gzip.open(episodes_file))
    episodes["obj_category_to_obj_category_id"] = obj_to_id
    episodes["recep_category_to_recep_category_id"] = rec_to_id
    for episode in episodes["episodes"]:
        object_id, start_rec_id, goal_rec_id = get_obj_rec_cat_in_eps(episode)
        episode["object_category"] = object_id
        episode["start_recep_category"] = start_rec_id
        episode["goal_recep_category"] = goal_rec_id
    return episodes


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--data_dir",
        type=str,
        default="data/datasets/replica_cad/rearrange/v1/",
    )
    parser.add_argument(
        "--source_episodes_tag", type=str, default="rearrange_easy"
    )
    parser.add_argument(
        "--target_episodes_tag", type=str, default="categorical_rearrange_easy"
    )

    args = parser.parse_args()

    data_dir = args.data_dir
    source_episodes_tag = args.source_episodes_tag
    target_episodes_tag = args.target_episodes_tag

    # Retrieve object and receptacle categories in train episodes
    train_episode_file = osp.join(
        data_dir, "train", f"{source_episodes_tag}.json.gz"
    )
    obj_to_id, rec_to_id = get_cats_list(train_episode_file)
    print(f"Number of object categories: {len(obj_to_id)}")
    print(f"Number of receptacle categories: {len(rec_to_id)}")

    # Add category fields and save episodes
    for split in ["train", "minival", "val"]:
        episodes_file = osp.join(
            data_dir, split, f"{source_episodes_tag}.json.gz"
        )
        episodes = add_cat_fields_to_episodes(
            episodes_file, obj_to_id, rec_to_id
        )
        episodes_json = DatasetFloatJSONEncoder().encode(episodes)
        target_episodes_file = osp.join(
            data_dir, split, f"{target_episodes_tag}.json.gz"
        )
        with gzip.open(target_episodes_file, "wt") as f:
            f.write(episodes_json)
    print("All episodes written")
