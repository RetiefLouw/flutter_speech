# Setup Android development environment on Linux

Here is the [link](https://docs.flutter.dev/get-started/install/linux/android) to the official installation instructions. Below are the steps to set up the development environment used for the applications in `flutter_examples`.


The following versions were used to build the projects:

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


	Downgrade to version 3.24.3 using with `commit-hash = 2663184` (see [archive](https://docs.flutter.dev/release/archive)):
		
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

## Prototpyes
Main assessment:
- VAD (silero)
- Whisper on-device
- recording

Template matching
- VAD
- recording
- feature extractor
