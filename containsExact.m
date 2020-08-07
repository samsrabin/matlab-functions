function TF = containsExact(STR,PATTERN,varargin)
%containsExact True if text begins and ends with pattern.
%   TF = containsExact(STR,PATTERN) returns 1 (true) if STR exactly matches
%   PATTERN, and returns 0 (false) otherwise. (Same as strcmp().)
%
%   STR can be a string array, a character vector, or a cell array of
%   character vectors. So can PATTERN. PATTERN and STR need not be the same
%   size. If PATTERN is a string array or cell array, then containsExact returns
%   true if STR matches any element of PATTERN. If STR is a string array
%   or cell array, then TF is a logical array that is the same size.
%
%   TF = containsExact(STR,PATTERN,'IgnoreCase',IGNORE) ignores case when searching
%   for PATTERN at the end of STR if IGNORE is true. The default value of IGNORE
%   is false.
%
%   Sam Rabin 2018. Modeled after builtin contains().

% Set up & parse input arguments
p = inputParser ;
addRequired(p,'STR') ;
addRequired(p,'PATTERN') ;
addParameter(p,'IgnoreCase',false) ;
parse(p,STR,PATTERN,varargin{:});

TF = false(size(STR)) ;
for i = 1:length(PATTERN)
    if p.Results.IgnoreCase
        TF(strcmpi(STR,PATTERN{i})) = true ;
    else
        TF(strcmp(STR,PATTERN{i})) = true ;
    end
end



end