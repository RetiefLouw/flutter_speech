# Voice activity detection

This application implements a real-time voice activity detection (VAD) system using the Silero ONNX model.

## Getting started

### Download Silero VAD model

1. Create directory:

	mkdir -p assets/models
	cd assets/models

2. Download model:

	wget https://github.com/snakers4/silero-vad/blob/master/src/silero_vad/data/silero_vad.onnx
	
3. Change `pubspec.yaml`

	flutter:
	  ...

	  assets:
	  - assets/models/silero_vad.onnx
