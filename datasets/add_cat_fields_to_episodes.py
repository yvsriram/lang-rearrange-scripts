from habitat.core.utils import DatasetFloatJSONEncoder
from tqdm import tqdm
import gzip
import json
import re
import numpy as np
import os.path as osp
import argparse
import os


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
    count = 0
    those_episodes = []
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


def collect_receptacle_positions(episode):
    scene_data = json.load(open(episode["scene_id"]))
    recep_positions = {}
    for recep_type in ["object_instances", "articulated_object_instances"]:
        for recep_data in scene_data[recep_type]:
            recep_positions[recep_data["template_name"]] = recep_data[
                "translation"
            ]
    return recep_positions


def get_matching_recep_handle(receptacle_name, handles):
    return [handle for handle in handles if handle in receptacle_name][0]


def get_candidate_starts(
    objects, category, name_to_receptacle, start_receptacle
):
    obj_goals = []
    for i, (obj, pos) in enumerate(objects):
        import pdb

        pdb.set_trace()

        if obj.split(".")[0][4:] == category:
            obj_goal = {
                "position": np.array(pos)[:3, 3].tolist(),
                "object_name": obj,
                "object_id": i,
                "object_category": category,
                "view_points": [],
            }
            obj_goals.append(obj_goal)

    return obj_goals


def get_candidate_receptacles(rec_positions, goal_recep_category):
    goals = []
    for recep, position in rec_positions.items():
        recep_category = fix_rec_name(recep)
        if recep_category == goal_recep_category:
            goal = {
                "position": position,
                "object_name": recep,
                "object_id": -1,
                "object_category": recep_category,
                "view_points": [],
            }
            goals.append(goal)
    return goals


def add_cat_fields_to_episodes(episodes_file, obj_to_id, rec_to_id):
    """
    Adds category fields to episodes
    """
    episodes = json.load(gzip.open(episodes_file))
    count = 0
    episodes["obj_category_to_obj_category_id"] = obj_to_id
    episodes["recep_category_to_recep_category_id"] = rec_to_id
    for episode in episodes["episodes"]:
        rec_positions = collect_receptacle_positions(episode)
        obj_cat, start_rec_cat, goal_rec_cat = get_obj_rec_cat_in_eps(episode)
        episode["object_category"] = obj_cat
        episode["start_recep_category"] = start_rec_cat
        episode["goal_recep_category"] = goal_rec_cat
        episode["candidate_objects"] = get_candidate_starts(
            episode["rigid_objs"],
            obj_cat,
            episode["name_to_receptacle"],
            start_rec_cat,
        )
        episode["candidate_start_receps"] = get_candidate_receptacles(
            rec_positions, start_rec_cat
        )
        episode["candidate_goal_receps"] = get_candidate_receptacles(
            rec_positions, goal_rec_cat
        )

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
    for split in os.listdir(data_dir):
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
