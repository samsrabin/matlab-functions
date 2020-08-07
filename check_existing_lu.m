function check_existing_lu(...
    thisVer, out_file_lu, ...
    allVer_names, allVer_ignore_types)

thisInd = find(strcmp(allVer_names,thisVer)) ;
thisIgnore = allVer_ignore_types(thisInd) ;

if length(find(allVer_ignore_types==thisIgnore))>1
    matchThis_list = find(allVer_ignore_types==thisIgnore) ;
    matchThis_list(matchThis_list==thisInd) = [] ;
    for i = 1:length(matchThis_list)
        thisMatch = matchThis_list(i) ;
        tryThisName = allVer_names{thisMatch} ;
        tryThisOut = strrep(out_file_lu,thisVer,tryThisName) ;
        if exist(tryThisOut,'file') || exist([tryThisOut '.gz'],'file')
            error(['Nominally equivalent LU already exists; manually save if you really want to. At ' tryThisOut '(.gz)'])
        end
    end
end

end