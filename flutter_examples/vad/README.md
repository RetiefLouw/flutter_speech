# Voice activity detection

This application implements a real-time voice activity detection (VAD) system using the Silero ONNX model.

## Getting started

### Download Silero VAD model

1. Download model and move to assets:

		mkdir -p assets/models
		wget https://github.com/snakers4/silero-vad/raw/master/src/silero_vad/data/silero_vad.onnx
		mv silero_vad.onnx assets/models/
		
3. Change `pubspec.yaml`:

		flutter:
		  ...
	
		  assets:
		  - assets/models/silero_vad.onnx

### Run application on android device

Open folder in vscode: `code .`

In the command palette enter `Flutter: Select device` and choose your android device.

From `main.dart` run the debug play button.
   
   	
