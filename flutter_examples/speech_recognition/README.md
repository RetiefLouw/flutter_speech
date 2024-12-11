# Speech recognition

This is an application showing how to perform non-realtime speech recognition on-device using a Whisper model.


## Getting started

### Get Whisper model

1. Create directory:

		mkdir -p assets/models

2. Export HF Whisper model [here](../../scripts/whisper)

3. Change `pubspec.yaml`. For example:
	
		flutter:
		  ...
		  assets:
		  ....
		    - assets/models/tiny-encoder.int8.onnx
		    - assets/models/tiny-decoder.int8.onnx
		    - assets/models/tiny-tokens.txt
