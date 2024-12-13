# Word Classification Application Using AWE with Mean Pooling of Self-Supervised Speech Features

This is an application showing how to use a self-supervised speech model (S3M) for feature extraction. The example use case here is for matching words to a reference set to predict a new word. A reference set of three words are given in assets/audio. The app expects a new recording from the user. The word will then be predicted as one of the examples from the reference set.

## Getting started

### Get S3M model

1. Create directory:

		mkdir -p assets/models

2. Export HF model [here](../../scripts/self_supervised) and copy model files to `assets/models`.

	For example, to use hubert-base

		python ../../scripts/whisper/export_onnx.py --model tiny --hf_model openai/whisper-tiny

	>[!NOTE]
	> See [this readme](../../scripts/self_supervised) for more options.

	Link model files to assets:

		ln -s $(pwd)/../../scripts/whisper/out/tiny-encoder.int8.onnx assets/models/
		ln -s $(pwd)/../../scripts/whisper/out/tiny-decoder.int8.onnx assets/models/
		ln -s $(pwd)/../../scripts/whisper/out/tiny-tokens.txt assets/models/


4. Change `pubspec.yaml`:
	
		flutter:
		  ...
		  assets:
		  ....
		    - assets/models/tiny-encoder.int8.onnx
		    - assets/models/tiny-decoder.int8.onnx
		    - assets/models/tiny-tokens.txt

### Audio

Three audio files from the babloon test set are included in the assets folder.

## Run application on android device

Open folder in vscode: `code .`

In the command palette enter `Flutter: Select device` and choose your android device.

From `main.dart` run the debug play button.

The following screen should load:

Insert image here

1. From the dropdown menu, select one of the example audio files.
2. Press the Play button to listen to the audio.
3. Click Transcribe Audio to transcribe it using the model. Note that this process might take some time.
