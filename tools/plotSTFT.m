function h = plotSTFT(t,f,X,fs,bLog,DRdB)
%plotSTFT   Plot the STFT representation 
% 
%USAGE
%   h = plotSTFT(t,f,X,fs)
%   h = plotSTFT(t,f,X,fs,bLog,DRdB)
%
%INPUT ARGUMENTS
%      t : time vector in seconds [1 x L]
%      f : frequency vector in Hertz [M x 1]
%      X : complex STFT matrix [M x L]
%     fs : sampling frequency in Hertz
%   bLog : binary flag indicating if a logarithmic frequency axis should be
%          used (default, bLog = false)
%   DRdB : dynamic range of the spectrogram in dB (default, DRdB = 60)
%
%OUTPUT ARGUMENTS
%   h : figure handle
% 
%   plotSTFT(...) plots the STFT in a new figure.

%   Developed with Matlab 9.8.0.1451342 (R2020a) Update 5. Please send bug
%   reports to 
%
%   Author  :  Tobias May, © 2020
%              Technical University of Denmark
%              tobmay@.dtu.dk
%
%   History :
%   v.0.1   2020/09/15
%   ***********************************************************************


%% CHECK INPUT ARGUMENTS
%
%
% Check for proper input arguments
if nargin < 4 || nargin > 6
    help(mfilename);
    error('Wrong number of input arguments!')
end

% Set default values
if nargin < 5 || isempty(bLog); bLog = false; end
if nargin < 6 || isempty(DRdB); DRdB = 60;    end
    

%% PLOT SPECTROGRAM
% 
% 
% Spectrogram in dB
XdB = 20 * log10(abs(X));

% Select dynamic range
range = [max(XdB(:)) - DRdB max(XdB(:))];

% Select frequency scaling
if bLog
    % Logarithmic frequency grid
    fLogHz = 2.^(-20:20) * 1E3;
    fLogHz = fLogHz(fLogHz >= f(2) & fLogHz <= fs/2);
    
    % Show STFT with logarithmic frequency axis
    h = figure;
    pcolor(t,f,XdB);
    shading flat;
    % colormap(colormapVoicebox);
    colorbar;
    set(gca,'yscale','log','clim',range)
    set(gca,'ytick',fLogHz,'yticklabel',num2str(fLogHz'))
    ylim([0 fs/2])
    xlabel('Time (s)')
    ylabel('Frequency (Hz)')
    title('Logarithmic frequency axis')
else
    % Create fkHz frequency axis
    fkHz = f / 1e3;

    % Show STFT with linear frequency axis
    h = figure;
    imagesc(t(:)',fkHz(:),XdB,range);
    axis xy;
    % colormap(colormapVoicebox);
    colorbar;
    ylim([0 fs/2/1e3])   % adjust y-axis limits (in kHz now)
    xlabel('Time (s)')
    ylabel('Frequency (kHz)')
    title('Linear frequency axis')
end
