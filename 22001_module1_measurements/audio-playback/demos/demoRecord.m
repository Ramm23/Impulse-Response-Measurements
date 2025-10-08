% This the demo file for recording sound with the audio-playback framework
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
duration = 2; % Duration of the recordded signal (s)
channels = 3; % Channels you wanna record signal from

%% Define how many samples you will record

recNbSamples = duration*fs;

%% Create the player object
player = audioUtility('channelsPlay',[],'channelsRec',channels,'fs',fs);
% This is the equivalent of typing 'player = HeaAudioPsych('channelsPlay',[],...
%   'channelsRec',channels,'fs',fs)'

%% Did it work?
% If not, it might be because you need to adjust the settings to your
% hardware. No worries, you only need to do that once!
% 
% Check the "How do I adjust the properties to my own setup?" in the
% README.md

%% Record the signal
signal = player.rec(recNbSamples);

%% Plot it
figure
plot(signal)
pause(1)

%% And play it on channel 1
player.channelsPlay = [1];
player.channelsRec = [];
player.play(signal)

% eof