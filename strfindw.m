function [idx] = strfindw(array, expStr)
% Based on https://de.mathworks.com/matlabcentral/fileexchange/30828-wildcard-string-find?focused=5180126&tab=function

regStr = ['^',strrep(strrep(expStr,'?','.'),'*','.{0,}'),'$'];
starts = regexp(array, regStr);
iMatch = ~cellfun(@isempty, starts);
idx=iMatch;% idx = find(iMatch);
