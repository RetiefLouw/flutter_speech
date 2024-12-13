#!/bin/bash

# Default value for mHubert, can be overridden by user
model_dir=${1:-"mHuBERT-147-layer7-mvn"}  # Default to 'mHuBERT-147-layer7-mvn' if no argument is provided

# Default path for samediff.py, can be overridden by user
samediff_path=${2:-"./samediff.py"}  # Default to './samediff.py' if no path is provided

# Check if samediff.py exists at the specified location
if [[ ! -f "$samediff_path" ]]; then
  echo "Error: samediff.py not found at $samediff_path"
  exit 1
fi

# Set paths dynamically based on mHubert_dir
labels_path="${model_dir}/labels.txt"
dist_path="${model_dir}/dist.txt"
speakers_path="${model_dir}/speakers.txt"

# Execute the samediff.py script with the dynamically generated paths
"$samediff_path" "$labels_path" "$dist_path" --speakers_fn "$speakers_path"

