function varargout = gridlist_to_map(xres,yres,in_file,varargin)

warning('gridlist_to_map() not updated to include lat_extent or lat_orient as fields of out_struct')

force_struct = false ;
if isempty(varargin)
    disp('Assuming in_file is the gridlist to be mapped, and that Col1=Lon and Col2=Lat.')
elseif ~ischar(varargin{1})
    disp('Checking lat/lon lists...')
    table1 = varargin{1} ;
    table1_latlon = [table1.Lat table1.Lon] ;
    disp(['   ' inputname(3)])
    if length(varargin) > 1
        for n = 2:length(varargin)
            tableN = varargin{n} ;
            disp(['   ' inputname(2+n)])
            if ~isequal(table1_latlon, [tableN.Lat tableN.Lon])
                error('Input tables do not have the same lat/lon lists.')
            end
        end
    end
elseif ischar(varargin{1})
    if strcmp(varargin{1},'struct')
        force_struct = true ;
        disp('Assuming in_file is the gridlist to be mapped, and that Col1=Lon and Col2=Lat.')
    else
        error('If char, varargin{1} can only be ''struct''.')
    end
end
varargin_saved = varargin ;

% Get filename parts
[~,NAME,EXT] = fileparts(in_file) ;
disp([NAME EXT ':'])

in_matfile = [in_file '.maps.mat'] ;

