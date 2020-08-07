function h = shademap_garr(garr_x, list2map, varargin)

% Process optional inputs
dims = [360 720] ;
if ~isempty(varargin)
    dims = varargin{1} ;
    if length(varargin)>1
        error('At most one optional variable is accepted (dims)')
    end
end

% Error checks
if length(dims) ~= 2
    error('dims must have 2 elements')
elseif any(~isint(dims))
    error('Elements of dims must both be integers')
elseif length(garr_x) ~= length(list2map)
    error('garr_x and list2map must be the same size!')
end

% Do shademap
tmp_YX = nan(dims) ;
tmp_YX(list2map) = garr_x ;
h = shademap(tmp_YX) ;


end