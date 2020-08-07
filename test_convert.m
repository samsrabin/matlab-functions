topDir = '/Users/Shared/PLUM/trunk_runs' ;
dirList = { ...
    'LPJGPLUM_1850-2010_remap6p7/output-2019-02-18-120851' ;
    'LPJGPLUM_2011-2100_harm3_SSP1_RCP45/output-2019-02-27-103914';
    'LPJGPLUM_2011-2100_harm3_SSP3_RCP60/output-2019-02-27-093027';
    'LPJGPLUM_2011-2100_harm3_SSP4_RCP60/output-2019-02-27-093259';
    'LPJGPLUM_2011-2100_harm3_SSP5_RCP85/output-2019-02-27-104120'
    } ;

file_names = {} ;
for d = 1:length(dirList)
    thisDir = sprintf('%s/%s', topDir, dirList{d}) ;
    files = dir(sprintf('%s/*.maps.mat', thisDir)) ;
    file_names = cat(1, file_names, strcat([thisDir '/'], {files.name}')) ;
    files = dir(sprintf('%s/first_decade.mat', thisDir)) ;
    if ~isempty(files)
        file_names = cat(1, file_names, strcat([thisDir '/'], {files.name}')) ;
    end
    files = dir(sprintf('%s/last_decade.mat', thisDir)) ;
    if ~isempty(files)
        file_names = cat(1, file_names, strcat([thisDir '/'], {files.name}')) ;
    end
    files = dir(sprintf('%s/last_*yrs.mat', thisDir)) ;
    if ~isempty(files)
        file_names = cat(1, file_names, strcat([thisDir '/'], {files.name}')) ;
    end
end
clear files d

for f = 1:length(file_names)
    fprintf('%d of %d...\n', f, length(file_names))
    thisFile = file_names{f} ;
    if contains(thisFile,'.maps.mat')
        lpjgu_convert_mapsmat_to_garray(thisFile) ;
    else
        
        % Get output file
        if contains(thisFile, '.maps.mat')
            out_file = strrep(in_file, '.maps.mat', '.garr.mat') ;
        elseif contains(thisFile, '.mat')
            out_file = strrep(thisFile, '.mat', '.garr.mat') ;
            warning('Saving as %s', out_file) ;
        else
            error('How to get output file name?')
        end
        if exist(out_file, 'file')
            warning('Output file exists! Skipping %s', out_file)
            continue
        end
        
        
        % Read input file
        fprintf('Reading %s...\n', thisFile)
        in_struct = load(thisFile) ;
        
        fields = fieldnames(in_struct) ;
        for ii = 1:length(fields)
            thisField = fields{ii} ;
            disp('Converting...')
            eval(sprintf( ...
                '%s = lpjgu_convert_mapsstruct_to_garrstruct(in_struct.%s) ;', ...
                thisField, thisField)) ;
            disp('Saving...')
            if ~exist(out_file, 'file')
                save(out_file, thisField, '-v7.3')
            else
                save(out_file, thisField, '-append')
            end
            eval(sprintf('clear %s', thisField))
            in_struct = rmfield(in_struct, thisField) ;
        end
        
        
        
    end
    disp(' ')
end
disp('All done!')
