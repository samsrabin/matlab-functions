function value = get_ins_value(filename, parameter)

F = dir(filename) ;
thisDir = F.folder ;
value = '' ;

% Read this file
str = fileread(filename) ;

% Loop through ins-files called by this ins-file
C = regexp(str, '\n\s*import [^\n]+', 'match') ;
if ~isempty(C)
    for f = 1:length(C)
        imported_file = strrep(regexp(C{f}, '"\S+"', 'match'), '"', '') ;
        imported_file = sprintf('%s/%s', thisDir, imported_file{1}) ;
        imported_value = get_ins_value(imported_file, parameter) ;
    end
    if ~isempty(imported_value)
        value = imported_value ;
    end
end

% Get the value from this file
C = regexp(str, ['\n\s*' parameter '\s+[^\n!]+'], 'match') ;
if ~isempty(C)
    C = C{end} ;
    C2 = regexp(C, [parameter '\s+(\S+)'], 'tokens') ;
    if length(C2) ~= 1
        error('length(value) ~= 1')
    end
    value = C2{1}{1} ;
else
    C = regexp(str, ['\n\s*param "' parameter '"[^\n!]+'], 'match') ;
    if ~isempty(C)
        C = C{end} ;
        C2 = regexp(C, 'str "(.*)"', 'tokens') ;
        if length(C2) ~= 1
            error('length(value) ~= 1')
        end
        value = C2{1}{1} ;
    end
end

end