import fileinput
import os
import argparse

def update_textures(file, value):
    for line in fileinput.input([file], inplace=1):
        if line.startswith("Kd"):
            print(f"Kd {value} {value} {value}")
        else:
            print(line, end="")

parser = argparse.ArgumentParser()
parser.add_argument("--Kd", type=str, default=0.3)
parser.add_argument(
    "--dataset_dir", type=str, default="data/objects/google_object_dataset/objects"
)
args = parser.parse_args()

for object_dir in os.listdir(args.dataset_dir):
    file = os.path.join(args.dataset_dir, object_dir, "meshes/model.mtl")
    print(file)
    if os.path.exists(file):
        update_textures(file, args.Kd)                                        
