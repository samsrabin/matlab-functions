function lpjgu_gmap_some(map_struct,varargin)

% Set up input arguments
p = inputParser ;
addRequired(p,'map_struct',@isstruct) ;
default_specified = map_struct.varNames ;
% Variables to plot. Default all.
addParameter(p,'specified',default_specified,@iscellstr) ;
% Year ranges to average over. Default all.
default_yearRanges = {[min(map_struct.yearList) max(map_struct.yearList)]} ;
addParameter(p,'yearRanges',default_yearRanges,@iscell) ;
% Prefix for output files, including path. Default empty.
default_outPrefix = '' ;
addParameter(p,'outPrefix',default_outPrefix,@ischar) ;
% Extension for output files. Default .png.
default_extension = '.png' ;
addParameter(p,'extension',default_extension,@ischar) ;
% Make caxis the same for all maps in a given year range? Default no.
default_caxisByYearRange = false ;
addParameter(p,'caxisByYearRange',default_caxisByYearRange,@islogical) ;
% Make caxis the same for all maps of a given variable? Default no.
default_caxisByVar = false ;
addParameter(p,'caxisByVar',default_caxisByVar,@islogical) ;
% Overwrite (1), ask (0), or skip (-1)?
default_overwrite = 0 ;
addParameter(p,'overwrite',default_overwrite,...
    @(x) isint(x) & x>=-1 & x<=1) ;

% Parse inputs
parse(p,map_struct,varargin{:});
if ~strcmp(p.Results.extension(1),'.')
    p.Results.extension = ['.' p.Results.extension] ;
end
Nvars = length(p.Results.specified) ;
NyrRanges = length(p.Results.yearRanges) ;

% Make map for each of the specified variables
maps_YXvy = nan([size(map_struct.maps_YXvy(:,:,1,1)) Nvars NyrRanges]) ;
yearRangeStr_list = {} ;
skip_this = false(NyrRanges,1) ;
for y = 1:NyrRanges
    thisYearRange = p.Results.yearRanges{y} ;
    if ~isnumeric(thisYearRange) || ~isequal(size(thisYearRange),[1 2])
        error('Year ranges must be 1x2 numeric arrays.')
    end
    y1 = min(thisYearRange) ;
    yN = max(thisYearRange) ;
    if ~any(map_struct.yearList==y1) && any(map_struct.yearList==yN)
        warning([num2str(y1) ' is before beginning of map_struct.yearList. Starting at ' num2str(min(map_struct.yearList)) ' instead.'])
        y1 = min(map_struct.yearList) ;
    elseif any(map_struct.yearList==y1) && ~any(map_struct.yearList==yN)
        warning([num2str(yN) ' is after end of map_struct.yearList. Ending at ' num2str(max(map_struct.yearList)) ' instead.'])
        yN = max(map_struct.yearList) ;
    elseif ~any(map_struct.yearList==y1) && ~any(map_struct.yearList==yN)
        warning(['Year range ' num2str(y1) '-' num2str(yN) ' is not in map_struct.yearList (' num2str(min(map_struct.yearList)) '-' num2str(max(map_struct.yearList)) '). Skipping.'])
        skip_this(y) = true ;
        continue
    end
    maps_YXv = mean(map_struct.maps_YXvy(:,:,:,...
        map_struct.yearList>=y1 & map_struct.yearList<=yN),4) ;
    if y1==yN
        yearRangeStr = num2str(y1) ;
    else
        yearRangeStr = [num2str(y1) '-' num2str(yN)] ;
    end
    yearRangeStr_list{y} = yearRangeStr ;
    for v = 1:Nvars
        thisVar = p.Results.specified{v} ;
        if ~any(strcmp(map_struct.varNames,thisVar))
            warning(['      ' map_struct ' not found in map_struct.varNames; skipping.'])
            continue
        end
        maps_YXvy(:,:,v,y) = maps_YXv(:,:,strcmp(map_struct.varNames,thisVar)) ;
    end
end

% Get overall caxis, if needed
newCaxis = [] ;
if p.Results.caxisByYearRange && p.Results.caxisByVar
    newCaxis = [min(maps_YXvy(~isnan(maps_YXvy))) max(maps_YXvy(~isnan(maps_YXvy)))] ;
end

% Plot and save map of each of specified variables
if any(~skip_this)
    disp('Plotting...')
    for y = 1:NyrRanges
        if skip_this(y)
            continue
        end
        disp([yearRangeStr_list{y} '...'])
        clear_newCaxis = false ;
        if p.Results.caxisByYearRange && ~p.Results.caxisByVar
            tmp = maps_YXvy(:,:,:,y) ;
            newCaxis = [min(tmp(~isnan(tmp))) max(tmp(~isnan(tmp)))] ;
            clear_newCaxis = true ;
        end
        for v = 1:Nvars
            thisVar = p.Results.specified{v} ;
            % Check for existence of output file
            outFile = [p.Results.outPrefix thisVar '.' yearRangeStr_list{y} p.Results.extension] ;
            if exist(outFile,'file')
                if p.Results.overwrite==-1
                    warning(['   Skipping ' thisVar ' because outFile exists.'])
                    continue
                elseif p.Results.overwrite==1
                    warning(['   Overwriting existing outFile for ' thisVar '.'])
                elseif p.Results.overwrite==0
                    ok = false ;
                    do_overwrite = false ;
                    while ~ok
                        disp('   Save, overwriting existing outFile? Y or [N]. 10 seconds...')
                        dbl = getkeywait_ssr(10) ;
                        if strcmp(char(dbl),'y') || strcmp(char(dbl),'Y')
                            ok = true ;
                            do_overwrite = true ;
                        elseif dbl==-1 || strcmp(char(dbl),'n') || strcmp(char(dbl),'N')
                            ok = true ;
                        else
                            warning(['Input (' char(dbl) ') not recognized.'])
                        end
                    end ; clear ok
                    if ~do_overwrite
                        continue
                    end
                end
            end
            if ~any(strcmp(map_struct.varNames,thisVar))
                warning(['      ' map_struct ' not found in map_struct.varNames; skipping.'])
                continue
            end
            disp(['      ' thisVar '...'])
            if ~p.Results.caxisByYearRange && p.Results.caxisByVar
                tmp = maps_YXvy(:,:,v,:) ;
                newCaxis = [min(tmp(~isnan(tmp))) max(tmp(~isnan(tmp)))] ;
            end
            clear_newCaxis = false ;
            if isempty(newCaxis)
                clear_newCaxis = true ;
                tmp = maps_YXvy(:,:,v,y) ;
                newCaxis = [min(tmp(~isnan(tmp))) max(tmp(~isnan(tmp)))] ;
            end
            thisTitle = [thisVar ' (' yearRangeStr_list{y} ')'] ;
            if isempty(newCaxis) % If STILL empty
                warning([thisTitle ' is all NaN; skipping.'])
            else
                lpjgu_gmap(maps_YXvy(:,:,v,y),...
                    'title',thisTitle,...
                    'outFile',outFile,...
                    'caxis',newCaxis)
            end
            if clear_newCaxis
                newCaxis = [] ;
            end
        end
        if clear_newCaxis
            newCaxis = [] ;
        end
    end
end
disp('Done.')