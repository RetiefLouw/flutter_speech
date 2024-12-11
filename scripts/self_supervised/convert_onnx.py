

# from transformers import Wav2Vec2FeatureExtractor, Wav2Vec2Config, Wav2Vec2Model
from transformers import AutoFeatureExtractor, AutoConfig, AutoModel, AutoTokenizer
import argparse
from optimum.onnxruntime import ORTModelForCustomTasks
from pathlib import Path

def main(args):
    # model = "facebook/wav2vec2-large-xlsr-53"
    model_name = args.model_name_or_path
    
    out_dir = "hubert-base-ls960"
    out_dir = Path(model_name).stem
        
    config = AutoConfig.from_pretrained(model_name)
    
    if args.num_hidden_layers:
        config.num_hidden_layers = args.num_hidden_layers
        out_dir += f".layer_{args.num_hidden_layers}"
        
    hf_model = AutoModel.from_config(config)
    hf_out = f"{out_dir}/hf"
    hf_model.save_pretrained(hf_out)

    # tokenizer = AutoTokenizer.from_pretrained(model)
    # model = AutoModel.from_pretrained(model, config=config)
    # print(config)
    print(f"Loading: {hf_out}")
    # model = ORTModelForCustomTasks.from_pretrained(model_name, config=config, export=True)
    # print(model.model.encoder)
    model = ORTModelForCustomTasks.from_pretrained(hf_out, export=True)

    print(f"Writing: {out_dir}")
    model.save_pretrained(out_dir)


def check_argv():
    parser = argparse.ArgumentParser()
    parser.add_argument("model_name_or_path", type=str, help="")
    # parser.add_argument("--output_hidden_states", action="store_true", default=False)
    parser.add_argument("--num_hidden_layers", type=int, default=None)

    args = parser.parse_args()

    return args


if __name__ == "__main__":
    args = check_argv()
    main(args)
