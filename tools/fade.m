function x = fade(x, Nin, Nout)
%fade   Apply a raised cosine window for fade in and fade out
% 
%USAGE
%   y = fade(x, Nin, Nout)
%  
%INPUT ARGUMENTS
%         x : input signal [N x 1]
%   Nfadein : number of samples to fade in
%  Nfadeout : number of samples to fade out
% 
%OUTPUT ARGUMENTS
%   x : signal with raised cosine window applied [N x 1]



%% CHECK INPUT ARGUMENTS
%
%
% Check for proper input arguments
if nargin < 1 || nargin > 3
    help(mfilename);
    error('Wrong number of input arguments!')
end

% Set default values
if nargin < 3 || isempty(Nout); Nout = 10; end
if nargin < 2 || isempty(Nin);  Nin  = 10; end

% Check if input is a vector
if min(size(x)) > 1
    error('Input signal x must be a vector.')
else
    % Ensure x is a colum vector
    x = x(:);
end


%% WINDOWING 
% 
% 
% Dimensionality
N = numel(x);

% Reduce abrupt discontinuities at signal start and end, by fading in over
% number of samples specified by Nin and Nout.

% Create raised cosine windows for fade in and out
% -- ADD YOUR CODE HERE --------------------------------------------------
% Fade-in window (0 -> 1)
wIn = 0.5 * (1 - cos(pi * (0:Nin-1)' / Nin)); 
wOut = 0.5 * (1 + cos(pi * (0:Nout-1)' / Nout)); % Fade-out window (1 -> 0)

% Apply window
% Apply fade-in
x(1:Nin) = x(1:Nin) .* wIn; % For 1:Nin first values apply fade in window

% Apply fade-out
x(end-Nout+1:end) = x(end-Nout+1:end) .* wOut; % For last end-Nout+1:end values apply fade out window
