% HeaAudio default parameters. If you want to have different starting
% parameters, run HeaAudio.createUserParameterFile and modify the file
% 'userParametersHeaAudio.m' which should be now in your path.

%% General parameters

%general.channelsPlay = [1 2]; % Channels to play the sound to (ex. [1 2] or [1 3 15])
%general.channelsRec = []; % Channels to record the sound from (ex. [1 2] or [1 3 15])
general.fs = 48000; % Sampling frequency, in Hertz

%% HeaAudio PsychToolbox

%psych.deviceID = 42; % Device ID (run HeaAudioPsych.listDevices to get the list)
%psych.bufferSize = 1024; % Buffer size, in samples
%psych.waitRefreshSeconds = 0.2; % How often the player status is checked, when playing back sound
%psych.verbose = 0; % Verbose (from 0 = silent to 10 = maximum)
%psych.reqLatency = 0; % Wanted latency, in seconds (0 = as fast as possible)
%psych.secondsToAllocate = 1; % Number of seconds to allocate in the recording buffer

%% HeaAudio PlayRec

%playrec.devicePlayID = 0; % Playing Device ID (run HeaAudioPlayRec.listDevices to get the list)
%playrec.deviceRecID = 0; % Recording Device ID (run HeaAudioPlayRec.listDevices to get the list)

%% HeaAudio DSP

dsp.devicePlayName = 'ASIO Fireface'; % Playing Device ID (run HeaAudioDSP.listDevices to get the list)
dsp.deviceRecName = 'ASIO Fireface'; % Recording Device ID (run HeaAudioDSP.listDevices to get the list)
dsp.bufferSize = 512; % Buffer size, in samples (type "doc dsp.audioplayer" and check the first figure)
%dsp.queueDuration = 0.1; % Queue duration, in seconds (type "doc dsp.audioplayer" and check the first figure)
dsp.samplesPerFrame = 512; % Samples per frame, in samples (type "doc dsp.audioplayer" and check the first figure)
