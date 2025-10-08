% This the demo file for playing sound with the audio-playback framework
%
% If you think something is unclear, please report it as an issue on
% bitbucket: https://bitbucket.org/hea-dtu/audio-playback/issues?status=new&status=open
%
% Be careful with the demo! Always keep headphones far from your ears the first
% time you try it!
%
% This demos assumes that you ran startupHeaAudio.m before getting started
%
% This also assumes that you read the README.md file beforehand.


%% Parameters of the demo

audioUtility = @HeaAudioPsych; % Which audio utility you want to use (can be
% either @HeaAudioPsych, @HeaAudioPlayRec or @HeaAudioDSP. Read more about
% it in the README.md and in their respective help files ('help HeaAudioPsych')
fs = 48000; % Sampling frequency (Hz)
duration = 2; % Duration of the demo signal (s)
f = 1000; % Frequeny of the dmeo signal (Hz)
amp = 0.01; % Amplitude of the demo signal
channels = 1:8; % Channels you wanna play signal to

%% Create the test signal (a simple sinusoid)
t = 0:1/fs:duration-1/fs;
signal = amp*sin(2*pi*f*t)';

%% Create the player
player = audioUtility('channelsPlay',channels,'fs',fs); % This is the equivalent
% of typing 'player = HeaAudioPsych('channelsPlay',channels,'fs',fs)'

%% Did it work?
% If not, it might be because you need to adjust the settings to your
% hardware. No worries, you only need to do that once!
% 
% Check the "How do I adjust the properties to my own setup?" in the
% README.md

%% Play signal (it is duplicated on the 8 channels, since the signal is mono)
player.play(signal)

%% Same but by playing the signal only on channel 4
player.channelsPlay = [4];
player.play(signal)

%% Change the sampling frequency (the pitch should change)
player.fs = 44100;
player.play(signal)

%eof