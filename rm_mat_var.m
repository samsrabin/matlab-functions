function rm_mat_var(filename, varargin)
%RMVAR  Remove variable from MAT-File
%   RMVAR FILENAME VAR1 VAR2... removes the variables VAR1, VAR2... from
%   the Mat-File FILENAME. If FILENAME has no extension RMVAR looks for
%   FILENAME.mat
%
%   RMVAR('Filename','VAR1','VAR2' ...) does the same.
%
%   Example:
%      % Creates a file 'myfile.mat' containing 2 variables:
%      a='hello';
%      b=magic(3);
%      save myfile.mat a b
%      % Removes the variable 'a' and opens the result
%      clear
%      rmvar myfile a
%      load myfile
%      whos
%
%   F. Moisy
%   Revision: 1.00,  Date: 2008/03/31.
%
%   See also LOAD, SAVE.

% History:
% 2008/03/31: v1.00, first version.
% SSR incorporated Leo Simon's suggestion from 2014-07-20
% SSR changed nargchk() to narginchk(), strmatch() to strcmp(), strvcat()
% to char(), isempty() to ~any()

narginchk(2,inf) ;
WHOS = whos('-file',filename);
removeThese = {};
for ii=1:numel(varargin);
    if ~any(strcmp({WHOS(:).name},varargin{ii}))
        disp([ varargin{ii} ' isn''t saved in ' filename ])
    else
        removeThese = [ removeThese , varargin{ii} ];
    end;
end;
vars = rmfield(load(filename),removeThese);
save(filename,'-struct','vars');
