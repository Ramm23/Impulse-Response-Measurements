# Audio Playback #

The goal of this project is to standardize the playback, recording, and
"playrec" interfaces, independently of the backend used for playback, and is
meant to be used with the ASIO driver of the Fireface UCX under in the Hearing
Systems lab, DTU.

An abstract class `HeaAudio` defines the interface and subclasses are defined
for each backend. So far, the following backend have been implemented:

1. `HeaAudioPlayRec` based on [PlayRec](http://www.playrec.co.uk)
2. `HeaAudioPsych` based on [PsychToolbox](http://psychtoolbox.org)
3. `HeaAudioDSP` based on [DSPToolbox](http://se.mathworks.com/help/dsp/ref/dsp.audioplayer-class.html)

Although `audio-playback` is developed and tested to be used in the lab under
Windows 64-bit, it is also thought to be usable on a Linux or Mac machine
without having a Fireface nor an ASIO driver. This allows to do pilot testing
outside the lab.

## How do I get set up? ##

* Clone this repository to your computer:

	`git clone https://bitbucket.org/hea-dtu/audio-playback.git`

* Run `startupHeaAudio.m`, which is in the `audio-playback` folder just created.
* That's it! The various `HeaAudioXXX` classes should now be in your path.


## How do I use it? ##

_There is a demo folder and each function has a built-in help, 
but below are listed some very basic commands._

* Create an object: `player = HeaAudioDSP()` or with an other utility
* Play sound: `player.play(x)`
* Record sound: `y = player.rec(recNbSamples)`
* Play and record simultaneously: `y = player.playrec(x)`

## How do I adjust the properties to my own setup? ##

Creating an object, by typing for example `player = HeaAudioDSP()`, 
might crash on your computer, most likely beacuse the default settings 
are not adapted for your sound system, but for the one in the lab.

There are 3 different ways to adjust the properties:

1. Create a user parameter file by running `HeaAudio.createUserParameterFile`. 
2. Adjust the properties directly when creating the object. For example, to
   adjust the sampling frequency and the recording channels: `player =
   HeaAudioDSP('fs', 48000, 'channelsRec', [3 7])`
3. Adjust the properties after the object is created (if it did not crash when
  creating it!):
	1. `player = HeaAudioDSP;`
	2. `player.fs = 48000;`
	3. `player.channelsRec = [3 7];`

**Important:** These 3 methods are listed in their preferred order: setting
properties with method 2 overrides the properties set with method 1, and so on.
 

### Identifying the device name or ID ###

To know the device ID or device name for each utility, 
you can run the `listDevices` method of the player you're tring to use, e.g.: 

- `HeaAudioDSP.listDevices`
- `HeaAudioPsych.listDevices`
- `HeaAudioPlayRec.listDevices`


### Defining a `UserParameterFile` file ###

You can override default parameters by having a `userParametersHeaAudio.m` in
your path. The file is created in the current directory by calling
`HeaAudio.createUserParameterFile`. If you open it, you can uncomment and
adjust the properties to fit your system.

`audio-player` will use the values defined in that file, instead of the default
values, if it's found in Matlab's path.

## How do I add this repository to an other git repository? ##

* Go to your other git repository:
	
	`cd ..\myExperiment\`


* Add the audio-playback as a submodule:

	`git submodule add https://bitbucket.org/hea-dtu/audio-playback audio-playback`


* Commit the changes (there should be two new files: `.gitmodules` and the `audio-playback` repository, who will be seen as one file)

All the audio playback files should now be in your local repository. To later update this `audio-playback` submodule to the latest version, you will need to run:

```bash
cd audio-playback
git pull origin master
cd ..
git add audio-playback
git commit -m "Updated audio-playback to latest version" 
```

##  Requirements  ##

* For `HeaAudioPlayRec`: Windows 64 bit and an ASIO driver
* For `HeaAudioPsych`: PsychToolbox should be installed (Supports Windows, Mac
  and Linux)
* For `HeaAudioDSP`: Matlab 2013a or higher with the DSP System Toolbox. 
* The type of driver (ASIO, Windows Direct Sound, ALSA, ...) should be checked
  by going into Matlab Settings, and then in the DSP System Toolbox tab.

## Contribution guidelines ##

* Create an issue on [bitbucket](http://bitbucket.org/hea-dtu/audio-playback)
* Contact Alex (alech@elektro.dtu.dk) or Francois (fguerit@elektro.dtu.dk)