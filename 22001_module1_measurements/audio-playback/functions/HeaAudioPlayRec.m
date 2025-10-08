
classdef HeaAudioPlayRec < HeaAudio
    %HEAAUDIOPLAYREC HeaAudio player implemented with the PlayRec utility
    %
    %   HEAAUDIOPLAYREC Properties:
    %       channelsPlay - Channels to play the sound to (default = [])
    %       channelsRec - Channels to record the sound from (default = [])
    %       fs - Sampling frequency, in Hertz (default = 44100)
    %       devicePlayID - ID of the ASIO device to use for playing (default = 0)
    %       deviceRecID - ID of the ASIO device to use for recording (default = 0)
    %
    %   HEAAUDIOPLAYREC Methods:
    %       play - obj.play(X) plays X over the specified channels
    %       rec - Y = obj.rec() records Y over the specified channels
    %       playrec - Y = obj.playrec(X) plays X and records Y at the same time
    %
    %   For more help on the PlayRec utility, see <a href="matlab:web('http://www.playrec.co.uk/index.html','-browser')">Playrec website</a>
    %
    %   See also DEMOHEAAUDIO, HEAAUDIO, HEAAUDIOPSYCH, HEAAUDIODSP
    
    % HeaAudio properties
    properties
        channelsPlay; % Channels to play the sound to (default = [])
        channelsRec; % Channels to record the sound from (default = [])
        fs; % Sampling frequency, in Hertz (default = 44100)
    end
    
    % HeaAudioPlayRec specific properties
    properties
        devicePlayID; % ID of the ASIO device to use for playing (default = 0)
        deviceRecID; % ID of the ASIO device to use for recording (default = 0)
    end
    
    properties (Hidden = true, Access = protected)
        playrecObject = []; %PlayRec object
        isConstructed;
    end
    
    %Default parameters
    properties (Hidden = true)
        defaultParametersToLoad = 'playrec';
    end
    
    % HeaAudio methods
    methods
        function audioObj = HeaAudioPlayRec(varargin)
            %constructor of the HeaAudioPlayRec
            
            % Load user/default parameters
            defaultValues = audioObj.loadDefaultParameters(audioObj.defaultParametersToLoad);
            
            %%%%%%%%%%% Check input arguments %%%%%%%%%%%%%%%%%%%%%
            p = inputParser;
            addOptional(p,'channelsPlay',defaultValues.channelsPlay)
            addOptional(p,'channelsRec',defaultValues.channelsRec)
            addOptional(p,'fs',defaultValues.fs,@(x)validateattributes(x,...
                {'numeric'},{'nonempty'}))
            addOptional(p,'devicePlayID',defaultValues.devicePlayID,@(x)validateattributes(x,...
                {'numeric'},{'nonempty'}))
            addOptional(p,'deviceRecID',defaultValues.deviceRecID,@(x)validateattributes(x,...
                {'numeric'},{'nonempty'}))
            parse(p,varargin{:})
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            audioObj.isConstructed = false;
            
            %%%%%%%%%%% Assign properties   %%%%%%%%%%%%%%%%%%%%%%
            audioObj.channelsPlay = p.Results.channelsPlay;
            audioObj.channelsRec = p.Results.channelsRec;
            audioObj.fs = p.Results.fs;
            audioObj.devicePlayID = p.Results.devicePlayID;
            audioObj.deviceRecID = p.Results.deviceRecID;
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
            
            % playback sound
            fprintf('Playrec utility running... ')
            
            %this is where playrec is started
            obj.playrecObject=playrec('play',signalToPlay,obj.channelsPlay);
            
            %waiting for playrec to finish
            while (playrec('isFinished', obj.playrecObject) == 0)
            end
            
            fprintf('  done\n')
            
        end
        
        function signalRecorded = rec(obj,recNbSamples)
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
            
            
            %this is where playrec is started
            obj.playrecObject=playrec('rec',recNbSamples,obj.channelsRec);
            
            %waiting for playrec to finish
            while (playrec('isFinished', obj.playrecObject) == 0)
            end
            
            %Get the recording
            [signalRecorded, ~] = playrec('getRec',obj.playrecObject);
            
        end
        
        function stop(obj)
            %STOP not implemented
            %   Detailed explanation goes here
            
            
        end
        
        function signalRecorded = playrec(obj,signalToPlay)
            %PLAYREC Y = obj.playrec(X) plays X and records Y at the same time
            %
            
            % Check that channels are defined
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
            
            %this is where playrec is started
            obj.playrecObject=playrec('playrec',signalToPlay,obj.channelsPlay,-1,obj.channelsRec);
            
            %waiting for playrec to finish
            while (playrec('isFinished', obj.playrecObject) == 0)
            end
            
            %Get the recording
            [signalRecorded, ~] = playrec('getRec',obj.playrecObject);
        end
        
        
    end
    
    % obj.set methods
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
        
        function obj = set.devicePlayID(obj,value)
            if isnumeric(value)
                obj.devicePlayID = value;
                obj = obj.init;
            else
                error('Failed to init the parameter')
            end
        end
        
        function obj = set.deviceRecID(obj,value)
            if isnumeric(value)
                obj.deviceRecID = value;
                obj = obj.init;
            else
                error('Failed to init the parameter')
            end
        end
        
    end

    % Static methods
    methods(Static)
        function listDevices()
            %LISTDEVICES provides a list of available devices
            %
            %based on SELECT_PLAY_DEVICE from Robert Humphrey, January 2008
            
            % Initialize
            clear mex;
            devs = playrec('getDevices');
            
            % Prepare the prompt for output devices
            prompt = '\nAvailable OUTPUT devices (player.devicePlayID):\n -1) No Device\n';
            
            % Add output devices
            for k=1:length(devs)
                if(devs(k).outputChans)
                    prompt = [prompt, sprintf(' %2d) %s (%s) %d channels\n', ...
                        devs(k).deviceID, devs(k).name, ...
                        devs(k).hostAPI, devs(k).outputChans)];
                end
            end
            
            % Prepare the prompt for input devices
            prompt = [prompt, '\n \nAvailable INPUT devices (player.deviceRecID):\n -1) No Device\n'];
            
            % Add input devices
            for k=1:length(devs)
                if(devs(k).inputChans)
                    prompt = [prompt, sprintf(' %2d) %s (%s) %d channels\n', ...
                        devs(k).deviceID, devs(k).name, ...
                        devs(k).hostAPI, devs(k).inputChans)];
                end
            end
            
            % Print the prompt in the command window
            fprintf([prompt, '\n']);
        end
        
    end
    
    % Other methods
    methods (Hidden =  true, Access = protected)
        function obj = init(obj)
            
            %Check if object is finished constructing
            if obj.isConstructed
                
                %check if dsp object already exists
                if playrec('isInitialised')
                    playrec('reset')
                end
                
                %Check if channelsPlay only is defined
                if ~isempty(obj.channelsPlay) && isempty(obj.channelsRec)
                    % Initialization of Playrec
                    if (playrec('isInitialised'))==0
                        %Initialise Playrec
                        playrec('init',obj.fs,obj.devicePlayID,-1,...
                            max(obj.channelsPlay),1)
                        %Make sure it is running
                        if (playrec('isInitialised'))==0
                            error('Error when initializing PlayRec')
                        end
                    end
                end
                
                %Check if channelsRec only is defined
                if isempty(obj.channelsPlay) && ~isempty(obj.channelsRec)
                    % Initialization of Playrec
                    if (playrec('isInitialised'))==0
                        %Initialise Playrec
                        playrec('init',obj.fs,-1,obj.deviceRecID,...
                            1,max(obj.channelsRec))
                        %Make sure it is running
                        if (playrec('isInitialised'))==0
                            error('Error when initializing PlayRec')
                        end
                    end
                end
                
                %Check if channelsPlay and channelsRec are defined
                if ~isempty(obj.channelsPlay) && ~isempty(obj.channelsRec)
                    % Initialization of Playrec
                    if (playrec('isInitialised'))==0
                        %Initialise Playrec
                        playrec('init',obj.fs,obj.devicePlayID,obj.deviceRecID,...
                            max(obj.channelsPlay),max(obj.channelsRec))
                        %Make sure it is running
                        if (playrec('isInitialised'))==0
                            error('Error when initializing PlayRec')
                        end
                    end
                end
                
                disp(obj)
                disp('Player initialized with above properties')
                
            end
            
        end
        
        
    end
    
end