import clip
import pickle
import torch


objects = [
    "apple",
    "banana",
    "bleach_cleanser",
    "bowl",
    "cracker_box",
    "gelatin_box",
    "lemon",
    "master_chef_can",
    "mug",
    "orange",
    "peach",
    "pear",
    "plum",
    "potted_meat_can",
    "pudding_box",
    "sponge",
    "strawberry",
    "sugar_box",
    "tomato_soup_can",
    "tuna_fish_can",
]


def get_embedding(s):
    inputs = tokenizer(s, return_tensors="pt")
    outputs = model(**inputs)

    last_hidden_states = outputs.last_hidden_state
    return last_hidden_states[0, 0].detach().numpy()


device = "cuda" if torch.cuda.is_available() else "cpu"
model, preprocess = clip.load("ViT-B/32", device)

# Prepare the inputs
text_inputs = torch.cat(
    [clip.tokenize(f"a photo of a {c}") for c in objects]
).to(device)
save_path = "clip_embeddings.pickle"

# Get CLIP embeddings
with torch.no_grad():
    text_features = model.encode_text(text_inputs)
embeddings = {o: t for o, t in zip(objects, text_features.detach().cpu().numpy())}
pickle.dump(embeddings, open(save_path, "wb"))
