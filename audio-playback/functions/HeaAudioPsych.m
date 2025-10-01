

classdef HeaAudioPsych < HeaAudio
    %HEAAUDIOPSYCH HeaAudio player implemented with the Psychtoolbox
    %
    %   HEAAUDIOPSYCH Properties:
    %       channelsPlay - Channels to play the sound to (default = [])
    %       channelsRec - Channels to record the sound from (default = [])
    %       fs - Sampling frequency, in Hertz (default = 44100)
    %       deviceID - ID of the device to use for playing (default = 48)
    %       bufferSize - Buffer size (default = 1024)
    %       waitRefreshSeconds - How often is the status of the player
    %       checked when playing (default = 0.2)
    %       verbose - How much verbose to output, 0 = nothing, up to 10 (default = 0)
    %       reqLatency - Latency required, 0 = smallest possible, might drop samples (default = 0)
    %       secondsToAllocate - number of seconds to allocate in the recording buffer (default = 1)
    %
    %   HEAAUDIOPSYCH Methods:
    %       play - obj.play(X) plays X over the specified channels
    %       rec - Y = obj.rec() records Y over the specified channels
    %       playrec - Y = obj.playrec(X) plays X and records Y at the same time
    %
    %   For more help on the Psychtoolbox utility, see <a href="matlab:web('http://psychtoolbox.org/','-browser')">Psychtoolbox website</a>
    %
    %   See also DEMOHEAAUDIO, HEAAUDIO, HEAAUDIOPLAYREC, HEAAUDIODSP
    % HeaAudio properties
    properties
        channelsPlay; % Channels to play the sound to (default = [])
        channelsRec; % Channels to record the sound from (default = [])
        fs; % Sampling frequency, in Hertz (default = 44100)
    end
    
    % HeaAudioPsych specific properties
    properties
        deviceID; % ID of the device to use for playing (default = 48)
        bufferSize; % Buffer size (default = 1024)
        waitRefreshSeconds; % How often is the status of the player checked when playing (default = 0.2)
        verbose; % How much verbose to output, 0 = nothing, up to 10 (default = 0)
        reqLatency; % Latency required, 0 = smallest possible, might drop samples (default = 0)
        secondsToAllocate; % number of seconds to allocate in the recording buffer (default = 1)
    end
    
    properties (Hidden = true,Access = protected)
        pahandle = []; %Handle to the PsychPortAudio object
        isConstructed;
    end
    
    %Default parameters
    properties (Hidden = true)
        defaultParametersToLoad = 'psych';
    end    
    
    %HeaAudio methods
    methods
        function audioObj = HeaAudioPsych(varargin)
            %constructor of the HeaAudioPlayRec
            
            % Load user/default parameters
            defaultValues = audioObj.loadDefaultParameters(audioObj.defaultParametersToLoad);
            
            %%%%%%%%%%% Check input arguments %%%%%%%%%%%%%%%%%%%%%
            p = inputParser;
            addOptional(p,'channelsPlay',defaultValues.channelsPlay)
            addOptional(p,'channelsRec',defaultValues.channelsRec)
            addOptional(p,'fs',defaultValues.fs,@(x)validateattributes(x,...
                {'numeric'},{'nonempty'}))
            addOptional(p,'deviceID',defaultValues.deviceID,@(x)validateattributes(x,...
                {'numeric'},{'nonempty'}))
            addOptional(p,'bufferSize',defaultValues.bufferSize,@(x)validateattributes(x,...
                {'numeric'},{'nonempty'}))
            addOptional(p,'waitRefreshSeconds',defaultValues.waitRefreshSeconds,@(x)validateattributes(x,...
                {'numeric'},{'nonempty'}))
            addOptional(p,'verbose',defaultValues.verbose,@(x)validateattributes(x,...
                {'numeric'},{'nonempty'}))
            addOptional(p,'reqLatency',defaultValues.reqLatency,@(x)validateattributes(x,...
                {'numeric'},{'nonempty'}))
            addOptional(p,'secondsToAllocate',defaultValues.secondsToAllocate,@(x)validateattributes(x,...
                {'numeric'},{'nonempty'}))
            parse(p,varargin{:})
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            audioObj.isConstructed = false;
            
            %%%%%%%%%%% Assign properties   %%%%%%%%%%%%%%%%%%%%%%
            audioObj.channelsPlay = p.Results.channelsPlay;
            audioObj.channelsRec = p.Results.channelsRec;
            audioObj.fs = p.Results.fs;
            audioObj.deviceID = p.Results.deviceID;
            audioObj.bufferSize = p.Results.bufferSize;
            audioObj.waitRefreshSeconds = p.Results.waitRefreshSeconds;
            audioObj.verbose = p.Results.verbose;
            audioObj.reqLatency = p.Results.reqLatency;
            audioObj.secondsToAllocate = p.Results.secondsToAllocate;
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
            %PLAY obj.play(X) plays X over the specified channels
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
            
            % Check that the number of channels is in accordance with the signal size
            if size(signalToPlay,2) ~= length(obj.channelsPlay)
                error('signal must be a vector with the number of columns matching the number of channels')
            end
            
            % In PsychAudio, the signal needs to be in rows
            signalToPlay = signalToPlay';
            
            % Fill the audio playback buffer with the audio data
            PsychPortAudio('FillBuffer', obj.pahandle, signalToPlay);
            
            %% Play the audio data
            
            fprintf('PsychPortAudio utility running... ')
            
            % Start playing
            PsychPortAudio('Start', obj.pahandle);
            
            % Check the status after some time
            WaitSecs(obj.waitRefreshSeconds);
            s = PsychPortAudio('GetStatus', obj.pahandle);
            % disp(s);
            
            %Wait the playback to be finished
            while s.Active
                WaitSecs(obj.waitRefreshSeconds);
                s = PsychPortAudio('GetStatus', obj.pahandle);
                %     disp(s);
            end
            
            %delete buffer
            PsychPortAudio('DeleteBuffer');
            
            fprintf('  done\n')
            
            
        end
        
        function signalRecorded = rec(obj, recNbSamples)
            %REC Y = obj.rec() records Y over the specified channels
            %
            
            % Check that channels are defined
            if ~isempty(obj.channelsPlay) || isempty(obj.channelsRec)
                if isempty(obj.channelsRec)
                    error('The property obj.channelsRec needs to be defined to use the method obj.rec')
                else
                    error('The property obj.channelsPlay needs to be empty to use the method obj.rec')
                end
            end
            
            % Initialize the buffer and temporary data
            PsychPortAudio('GetAudioData', obj.pahandle, obj.secondsToAllocate);
            
            signalRecorded = zeros(recNbSamples,length(obj.channelsRec));
            nRec = 0;
            
            % Start recording
            PsychPortAudio('Start', obj.pahandle);
            
            %Wait the playback to be finished
            while nRec < recNbSamples
                
                %Get data
                [audiodata, nRec] = PsychPortAudio('GetAudioData', obj.pahandle);
                
                %audiodata will be empty if you look before the buffer of the sound
                %card is full again
                if ~isempty(audiodata)
                    signalRecorded(nRec+1:nRec+size(audiodata,2),:) = audiodata';
                end
            end
            
            % Stop recording and drain buffer
            PsychPortAudio('Stop',obj.pahandle);
            [~] = PsychPortAudio('GetAudioData', obj.pahandle);
            
            % If recNbSamples is not a multiple of the buffer size, there will be more
            % samples recorded than asked bu the user
            signalRecorded = signalRecorded(1:recNbSamples,:);
            
            
        end
        
        function stop(obj)
            %STOP not implemented
            %
            
            
        end
        
        
        function signalRecorded = playrec(obj,signalToPlay)
            %PLAYREC Y = obj.playrec(X) plays X and records Y at the same time
            %
            
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
            
            % In PsychAudio, the signal needs to be in rows
            signalToPlay = signalToPlay';
            
            % Fill the audio playback buffer with the audio data
            PsychPortAudio('FillBuffer', obj.pahandle, signalToPlay);
            
            % Initialize the buffer and temporary data
            PsychPortAudio('GetAudioData', obj.pahandle, obj.secondsToAllocate);
            recNbSamples = size(signalToPlay,2);
            signalRecorded = zeros(recNbSamples,length(obj.channelsRec));
            nRec = 0;
            
            % Start recording
            PsychPortAudio('Start', obj.pahandle);
            
            %Wait the playback to be finished
            while nRec < recNbSamples
                
                %Get data
                [audiodata, nRec] = PsychPortAudio('GetAudioData', obj.pahandle);
                
                %audiodata will be empty if you look before the buffer of the sound
                %card is full again
                if ~isempty(audiodata)
                    signalRecorded(nRec+1:nRec+size(audiodata,2),:) = audiodata';
                end
            end
            
            % Stop recording and drain buffer
            PsychPortAudio('Stop',obj.pahandle);
            [~] = PsychPortAudio('GetAudioData', obj.pahandle);
            
            % If recNbSamples is not a multiple of the buffer size, there will be more
            % samples recorded than asked bu the user
            signalRecorded = signalRecorded(1:recNbSamples,:);
            
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
        
        function obj = set.deviceID(obj,value)
            if isnumeric(value)
                obj.deviceID = value;
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
        
        function obj = set.waitRefreshSeconds(obj,value)
            if isnumeric(value)
                obj.waitRefreshSeconds = value;
                obj = obj.init;
            else
                error('Failed to init the parameter')
            end
        end
        
        function obj = set.verbose(obj,value)
            if isnumeric(value)
                obj.verbose = value;
                obj = obj.init;
            else
                error('Failed to init the parameter')
            end
        end
        
        function obj = set.reqLatency(obj,value)
            if isnumeric(value)
                obj.reqLatency = value;
                obj = obj.init;
            else
                error('Failed to init the parameter')
            end
        end
        
        function obj = set.secondsToAllocate(obj,value)
            if isnumeric(value)
                obj.secondsToAllocate = value;
                obj = obj.init;
            else
                error('Failed to init the parameter')
            end
        end
    end
    
    % Static methods
    methods(Static)
        function devs = listDevices()
            %LISTDEVICES provides a list of available devices
            %
            %devs
            %
            %based on SELECT_PLAY_DEVICE from Robert Humphrey, January 2008
            
            %Initialization
            clear mex;
            AssertOpenGL;
            [~] = evalc('InitializePsychSound;');
            [~,devs] = evalc('PsychPortAudio(''GetDevices'')');
            
            % Prepare the prompt for output devices
            prompt = '\nAvailable OUTPUT devices (player.deviceID):\n -1) Default\n';
            
            % Add output devices
            for k=1:length(devs)
                if(devs(k).NrOutputChannels)
                    prompt = [prompt, sprintf(' %2d) %s (%s) %d channels\n', ...
                        devs(k).DeviceIndex, devs(k).DeviceName, ...
                        devs(k).HostAudioAPIName, devs(k).NrOutputChannels)];
                end
            end
            
            % Prepare the prompt for input devices
            prompt = [prompt, '\n \nAvailable INPUT devices (player.deviceID):\n -1) Default\n'];
            
            % Add input devices
            for k=1:length(devs)
                if(devs(k).NrInputChannels)
                    prompt = [prompt, sprintf(' %2d) %s (%s) %d channels\n', ...
                        devs(k).DeviceIndex, devs(k).DeviceName, ...
                        devs(k).HostAudioAPIName, devs(k).NrInputChannels)];
                end
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
                
                %check if Psych handle already exists
                if ~isempty(obj.pahandle)
                    % close the audio device
                    PsychPortAudio('Close');
                end
                
                %%%%%%%%% Play init %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                try
                    AssertOpenGL;
                catch ME
                    if strcmp(ME.identifier, 'MATLAB:UndefinedFunction')
                        msg = ['It seems that PsychToolbox cannot be found. '...
                            'Please double check that it is installed and in your path.'];
                        causeException = MException('HeaAudioPsych:PsychToolboxNotAvailable', msg);
                        ME = addCause(ME, causeException);
                    end
                    rethrow(ME)
                end
                
                %Check if channelsPlay is the only defined
                if ~isempty(obj.channelsPlay) && isempty(obj.channelsRec)
                    % check that Psychtoolbox is installed
                    
                    % Perform basic initialization of the sound driver:
                    InitializePsychSound;
                    PsychPortAudio('Verbosity',obj.verbose);
                    
                    % For PsychToolbox, channels start at 0
                    channelsPlay=obj.channelsPlay-1;
                    
                    % Open the specified audio device <param.playDeviceID>, with default mode <[]> (==Only playback),
                    % and a required latencyclass of zero (0 == no low-latency mode), as well as
                    % a sampling frequency of <fs> and a certain number of <channels> .
                    %Then comes the buffer size <param.bufferSize>, a suggested latency and
                    %the ID of the channels
                    %
                    % This returns a handle to the audio device:
                    try
                        obj.pahandle = PsychPortAudio('Open',obj.deviceID,[],obj.reqLatency,obj.fs,...
                            length(channelsPlay),obj.bufferSize,[],channelsPlay);
                    catch
                        error('Could not open the specified device')
                    end
                end
                
                
                %%%%%%%% rec init %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if ~isempty(obj.channelsRec) && isempty(obj.channelsPlay)
                    % check that Psychtoolbox is installed
                    
                    % Perform basic initialization of the sound driver:
                    InitializePsychSound;
                    PsychPortAudio('Verbosity',obj.verbose);
                    
                    % For PsychToolbox, channels start at 0
                    channelsRec=obj.channelsRec-1;
                    
                    % Open the specified audio device <param.playDeviceID>, with default mode <2> (==Only rec),
                    % and a required latencyclass of zero (0 == no low-latency mode), as well as
                    % a sampling frequency of <fs> and a certain number of <channels> .
                    %Then comes the buffer size <param.bufferSize>, a suggested latency and
                    %the ID of the channels
                    %
                    % This returns a handle to the audio device:
                    try
                        obj.pahandle = PsychPortAudio('Open',obj.deviceID,2,obj.reqLatency,obj.fs,...
                            length(channelsRec),obj.bufferSize,[],channelsRec);
                    catch
                        error('Could not open the specified device')
                    end
                end
                
                %%%%%%%%% playrec init %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if ~isempty(obj.channelsRec) && ~isempty(obj.channelsPlay)
                    % check that Psychtoolbox is installed
                    
                    % Perform basic initialization of the sound driver:
                    InitializePsychSound;
                    PsychPortAudio('Verbosity',obj.verbose);
                    
                    % For PsychToolbox, channels start at 0
                    channelsPlay=obj.channelsPlay-1;
                    channelsRec=obj.channelsRec-1;
                    
                    %Channel selection (First row: play, second row: rec)
                    %
                    %For example: [1 2; 3 NaN]
                    channelSelection = NaN(2,max(length(channelsPlay),length(channelsRec)));
                    channelSelection(1,1:length(channelsPlay)) = channelsPlay;
                    channelSelection(2,1:length(channelsRec)) = channelsRec;
                    
                    % Open the specified audio device <param.playDeviceID>, with default mode <2> (==Only rec),
                    % and a required latencyclass of zero (0 == no low-latency mode), as well as
                    % a sampling frequency of <fs> and a certain number of <channels> .
                    %Then comes the buffer size <param.bufferSize>, a suggested latency and
                    %the ID of the channels
                    %
                    % This returns a handle to the audio device:
                    
                    obj.pahandle = PsychPortAudio('Open',obj.deviceID,3,obj.reqLatency,obj.fs,...
                        [length(channelsPlay), length(channelsRec)],...
                        obj.bufferSize,[],channelSelection);
                end
                
                disp(obj)
                disp('Player initialized with above properties')
            end
        end
        
        
    end
end

%eof
