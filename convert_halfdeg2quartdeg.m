function outMap = convert_halfdeg2quartdeg(inMap)

inMap_size = size(inMap) ;
if length(inMap_size) == 2
    inMap_size(3) = 1 ;
end

if isequal(inMap_size(1:2),[360 720])
    tmp = nan(360,1440,inMap_size(3)) ;
    tmp(:,1:2:1440,:) = inMap ;
    tmp(:,2:2:1440,:) = inMap ;
    outMap = nan(720,1440,inMap_size(3)) ;
    outMap(1:2:720,:,:) = tmp ;
    outMap(2:2:720,:,:) = tmp ;
elseif isequal(inMap_size(1:2),[720 360])
    tmp = nan(1440,360,inMap_size(3)) ;
    tmp(1:2:1440,:,:) = inMap ;
    tmp(2:2:1440,:,:) = inMap ;
    outMap = nan(1440,720,inMap_size(3)) ;
    outMap(:,1:2:720,:) = tmp ;
    outMap(:,2:2:720,:) = tmp ;
else error('First 2 dims must be [360,720] or [720,360].')
end