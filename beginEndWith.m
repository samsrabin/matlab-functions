function TF = beginEndWith(STR,PATTERN,varargin)
%beginEndWith True if text begins and ends with pattern.
%   TF = matches(STR,PATTERN) returns 1 (true) if STR ends with PATTERN,
%   and returns 0 (false) otherwise.
%
%   STR can be a string array, a character vector, or a cell array of
%   character vectors. So can PATTERN. PATTERN and STR need not be the same
%   size. If PATTERN is a string array or cell array, then matches returns
%   true if STR begins and ends with any element of PATTERN. If STR is a string array
%   or cell array, then TF is a logical array that is the same size.
%
%   TF = matches(STR,PATTERN,'IgnoreCase',IGNORE) ignores case when searching 
%   for PATTERN at the beginning and end of STR if IGNORE is true. The default value of IGNORE 
%   is false.
%
%   Sam Rabin 2018. Modeled after builtin endsWith().

% Set up & parse input arguments
p = inputParser ;
addRequired(p,'STR') ;
addRequired(p,'PATTERN') ;
addParameter(p,'IgnoreCase',false) ;
parse(p,STR,PATTERN,varargin{:});

TF_1 = startsWith(STR,PATTERN,'IgnoreCase',p.IgnoreCase) ;
TF_2 = endsWith(STR,PATTERN,'IgnoreCase',p.IgnoreCase) ;
TF = TF_1 & TF_2 ;


end