function htext = letterlabel_align0(thisLetter,htitle,varargin)

do_caps = 0 ;
if ~isempty(varargin)
    do_caps = varargin{1} ;
end

% Set up current handles
htitle.Units = 'normalized' ;
htitle.Position(2) = 1.02 ;

% Force capital or lowercase, if doing so
if do_caps==-1
    thisLetter = lower(thisLetter) ;
elseif do_caps==1
    thisLetter = upper(thisLetter) ;
end

% Add label
thisLabel = ['(' thisLetter ')'] ;
htext = text(0,htitle.Position(2), ...
             thisLabel, ...
             'Units','normalized', ...
             'FontSize',htitle.FontSize, ...
             'FontWeight',htitle.FontWeight, ...
             'VerticalAlignment', htitle.VerticalAlignment) ;

end