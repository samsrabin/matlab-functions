function [ output ] = isint( input , varargin )
%ISINT Checks whether input is (are) integer(s), returning logical values.
%   ISINT(A) checks whether A (or each element in A if A is an array) is an integer.
%   ISINT(A,{['each'] 'all'}) checks whether each element (default) or all elements in A are integers
%
% By Sam Rabin
%
%

% Help from http://blogs.mathworks.com/loren/2009/05/12/optional-arguments-using-empty-as-placeholder/

% Only want 1 optional inputs at most
numvarargs = length(varargin);
if numvarargs > 1
    error('myfuns:somefun2Alt:TooManyInputs', ...
        'Only one optional input (mode)');
end

% Set defaults for optional inputs
optargs = {'each'};

% Skip any new inputs if they are empty
newVals = cellfun(@(x) ~isempty(x), varargin);

% Now put these defaults into the valuesToUse cell array, 
% and overwrite the ones specified in varargin.
[optargs{1:numvarargs}] = varargin{:};

% Place optional args in memorable variable names
[mode] = optargs{:};

output = rem(input,1) ;

if strcmp(mode,'all') == 1
    output = sum(output) ;
    if output == 0
        output = true ;
    else
        output = false ;
    end
else
    if output == 0
        output = true(size(input)) ;
    else
        output(output ~= 0) = 99 ;
        output(output == 0) = true ;
        output(output == 99) = false ;
    end
end


end