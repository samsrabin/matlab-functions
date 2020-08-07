function out_struct = lpjgu_convert_mapsmat_to_garray(in_file)

% Check that input file exists
if ~exist(in_file, 'file')
    error('Input file does not exist (%s', in_file)
end

% Get output file
if contains(in_file, '.maps.mat')
    out_file = strrep(in_file, '.maps.mat', '.garr.mat') ;
elseif contains(in_file, '.mat')
    out_file = strrep(in_file, '.mat', '.garr.mat') ;
    warning('Saving as %s', out_file) ;
else
    error('How to get output file name?')
end
if exist(out_file, 'file')
    warning('Output file exists! Skipping %s', out_file)
    return
end

% Read input file
fprintf('Reading %s...\n', in_file)
in_struct = lpjgu_matlab_readTable_then2map(in_file) ;

% Convert to garray structure
out_struct = lpjgu_convert_mapsstruct_to_garrstruct(in_struct) ;

% Save output file
fprintf('Saving %s...\n', out_file)
force_mat_save = true ;
verbose = false ;
lpjgu_matlab_save_to_matfile( ...
    out_struct, ...
    out_file, ...
    force_mat_save, ...
    verbose, verbose) ;

% % Test
% test_struct = lpjgu_matlab_read2geoArray(out_file, ...
%     'force_mat_save', false, ...
%     'force_mat_nosave', true) ;
% if in_ndims == 4
%     if ~isequaln(test_struct.maps_YXvy, in_struct.maps_YXvy)
%         error('Something went wrong!')
%     end
% elseif in_ndims == 3
%     if ~isequaln(test_struct.maps_YXv, in_struct.maps_YXv)
%         error('Something went wrong!')
%     end
% else
%     error('???')
% end

disp('Done!')


end