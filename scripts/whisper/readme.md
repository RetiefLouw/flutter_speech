## Install dependencies

	conda env create -f environment.yml


## Export Whisper HF model to ONNX

	./whisper_onnx/export-onnx.py \
	--model tiny \
	--hf_model openai/whisper-tiny \
	--out_dir whisper-tiny

Copy the exported files to the assets folder in the Flutter application, and update the `pubspec.yaml` file accordingly.

Note: The script `export-onnx.py` is modified from [this repository](https://github.com/k2-fsa/sherpa-onnx/tree/master/scripts/whisper). Hugging Face conversion has been added.
