# Word Classification Application Using AWE with Mean Pooling of Self-Supervised Speech Features

This application demonstrates how to use a self-supervised speech model (S3M) for feature extraction. This example involves matching a spoken word to a reference set in order to predict the word. A reference set of three words is provided in the `assets/audio` folder. The app prompts the user to record a new word, which will then be predicted as one of the words from the reference set.

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
		    - assets/models/model.onnx

### Audio

Three reference audio files are included in `assets/audio/references` folder containing the words: 'mouse', 'cat', and 'dog'.

## Run application on android device

Open folder in vscode: `code .`

In the command palette enter `Flutter: Select device` and choose your android device.

From `main.dart` run the debug play button.

The following screen should load:

Insert image here

1. Hold down the recording button until it turns red, then say a word.
2. Press the Play button to listen to the audio.
3. Click Predict to classify word.
