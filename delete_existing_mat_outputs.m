function delete_existing_mat_outputs(filename)

suffix_list = { ...
    '.mat' ;
    '.maps.mat' ;
    '.garr.mat' ;
    } ;
Nsuffices = length(suffix_list) ;

for s = 1: Nsuffices
    this_suffix = suffix_list{s} ;
    mat_filename = [filename this_suffix] ;
    if exist(mat_filename, 'file')
        try
            fprintf('Deleting existing %s\n', mat_filename)
            delete(mat_filename)
        catch
            warning( ...
                ['Unable to delete existing %s. MATLAB may try to read that instead ' ...
                 'of the new %s that we''re writing now.'], ...
                 mat_filename, filename)
        end
    end
end