if ~exist(in_matfile,'file')
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Get indices, assuming all input tables have same %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if ~isempty(varargin)
        in_table = varargin{1} ;
    else
        in_table = readtable(in_file) ;
        while ~any(~isnan(table2array(in_table(:,end))))
            in_table(:,end) = [] ;
        end
        if size(in_table,2)~=2
            error('in_file must have two columns: Lat and Lon.')
        end
        in_table.Properties.VariableNames = {'Lon','Lat'} ;
    end
    
    in_lons = in_table.Lon ;
    in_lats = in_table.Lat ;
    in_Ncells = length(in_lats) ;
    
    % Extract one-year lats/lons, if necessary
    colNames = in_table.Properties.VariableNames ;
    multi_yrs = false ;
    for c = 1:length(colNames)
        thisName = colNames{c} ;
        if strcmp(thisName,'Year') && length(unique(in_table.Year))>1
            multi_yrs = true ;
        end
    end
    if multi_yrs
        in_years = in_table.Year ;
        in_lons = in_lons(in_years==min(in_years)) ;
        in_lats = in_lats(in_years==min(in_years)) ;
        in_Ncells = length(in_lats) ;
    end
    
    % Set up maps
    lon_min = -180 ;
    lat_min = -90 ;
    lon_max = 180-xres ;
    lat_max = 90-yres ;
    if rem(in_lons(1)*100,50)~=0
        if 100*xres/2 ~= abs(rem(in_lons(1)*100,50))
            error('How do I deal with this orientation (lon.)?')
        end
        lon_min = lon_min + xres/2 ;
        lon_max = lon_max + xres/2 ;
    end
    if rem(in_lats(1)*100,50)~=0
        if 100*yres/2 ~= abs(rem(in_lats(1)*100,50))
            error('How do I deal with this orientation (lat.)?')
        end
        lat_min = lat_min + yres/2 ;
        lat_max = lat_max + yres/2 ;
    end
    lons = lon_min:xres:lon_max ;
    lats = lat_min:yres:lat_max ;
    lons_map = repmat(lons,[length(lats) 1]) ;
    lats_map = repmat(lats',[1 length(lons)]) ;
    
    disp('   Getting indices to convert list to map...')
    list_to_map = nan(in_Ncells,1) ;
    found = true(size(list_to_map)) ;
    progress = 0 ;
    progress_step_pct = 25 ;
    tic ;
    for c = 1:in_Ncells
        thisIndex = find(lats_map==in_lats(c) & lons_map==in_lons(c)) ;
        if ~isempty(thisIndex)
            list_to_map(c) = thisIndex ;
        else
            found(c) = false ;
            if length(find(~found))==1
                warning(['Some cells from input are getting ignored '...
                         'at output resolution ' num2str(xres) ' lon. x'...
                         num2str(yres) ' lat.'])
            end
        end
        
        % Update progress
        if rem(c,ceil(in_Ncells*progress_step_pct/100))==0
            progress = progress + progress_step_pct ;
            disp(['      ' num2str(progress) '% complete (' toc_hms(toc) ')'])
        end
    end
    
    % There should be at least one cell mapped!
    if ~any(~isnan(list_to_map))
        error('Something went badly wrong.')
    end
    
    % Deal with skipped cells
    list_to_map(~found) = [] ;
    in_Ncells = length(find(found)) ;
    
    % Sanity checks
    if any(isnan(list_to_map))
        error('Somehow list_to_map contains NaN.')
    end
    if length(list_to_map) ~= in_Ncells
        error('length(list_to_map) ~= in_Ncells')
    end
        
    %%%%%%%%%%%%%%%%%
    %%% Make maps %%%
    %%%%%%%%%%%%%%%%%
    
    disp('   Converting list to maps...')
    
    if isempty(varargin)
        out_map = zeros(length(lats),length(lons)) ;
        out_map(list_to_map) = 1 ;
        out_data.map_YX = out_map ;
        out_data.lons = in_lons ;
        out_data.lats = in_lats ;
        varargout{1} = out_data ;
    else   % if length(varargin==1)
        for i = 1:length(varargin_saved)
            
            %         disp(['   ' inputname(2+i) '...'])
            in_table = varargin_saved{i} ;
            
            % Get names of variables other than Lat, Lon, and Year
            colNames = in_table.Properties.VariableNames ;
            varNames = {} ;
            multi_yrs = false ;
            for c = 1:length(colNames)
                thisName = colNames{c} ;
                if ~(strcmp(thisName,'Lat') || strcmp(thisName,'Lon') || strcmp(thisName,'Year'))
                    varNames{end+1} = thisName ;
                elseif strcmp(thisName,'Year')
                    in_years = in_table.Year ;
                    if length(unique(in_years))>1
                        multi_yrs = true ;
                        yearList = unique(in_years) ;
                        Nyears = length(yearList) ;
                    end
                end
            end
            Nvars = length(varNames) ;
            
            % Convert list to maps
            if multi_yrs
                maps_YXvy = nan(length(lats),length(lons),Nvars,Nyears) ;
            else
                maps_YXv = nan(length(lats),length(lons),Nvars) ;
            end
            for v = 1:Nvars
                thisVar = varNames{v} ;
                disp(thisVar)
                if multi_yrs
                    for y = 1:Nyears
                        thisYear = yearList(y) ;
                        tmp = nan(length(lats),length(lons)) ;
                        tmp(list_to_map) = table2array(in_table(in_years==thisYear,thisVar)) ;
                        maps_YXvy(:,:,v,y) = tmp ;
                    end
                else
                    tmp = nan(length(lats),length(lons)) ;
                    %                 tmp(list_to_map) = table2array(in_table(:,thisVar)) ;
                    tmp(list_to_map) = table2array(in_table(found,thisVar)) ;
                    maps_YXv(:,:,v) = tmp ;
                end
            end
            
            % Save output structure
            out_struct.list_to_map = list_to_map ;
            out_struct.varNames = varNames ;
            if multi_yrs
                out_struct.maps_YXvy = maps_YXvy ;
                out_struct.yearList = yearList ;
            else
                out_struct.maps_YXv = maps_YXv ;
            end
            varargout{i} = out_struct ;
            
        end
    end
    
    % Ask to save to MAT-file
    ok = false ;
%     while ~ok
%         str = input('   Save to MAT-file? Y or N: ','s') ;
%         if strcmp(str,'y') || strcmp(str,'Y')
%             ok = true ;
%             disp('   Saving MAT-file...')
%             save(in_matfile,'varargout') ;
%         elseif strcmp(str,'n') || strcmp(str,'N')
%             ok = true ;
%         end
%     end
    while ~ok
        if exist(in_matfile,'file')
            disp('   Save, overwriting existing MAT-file? Y or [N]. 10 seconds...')
            default_save = false ;
        else
            disp('   Save to MAT-file? [Y] or N. 10 seconds...')
            default_save = true ;
        end
        dbl = getkeywait_ssr(10) ;
        if (dbl==-1 && default_save) || strcmp(char(dbl),'y') || strcmp(char(dbl),'Y')
            ok = true ;
            disp('   Saving MAT-file...')
            save(in_matfile,'varargout') ;
        elseif (dbl==-1 && ~default_save) || strcmp(char(dbl),'n') || strcmp(char(dbl),'N')
            ok = true ;
        else
            warning(['   Input (' char(dbl) ') not recognized.'])
        end
    end ; clear ok
    
else
    disp('   Loading from MAT-file...')
    load(in_matfile) ;
    varargout{1} = out_struct ;
end

disp('   Done.')


end