# Speech recognition

This is an application showing how to perform non-realtime speech recognition on-device using a Whisper model.


## Getting started

### Get Whisper model

1. Create directory:

		mkdir -p assets/models

2. Export HF Whisper model [here](../../scripts/whisper) and copy model files to `assets/models`.

3. Change `pubspec.yaml`. For example:
	
		flutter:
		  ...
		  assets:
		  ....
		    - assets/models/tiny-encoder.int8.onnx
		    - assets/models/tiny-decoder.int8.onnx
		    - assets/models/tiny-tokens.txt

### Run application on android device

Open folder in vscode: `code .`

In the command palette enter `Flutter: Select device` and choose your android device.

From `main.dart` run the debug play button.
   
