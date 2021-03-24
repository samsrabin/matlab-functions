function thisSystem = get_system_name()

if ispc
    homedir = getenv('USERPROFILE') ;
else
    homedir = getenv('HOME') ;
end

switch homedir
    case {'/Users/sam'}
        thisSystem = 'ssr_mac' ;
    case {'/home/rabin-s'}
        thisSystem = 'ssr_keal' ;
    case {'/home/kit/imk-ifu/lr8247'}
        thisCluster = getenv('CLUSTER') ;
        switch thisCluster
            case {'uc2'}
                thisSystem = 'ssr_uc2' ;
            case ''
                error('CLUSTER variable not set')
            otherwise
                error('thisSystem not recognized; home folder %s, CLUSTER %s not recognized', ...
                    homedir, thisCluster)
        end
    otherwise
        error('thisSystem not recognized; home folder %s', homedir)
end

end