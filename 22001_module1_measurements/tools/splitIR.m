function [d,r] = splitIR(ir,fsHz,timeDirect)
%splitIR   Split an impulse response into a direct and a reverberant part.
%
%USAGE
%   [d,r] = splitIR(ir,fsHz)
%   [d,r] = splitIR(ir,fsHz,timeDirect)
%
%INPUT ARGUMENTS
%           ir : room impulse response [nSamples x nChannels] 
%         fsHz : sampling frequency in Hertz
%   timeDirect : duration (in seconds) of the direct part starting from 
%                the maximum peak position in each channel 
%                (default, timeDirect = 1E-3).
% 
%OUTPUT ARGUMENTS
%   d : direct part of the IR [nPoints x nChannels] 
%   r : reverberant part of the IR [nPoints x nChannels] 
% 
%   splitIR(...) plots the IRs in a new figure. 
% 
%   ***********************************************************************


%% CHECK INPUT ARGUMENTS  
% 
% 
% Check for proper input arguments
if nargin < 2 || nargin > 3
    help(mfilename);
    error('Wrong number of input arguments!')
end

% Set default values
if nargin < 3 || isempty(timeDirect);  timeDirect = 1E-3; end

[nSamples, nChannels] = size(ir);

%% FIND PEAKS AND SPLIT POINT 
% 
% 
% Find peak for each channel, where 'mVal' is the value at maximum, and
% 'mIdx' is the index (sample) at the maximum
[mVal,mIdx] = ;

% Find sample to split at (T_peak + timeDirect)

%% OUTPUT DIRECT AND REVERBERANT PART
% 

d = ; % direct part
r = ; % reverberant part


%% PLOT IRs
% 
% 
% Show direct and reverberant part
if nargout == 0
    % do plots
end
%   ***********************************************************************