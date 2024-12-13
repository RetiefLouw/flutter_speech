# Export self-supervised speech models (S3M) from Hugging Face to ONNX

## Install dependencies

	conda env create -f environment.yml
	conda activate s3m_onnx

## Export Hugging Face model

Hubert-Base

	python convert_onnx.py facebook/hubert-base-ls960


To get output of intermediate layer specify the number of hidden layers
as follows:

Hubert-Base 

	python convert_onnx.py facebook/hubert-base-ls960 --num_hidden_layers 9


Wav2Vec2-XLSR-53

	python convert_onnx.py facebook/wav2vec2-large-xlsr-53 --num_hidden_layers 12

TODO:
Add quantization



