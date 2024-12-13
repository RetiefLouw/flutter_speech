# Word Classification Application Using AWE with Mean Pooling of Self-Supervised Speech Features

This is an application showing how to use a self-supervised speech model (S3M) for feature extraction. The example use case here is for matching words to a reference set to predict a new word. A reference set of three words are given in assets/audio. The app expects a new recording from the user. The word will then be predicted as one of the examples from the reference set.

## Getting started

### Export Hugging Face S3M model to ONNX

1. Create directory:

		mkdir -p assets/models

2. See [this readme](../../scripts/self_supervised) to export a Hugging Face S3M model.

	For example, to export Hubert-Base to ONNX:

   		# Install dependencies
		conda env create -f environment.yml
		conda activate s3m_onnx

   		# Export model
		python convert_onnx.py facebook/hubert-base-ls960
   
	Link ONNX model to application assets:

		ln -s $(pwd)/../../scripts/s3m/hubert-base-ls960/model.onnx assets/models/


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
