

classdef HeaAudioDSP < HeaAudio
    %HEAAUDIODSP HeaAudio player implemented with the Matlab DSP System Toolbox
    %
    %   HEAAUDIODSP Properties:
    %       channelsPlay - Channels to play the sound to (default = [])
    %       channelsRec - Channels to record the sound from (default = [])
    %       fs - Sampling frequency, in Hertz (default = 44100)
    %       devicePlayName - Name of the playing device to use (default = 'ASIO Fireface USB')
    %       deviceRecName - Name of the recording device to use (default = 'ASIO Fireface USB')
    %       bufferSize - Buffer size (default = 1024)
    %       queueDuration - Queue duration (default = 0.1)
    %       samplesPerFrame - Samples per frame (default = 1024)
    %
    %   HEAAUDIODSP Methods:
    %       play - obj.play(X) plays X over the specified channels
    %       rec - Y = obj.rec() records Y over the specified channels
    %       playrec - Y = obj.playrec(X) plays X and records Y at the same time
    %
    %   For more help on the Matlab DSP System Toolbox, see <a href="matlab:web('http://se.mathworks.com/products/dsp-system/','-browser')">Matlab DSP System Toolbox website</a>
    %
    %   See also DEMOHEAAUDIO, HEAAUDIO, HEAAUDIOPSYCH, HEAAUDIOPLAYREC
    
    
    %HeaAudio properties
    properties
        channelsPlay; % Channels to play the sound to (default = [])
        channelsRec; % Channels to record the sound from (default = [])
        fs; % Sampling frequency, in Hertz (default = 44100)
    end
    
    %HeaAudioDSP specific properties
    properties
        devicePlayName; % Name of the playing device to use (default = 'ASIO Fireface USB')
        deviceRecName; % Name of the recording device to use (default = 'ASIO Fireface USB')
        bufferSize; % Buffer size (default = 1024)
        queueDuration; % Queue duration (default = 0.1)
        samplesPerFrame; % Samples per frame (default = 1024)
    end
    
    properties (Hidden = true,Access = protected)
        hap = []; %handle to the dsp.AudioPlayer object
        har = []; %handle to the dsp.AudioRecorder object
        isConstructed;
    end
    
    %Default parameters
    properties (Hidden = true)
        defaultParametersToLoad = 'dsp';
    end
    
    %HeaAudio methods
    methods
        function audioObj = HeaAudioDSP(varargin)
            %constructor of the HeaAudioDSP
            
            % Load user/default parameters
            defaultValues = audioObj.loadDefaultParameters(audioObj.defaultParametersToLoad);
            
            %%%%%%%%%%% Check input arguments %%%%%%%%%%%%%%%%%%%%%
            p = inputParser;
            addOptional(p,'channelsPlay',defaultValues.channelsPlay)
            addOptional(p,'channelsRec',defaultValues.channelsRec)
            addOptional(p,'fs',defaultValues.fs,@(x)validateattributes(x,...
                {'numeric'},{'nonempty'}))
            addOptional(p,'devicePlayName',defaultValues.devicePlayName,@(x)validateattributes(x,...
                {'char'},{'nonempty'}))
            addOptional(p,'deviceRecName',defaultValues.deviceRecName,@(x)validateattributes(x,...
                {'char'},{'nonempty'}))            
            addOptional(p,'bufferSize',defaultValues.bufferSize,@(x)validateattributes(x,...
                {'numeric'},{'nonempty'}))
            addOptional(p,'queueDuration',defaultValues.queueDuration,@(x)validateattributes(x,...
                {'numeric'},{'nonempty'}))
            addOptional(p,'samplesPerFrame',defaultValues.samplesPerFrame,@(x)validateattributes(x,...
                {'numeric'},{'nonempty'}))
            parse(p,varargin{:})
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            audioObj.isConstructed = false;
            
            %%%%%%%%%%% Assign properties   %%%%%%%%%%%%%%%%%%%%%%
            audioObj.channelsPlay = p.Results.channelsPlay;
            audioObj.channelsRec = p.Results.channelsRec;
            audioObj.fs = p.Results.fs;
            audioObj.devicePlayName = p.Results.devicePlayName;
            audioObj.deviceRecName = p.Results.deviceRecName;
            audioObj.bufferSize = p.Results.bufferSize;
            audioObj.queueDuration = p.Results.queueDuration;
            audioObj.samplesPerFrame = p.Results.samplesPerFrame;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            audioObj.isConstructed = true;
            
            %Make sure nothing is running in the background
            clear mex
            
            %Init
            audioObj = init(audioObj);
        end
        
        function delete(obj)
            %DELETE destructor of the class
            clear mex
        end
        
        function play(obj,signalToPlay)
            % PLAY obj.play(X) plays X over the specified channels
            %
            
            %Check that channels are defined
            if isempty(obj.channelsPlay) || ~isempty(obj.channelsRec)
                if isempty(obj.channelsPlay)
                    error('The property obj.channelsPlay needs to be defined to use the method obj.play')
                else
                    error('The property obj.channelsRec needs to be empty to use the method obj.play')
                end
            end
            
            % If the signal is mono, but there are more than one channel, duplicate the input
            if isvector(signalToPlay) && length(obj.channelsPlay)>1
                signalToPlay = repmat(signalToPlay, 1, length(obj.channelsPlay));
            end
            
            %Check that the number of channels is in accordance with the signal size
            if size(signalToPlay,2) ~= length(obj.channelsPlay)
                error('signal must be a vector with the number of columns matching the number of channels')
            end
            
            %Find number of frames to play
            framesToPlay = ceil(size(signalToPlay,1) ./ obj.samplesPerFrame);
            %Pad signal to whole number of frames
            samplesToPad = framesToPlay*obj.samplesPerFrame - size(signalToPlay,1);
            signalToPlay = [signalToPlay; zeros(samplesToPad,size(signalToPlay,2))];
            
            %Play audio
            fprintf('DSP audioplayer utility running... ')
            for ii = 1:framesToPlay
                audio = signalToPlay((ii-1)*obj.samplesPerFrame+1:ii*obj.samplesPerFrame,:);
                step(obj.hap,audio);
            end
            pause(obj.hap.QueueDuration); % wait until audio is played to the end
            release(obj.hap);

            fprintf('  done\n')
        end
        
        function signalRecorded = rec(obj,recNbSamples)
            %REC Y = obj.rec() records Y over the specified channels
            
            % Check that channels are defined
            if ~isempty(obj.channelsPlay) || isempty(obj.channelsRec)
                if isempty(obj.channelsRec)
                    error('The property obj.channelsRec needs to be defined to use the method obj.rec')
                else
                    error('The property obj.channelsPlay needs to be empty to use the method obj.rec')
                end
            end
            
            
            % Initialize temporary data
            idx = 1; % Buffer index
            nRec = 0; % Number of samples already recorded
            signalRecorded = zeros(recNbSamples,length(obj.channelsRec));
            
            % Recording
            while nRec < recNbSamples
                signalRecorded(nRec+1:nRec+obj.samplesPerFrame,:) = step(obj.har);
                nRec = idx * obj.samplesPerFrame;
                idx = idx +1;
            end
            
            % If recNbSamples is not a multiple of the buffer size, there will be more
            % samples recorded than asked bu the user
            signalRecorded = signalRecorded(1:recNbSamples,:);
            
            %release object
            release(obj.har);
            
        end
        
        function stop(obj)
            %STOP not implemented
            
        end
        
        function signalRecorded = playrec(obj,signalToPlay)
            %PLAYREC Y = obj.playrec(X) plays X and records Y at the same time
            
            %Check that channels are defined
            if isempty(obj.channelsPlay) || isempty(obj.channelsRec)
                error('Both obj.channelsPlay and obj.channelsRec needs to be defined to use the method obj.playrec')
            end
            
            % If the signal is mono, but there are more than one channel, duplicate the input
            if isvector(signalToPlay) && length(obj.channelsPlay)>1
                signalToPlay = repmat(signalToPlay, 1, length(obj.channelsPlay));
            end
            
            % Check that the number of channels is in accordance with the signal size
            if size(signalToPlay,2) ~= length(obj.channelsPlay)
                error('signal must be a vector with the number of columns matching the number of channels')
            end
            
            %Find number of frames to play
            framesToPlay = ceil(size(signalToPlay,1) ./ obj.samplesPerFrame);
            %Pad signal to whole number of frames
            samplesToPad = framesToPlay*obj.samplesPerFrame - size(signalToPlay,1);
            signalToPlay = [signalToPlay; zeros(samplesToPad,size(signalToPlay,2))];

            % Initialize temporary data for recording
            signalRecorded = zeros(size(signalToPlay,1),length(obj.channelsRec));
            
            %Play and record
            for ii = 1:framesToPlay
                audio = signalToPlay((ii-1)*obj.samplesPerFrame+1:ii*obj.samplesPerFrame,:);
                step(obj.hap,audio);
                signalRecorded((ii-1)*obj.samplesPerFrame+1:ii*obj.samplesPerFrame,:) = step(obj.har);
            end
            
            release(obj.hap);
            release(obj.har);
            
            % If recNbSamples is not a multiple of the buffer size, there will be more
            % samples recorded than asked by the user
            signalRecorded = signalRecorded(1:end-samplesToPad,:);
        end
        
    end
    
    %obj.set methods
    methods
        
        function obj = set.channelsPlay(obj,value)
            if isnumeric(value)
                obj.channelsPlay = value;
                obj = obj.init;
            else
                error('Failed to init the parameter')
            end
        end
        
        function obj = set.channelsRec(obj,value)
            if isnumeric(value)
                obj.channelsRec = value;
                obj = obj.init;
            else
                error('Failed to init the parameter')
            end
        end
        
        function obj = set.fs(obj,value)
            if isnumeric(value)
                obj.fs = value;
                obj = obj.init;
            else
                error('Failed to init the parameter')
            end
        end
        
        function obj = set.devicePlayName(obj,value)
            if ischar(value)
                obj.devicePlayName = value;
                obj = obj.init;
            else
                error('Failed to init the parameter')
            end
        end
        
        function obj = set.deviceRecName(obj,value)
            if ischar(value)
                obj.deviceRecName = value;
                obj = obj.init;
            else
                error('Failed to init the parameter')
            end
        end
        
        function obj = set.bufferSize(obj,value)
            if isnumeric(value)
                obj.bufferSize = value;
                obj = obj.init;
            else
                error('Failed to init the parameter')
            end
        end
        
        function obj = set.queueDuration(obj,value)
            if isnumeric(value)
                obj.queueDuration = value;
                obj = obj.init;
            else
                error('Failed to init the parameter')
            end
        end
        
        function obj = set.samplesPerFrame(obj,value)
            if isnumeric(value)
                obj.samplesPerFrame = value;
                obj = obj.init;
            else
                error('Failed to init the parameter')
            end
        end
        
    end
    
    % static methods
    methods(Static)
        function listDevices()
            %LISTDEVICES provides a list of available devices
            %
            %based on SELECT_PLAY_DEVICE from Robert Humphrey, January 2008
            
            %Initialization (getting the api name looks tricky, maybe there is a better way)
            clear mex;
            devsOut = dspAudioDeviceInfo('outputs');
            devsIn = dspAudioDeviceInfo('inputs');
            apiNames = dspAudioDeviceInfo('hostApiNames');
            apiIds = dspAudioDeviceInfo('hostApiIds');
            apiID = dspAudioDeviceInfo('defaultHostApi');
            apiName = apiNames(find(apiID == apiIds));
            
            % Prepare the prompt for output devices
            prompt = '\nAvailable OUTPUT devices (player.devicePlayName):\n "Default": default output device\n';
            
            % Add output devices
            for k=1:length(devsOut)
                prompt = [prompt, sprintf(' "%s": (%s) %d channels\n', ...
                    strrep(devsOut(k).name, [' (' apiName{:} ')'],''),...
                    apiName{:},devsOut(k).maxOutputs)];
            end
            
            % Prepare the prompt for input devices
            prompt = [prompt, '\nAvailable INPUT devices (player.deviceRecName):\n "Default": default input device\n'];
            
            % Add input devices
            for k=1:length(devsIn)
                prompt = [prompt, sprintf(' "%s": (%s) %d channels\n', ...
                    strrep(devsIn(k).name, [' (' apiName{:} ')'],''),...
                    apiName{:},devsIn(k).maxInputs)];
            end
            
            % Print the prompt in the command window
            fprintf([prompt, '\n']);
        end
    end
    
    
    %other methods
    methods (Hidden =  true, Access = protected)
        function obj = init(obj)
            
            %Check if object is finished constructing
            if obj.isConstructed
                
                %check if dsp object already exists
                if ~isempty(obj.hap)
                    release(obj.hap);
                end
                if ~isempty(obj.har)
                    release(obj.har);
                end
                
                %Check if channelsPlay is defined
                if ~isempty(obj.channelsPlay)
                    %Create the handle to the dsp.AudioPlayer
                    obj.hap = dsp.AudioPlayer( 'DeviceName',obj.devicePlayName,...
                        'SampleRate',obj.fs,...
                        'BufferSizeSource','Property',...
                        'BufferSize',obj.bufferSize,...
                        'ChannelMappingSource','Property',...
                        'ChannelMapping',obj.channelsPlay,...
                        'QueueDuration',obj.queueDuration);
                end
                
                %Check if channelsRec is defined
                if ~isempty(obj.channelsRec)
                    %Create the handle to the dsp.AudioRecorder
                    obj.har = dsp.AudioRecorder( 'DeviceName',obj.deviceRecName,...
                        'SampleRate',obj.fs,...
                        'BufferSizeSource','Property',...
                        'BufferSize',obj.bufferSize,...
                        'ChannelMappingSource','Property',...
                        'ChannelMapping',obj.channelsRec,...
                        'QueueDuration',obj.queueDuration,...
                        'SamplesPerFrame',obj.samplesPerFrame);
                end
                
                disp(obj)
                disp('Player initialized with above properties')
                
            end
            
        end
        
        
    end
end