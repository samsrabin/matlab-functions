function fullscreen_coords = fullscreen(varargin)
% This doesn't do anything except spit out the coordinates for a figure to
% be fullscreen.

if ~isempty(varargin)
    whichScreen = varargin{1} ;
else
    whichScreen = 'laptop' ;
end

if strcmp(whichScreen,'laptop')
    fullscreen_coords = [1 41 1440 764] ;
elseif strcmp(whichScreen,'external')
    fullscreen_coords = [1441 -123 1280 928] ;
else
    error(['whichScreen value "' whichScreen '" not recognized.'])
end

end