## Install dependencies

	conda env create -f environment.yml


## Export Hugging Face Whisper model to ONNX

	python export_onnx.py \
	--model tiny \
	--hf_model openai/whisper-tiny \
	--out_dir whisper-tiny

Copy the exported files to the assets folder in the Flutter application, and update the `pubspec.yaml` file accordingly.

>[!NOTE]
>The script `export_onnx.py` is adapted from [this repository](https://github.com/k2-fsa/sherpa-onnx/tree/master/scripts/whisper), with added functionality for Hugging Face model conversion.
