# Setup Android development environment on Linux

Here is the [link](https://docs.flutter.dev/get-started/install/linux/android) to the official installation instructions. Below are the steps to replicate the development environment used for building the Flutter demo applications in this repository.


Software versions used:

- JDK 17
- Android Studio 2024.2.1 (Ladybug)
- Flutter 3.24.3
- Dart 3.5.3
- DevTools 2.37.3
- Gradle 8.9


## Install Java Development Kit

Install JDK 17:

	sudo apt install openjdk-17-jdk-headless

Add to PATH:

	echo '# JDK' >> ~/.bashrc
	echo 'export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"' >> ~/.bashrc
	echo 'export PATH="$JAVA_HOME/bin:$PATH"' >> ~/.bashrc

Running `java --version` in the terminal should display the following:

	openjdk 17.0.13 2024-10-15
	OpenJDK Runtime Environment (build 17.0.13+11-Ubuntu-2ubuntu122.04)
	OpenJDK 64-Bit Server VM (build 17.0.13+11-Ubuntu-2ubuntu122.04, mixed mode, sharing)


## Flutter Setup


<!-- #### Development Tools -->
	
1. Install the **development tools** by executing the [terminal commands](https://docs.flutter.dev/get-started/install/linux/android#development-tools) provided in the documentation.


2. Install **Android Studio** using the following steps ([link](https://developer.android.com/studio/install#linux) to documentation):

	Download version 2024.2.1.12:

		wget https://dl.google.com/dl/android/studio/ide-zips/2024.2.1.12/android-studio-2024.2.1.12-linux.tar.gz

	Unpack and move:
	
		tar -zxvf android-studio-2022.1.1.21-linux.tar.gz
		sudo mv android-studio /usr/local/

	Install the required libraries using the [terminal commands](https://developer.android.com/studio/install#64bit-libs). **Note**: You can ignore the libncurses error. Just ensure that `libncurses-dev` is installed by running: `sudo apt install libncurses-dev`.

	[Configure](https://docs.flutter.dev/get-started/install/linux/android#configure-android-development) the Android toolchain in Android Studio.


4. Install **Flutter** 

	To use specific Flutter version:

		mkdir ../src && cd "$_"
		git clone -b main https://github.com/flutter/flutter.git

	Add to PATH:

		echo '# Flutter SDK' >> ~/.bashrc
		echo "export PATH=\"$(pwd)/flutter/bin:\$PATH\"" >> ~/.bashrc


	Downgrade to version `3.24.3` (commit-hash: 2663184, see [archive](https://docs.flutter.dev/release/archive)):
		
		cd flutter
		git checkout 2663184
		cd bin
		./flutter --version

	Running `./flutter --version` in the terminal should display the following:

		Flutter 3.24.3 • channel stable • https://github.com/flutter/flutter.git
		Framework • revision dec2ee5c1f (4 weeks ago) • 2024-11-13 11:13:06 -0800
		Engine • revision a18df97ca5
		Tools • Dart 3.5.3 • DevTools 2.37.3


	Agree to Android licenses:

		flutter doctor --android-licenses


## Creating new Flutter Project:

Run:

	flutter doctor




Setup Android stuff:

	cd android	

Check Gradle version:

	./android/gradlew wrapper --version

Update gradle to 8.9:
	
	./android/gradlew wrapper --gradle-version=8.9

In `android/settings.gradle`, replace:
    
    id "com.android.application" version "8.1.0" apply false

with
	
	id "com.android.application" version "8.7.1" apply false

In android/app/build.gradle, add:

	defaultConfig {
		...
		minSdkVersion 24
	}

In android/app/build.gradle, change:


	android{
		...
	    	ndkVersion = flutter.ndkVersion
	    	...
	}

to 
	
	android{
		...
 		ndkVersion = "27.0.12077973"
		...
  	}



Ignore warning messages for now...


# Building blocks
- [Voice activity detection](flutter_examples/vad/)
- [Speech recognition](flutter_examples/speech_recognition/)
- [Speech feature extraction using self-supervised speech models](flutter_examples/template_matching/)

# Prototpyes
- [MAIN assessment on-device](prototypes/main_assessment_od)

## Setting Up the Development Environment

To set up the development environment, follow these steps:

1. **Install Conda**: If you haven't already installed Conda, you can download and install it from the [Anaconda](https://www.anaconda.com/products/distribution) or [Miniconda](https://docs.conda.io/en/latest/miniconda.html) website.

2. **Create a New Conda Environment**: Open a terminal and run the following command to create a new Conda virtual environment named `flutter_speech_env` with Python 3.8:

    ```bash
    conda create --name flutter_speech_env python=3.8 -y
    ```

3. **Activate the Virtual Environment**: Activate the virtual environment by running the following command:

    ```bash
    conda activate flutter_speech_env
    ```

4. **Install Required Packages**: While the virtual environment is activated, install the required packages from the `requirements.txt` file:

    ```bash
    pip install -r requirements.txt
    ```

5. **Run the Script**: After installing the packages, run the following command to execute the script:

    ```bash
    python ../../scripts/whisper/export_onnx.py --model tiny --hf_model openai/whisper-tiny
    ```

6. **Deactivate the Virtual Environment**: When you are done working in the virtual environment, you can deactivate it by running:

    ```bash
    conda deactivate
    ```

By following these steps, you will set up a Conda virtual environment with all the necessary dependencies for the project and be able to run the script successfully.