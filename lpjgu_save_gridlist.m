function lpjgu_save_gridlist(lonlats, out_file, varargin)

% Set up & parse input arguments
is_ok_lonlats = @(x) isnumeric(lonlats) && ismatrix(lonlats) && size(lonlats, 2)==2 ;
p = inputParser ;
addRequired(p, 'lonlats', is_ok_lonlats) ;
addRequired(p, 'out_file', @ischar) ;
addOptional(p, 'out_formatSpec_gridlist', '%4.2f %4.2f\n', @ischar)
addOptional(p, 'do_randomize', true, @islogical)
parse(p, lonlats, out_file, varargin{:});

% Extract input arguments from p.Results
pFields = fieldnames(p.Results) ;
Nfields = length(pFields) ;
for f = 1:Nfields
    thisField = pFields{f} ;
    if ~exist(thisField,'var')
        eval(['global ' thisField ';']) ;
        eval([thisField ' = p.Results.' thisField ' ;']) ;
    end
    clear thisField
end ; clear f
clear p pFields

% Randomize order
if do_randomize
    rng(19870724) ;
    Ncells = size(lonlats, 1) ;
    rdmsam  = randsample(Ncells, Ncells) ;
    lonlats = lonlats(rdmsam,:) ;
end

% Save to file
fid = fopen(strrep(out_file, '\ ', ' '), 'w') ;
fprintf(fid, out_formatSpec_gridlist, lonlats') ;
fprintf(fid, '%s', '') ;  % Blank line
fclose(fid) ;

end