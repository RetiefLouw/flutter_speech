# Speech recognition

This is an application showing how to perform non-realtime speech recognition on-device using a Whisper model.


## Getting started

### Get Whisper model

1. Create directory:

		mkdir -p assets/models

2. Export HF Whisper model [here](../../scripts/whisper) by reading the instructions and copy model files to `assets/models`.

	Link model files to assets:

		# Create symbolic links for the model files
		ln -s $(pwd)/scripts/whisper/out/tiny-encoder.int8.onnx flutter_examples/speech_recognition/assets/models/tiny-encoder.int8.onnx
		ln -s $(pwd)/scripts/whisper/out/tiny-decoder.int8.onnx flutter_examples/speech_recognition/assets/models/tiny-decoder.int8.onnx
		ln -s $(pwd)/scripts/whisper/out/tiny-tokens.txt flutter_examples/speech_recognition/assets/models/tiny-tokens.txt


4. Check links in `pubspec.yaml`:
	
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
