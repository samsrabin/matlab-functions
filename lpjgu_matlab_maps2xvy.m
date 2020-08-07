function [out_array, list2map] = lpjgu_matlab_maps2xvy(in_maps, varargin)

list2map = [] ;
if ~isempty(varargin)
    if length(varargin) > 1
        error('At most one optional argument (list2map)')
    end
    list2map = varargin{1} ;
end

if ndims(in_maps)==3 || ndims(in_maps)==4
    if isempty(list2map)
        ok_YX = ~isnan(mean(mean(in_maps,4),3)) ;
        list2map = find(ok_YX) ;
    end
    in_maps_size = size(in_maps) ;
    Nvars = size(in_maps,3) ;
    Nyears = size(in_maps,4) ;
    out_array = reshape(in_maps,[prod(in_maps_size(1:2)) Nvars Nyears]) ;
    out_array = out_array(list2map,:,:) ;
else
    error('in_maps must have either 3 or 4 dimensions!')
end


end