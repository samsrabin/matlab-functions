function output = yesorno(input)

switch input
    case 0
        output = 'no' ;
    case 1
        output = 'yes' ;
    otherwise
        error('Input must be either 0 or 1.')
end

end