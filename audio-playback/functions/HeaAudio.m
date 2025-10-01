
classdef (Abstract) HeaAudio
    %HEAAUDIO class (abstract)
    %
    %   HEAAUDIO Properties:
    %       channelsPlay - Channels to play the sound to
    %       channelsRec - Channels to record the sound from
    %       fs - Sampling frequency, in Hertz
    %
    %
    %   HEAAUDIO Methods:
    %       play - obj.play(X) plays X over the specified channels
    %       rec - Y = obj.rec(recNbSamples) records recNbSamples in Y over the specified channels
    %       playrec - Y = obj.playrec(X) plays X and records Y at the same time
    %
    %   This is the super class of several implementations, see below:
    %
    %   See also DEMOHEAAUDIO, HEAAUDIOPLAYREC, HEAAUDIOPSYCH, HEAAUDIODSP
    
    properties (Abstract)
        channelsPlay % Channels to play the sound to
        channelsRec % Channels to record the sound from
        fs % Sampling frequency, in Hertz
    end
    
    properties (Constant, Access = protected)
        userParametersFileName = 'userParametersHeaAudio.m';
        defaultParametersFileName = 'defaultParametersHeaAudio.m';
    end
    
    methods (Abstract)
        play(obj,signalToPlay) % obj.play(X) plays X over the specified channels
        signalRecorded = rec(obj, recNbSamples) % Y = obj.rec(recNbSamples) records Y over the specified channels
        signalRecorded = playrec(obj, signalToPlay) % Y = obj.playrec(X) plays X and records Y at the same time
        stop(obj) % not implemented
        delete(obj) % destructor of the class
    end
    
    methods (Abstract, Static)
        listDevices() % list devices
    end
    
    methods (Static, Access = protected)
        function defaultValues = loadDefaultParameters(backend)
            
            % Load default parameters
            defaultParametersHeaAudio;
            
            % Overwrite with user parameters
            if exist('userParametersHeaAudio','file')
                userParametersHeaAudio;
            end
            
            % Create the parameters structure
            generalDefaults = eval('general');
            backendDefaults = eval(backend);
            M = [fieldnames(generalDefaults)', fieldnames(backendDefaults)';
                 struct2cell(generalDefaults)', struct2cell(backendDefaults)'
            ];
            defaultValues = struct(M{:});
        end
    end
    
    methods (Static)
        function createUserParameterFile(varargin)
            %CREATEUSERPARAMETERFILE  Creates a blank config file in the current folder.
            
            % Open the default parameter files
            fid = fopen(HeaAudio.defaultParametersFileName);
            iLine = 1;
            tline = fgetl(fid);
            newfile = {};
            while ischar(tline)
                newfile{iLine} = regexprep(tline, '^(\w.*)', '%$1');
                tline = fgetl(fid);
                iLine = iLine + 1;
            end
            fclose(fid);
            
            % Check if the user parameters should be overwritten
            if nargin > 0
                overwrite = varargin{1};
            else
                overwrite = false;
            end
            
            
            % Write the user parameters file
            outputFilename = HeaAudio.userParametersFileName;
            if exist(outputFilename,'file') && ~overwrite
                error(['HeaAudio:createUserParameterFile:The file %s ',...
                    'already exists. Call the method with a "true" ', ...
                    'argument to overwrite the file.'], outputFilename);
            else
                fid = fopen(outputFilename, 'w');
            end
            
            for iLine = 1:length(newfile)
                fprintf(fid, '%s\n', newfile{iLine});
            end
            
            fclose(fid);
            
        end
        
    end
    
    
    
end