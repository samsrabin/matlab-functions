function value = get_ins_value(filename, parameter, required)

if ~exist(filename, 'file')
	error('Can''t find ins-file "%s"', filename)
end
F = dir(filename) ;
thisDir = F.folder ;

% % Troubleshooting
% disp(parameter)

% Call factorial function
value = doit(thisDir, filename, parameter, '') ;

% Error if not found
if required && isempty(value)
	error('%s not found in ins-files', parameter)
end

end


function value = doit(thisDir, filename, parameter, value)

% % Troubleshooting
% tmp = dir(filename) ;
% fprintf('%s: Checking %s\n', parameter, tmp.name)

% Read this file
str = fileread(filename) ;

% Loop through ins-files called by this ins-file
C = regexp(str, '\n\s*import [^\n]+', 'match') ;
if ~isempty(C)
    for f = 1:length(C)
        imported_file = strrep(regexp(C{f}, '"\S+"', 'match'), '"', '') ;
        imported_file = sprintf('%s/%s', thisDir, imported_file{1}) ;
        value = doit(thisDir, imported_file, parameter, value) ;
    end
end

% Get the value from this file
thisfile_value = '' ;
C = regexp(str, ['\n\s*' parameter '\s+[^\n!]+'], 'match') ;
if ~isempty(C)
    C = C{end} ;
    C2 = regexp(C, [parameter '\s+(\S+)'], 'tokens') ;
    if length(C2) ~= 1
        error('length(value) ~= 1')
    end
    thisfile_value = C2{1}{1} 
else
    C = regexp(str, ['\n\s*param "' parameter '"[^\n!]+'], 'match') ;
    if ~isempty(C)
        C = C{end} ;
        C2 = regexp(C, 'str "(.*)"', 'tokens') ;
        if length(C2) ~= 1
            error('length(value) ~= 1')
        end
        thisfile_value = C2{1}{1} ; 
    end
end

if ~isempty(thisfile_value)
	value = thisfile_value ;
end

%% Troubleshooting
%fprintf('   %s: %s\n', filename, value)

end
