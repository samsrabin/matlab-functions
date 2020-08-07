function posCoords = figurePos(varargin)

if ~isempty(varargin)
    whichPos = varargin{1} ;
else
    whichPos = 'fs_laptop' ;
end

if strcmp(whichPos,'fullscreen') || strcmp(whichPos,'fs_laptop')
    posCoords = [1 41 1440 764] ;
elseif strcmp(whichPos,'fs_external')
    posCoords = [1441 -123 1280 928] ;
elseif strcmp(whichPos,'maps3x1')
    posCoords = [425    41   490   764] ;
elseif strcmp(whichPos,'maps2x1')
    posCoords = [721    42   720   763] ;
else
    error(['whichPos value "' whichPos '" not recognized.'])
end

end