function k = cellstrfind(in_cellstr,in_pattern,varargin)
% cellstrfind Find any occurrence of a string in a cell array of strings.
%     K = strfind(IN_CELLSTR,IN_PATTERN)
%         Returns indices of cells in IN_CELLSTR containing
%         IN_PATTERN.
%     K = strfind(IN_CELLSTR,IN_PATTERN,INCL)
%         If INCL==true (default), return matching cells. If
%         INCL==false, return non-matching cells.
%     Example
%         cellstrfind({'abc','def','bc','e'},'b') returns [1 3].
%
%     SSR 2016-12-02
%     Based on MATLAB function strfind and MATLAB Answer post
%     at https://www.mathworks.com/matlabcentral/answers/2015-find-index-of-cells-containing-my-string#answer_3240

% Set up input arguments
p = inputParser ;
addRequired(p,'in_cellstr',@iscellstr) ;
addRequired(p,'in_pattern',@ischar) ;
default_incl = true ;
addOptional(p,'incl',default_incl,@islogical) ;
default_indices = false ;
addOptional(p,'indices',default_indices,@islogical) ;
parse(p,in_cellstr,in_pattern,varargin{:});
pr = p.Results ;

% Do it
kC = strfind(in_cellstr,in_pattern) ;
if pr.incl
    k = not(cellfun('isempty',kC)) ;
else
    k = cellfun('isempty',kC) ;
end
if ~pr.indices
    k = find(k) ;
end



end