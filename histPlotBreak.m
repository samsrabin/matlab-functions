function b = histPlotBreak( data , break_start , break_end , varargin)

% histPlotBreak Produces a histogram whose y-axis skips to avoid unecessary
% blank space

% USAGE
%  figure
%  histPlotBreak(data , break_start , break_end, ...
%               [break_type , topYscale , numBins])
% 
% INPUT ARGUMENTS
%   data          The data to be made into a histogram. (Vector.)
%   break_start
%   break_end
%   break_type    (Optional.) What should the break look like? Options:
%                   'Neat': A regular, zig-zag tear. (Default.)
%                   'Messy': More irregularly torn.
%                   
%   topYscale     (Optional.) Between 0-1; the % of max Y value that needs
%                 to be subtracted from the max value bars.
%   numBins       (Optional.) The number of bins to be used for the
%                 histogram. Default = 10.

% USAGE:
% figure
% BarPlotBreak([10,40,1000], 50, 60, 'Messy', 0.85);
%
% ACKNOWLEDGEMENTS
%   Almost entirely based on BarPlotBreak by Chintan Patel, which can be
%   found at http://www.mathworks.com/matlabcentral/fileexchange/14308.
%
%   Some modifications made by Sam Rabin (sam.rabin@gmail.com):
%    - Generates histograms instead of regular bar plots.
%    - Doesn't always set break_type to 'Neat' (see line 56 of
%      BarPlotBreak, which calls this 'Patch'). 
%    - Miscellaneous cleanup of help and code.

disp(varargin)

% Add default values
if length(varargin)==3 ; numBins=varargin{3} ; topYscale=varargin{2} ; break_type=varargin{1} ;
elseif length(varargin)==2 ; numBins=10 ; topYscale=varargin{2} ; break_type=varargin{1} ;
elseif length(varargin)==1 ; numBins=10 ; topYscale=0 ; break_type=varargin{1} ;
elseif isempty(varargin) ; numBins=10 ; topYscale=0 ; break_type='Neat' ;
else error('Number of optional arguments must be between 0 and 3.')
end

% Change things that I haven't fixed yet
% if topYscale~=0 ; topYscale=0 ; warning('Ignoring "topYscale"...') ; end

% Check validity of input
if min(size(data))~=1 ; error('Data must be in a vector.') ; end
if ~strcmp(break_type,'Neat') && ~strcmp(break_type,'Messy') ; error('break_type improperly specified.') ; end

% Calculate break midpoint
break_mid   = (break_end-break_start)./2+break_start;

% Generate histogram data
[Y,binCenters] = hist(data,numBins) ;

% topYscale data that are above the break
Y2 = Y ;
Y2(Y2>=break_end)=Y2(Y2>=break_end)-(Y2(Y2>=break_end)*topYscale);

% Plot data
% bar(binCenters , Y2 , 1) ;
bar(Y2 , 1) ;

xlim=get(gca,'xlim');
ytick=get(gca,'YTick');
[~,i]=min(ytick<=break_start);
y=(ytick(i)-ytick(i-1))./2+ytick(i-1);
dy=(ytick(2)-ytick(1))./10;
xtick=get(gca,'XTick');
x=xtick(1);
dx=(xtick(2)-xtick(1))./2;
switch break_type
    case 'Neat',
		% this can be vectorized
        dx=(xlim(2)-xlim(1))./10;
        yy=repmat([y-2.*dy y-dy],1,6);
        xx=xlim(1)+dx.*[0:11];
		patch([xx(:);flipud(xx(:))], ...
            [yy(:);flipud(yy(:)-2.*dy)], ...
            [.8 .8 .8])
    case 'Messy',
		% this can be vectorized
        dx=(xlim(2)-xlim(1))./100;
        yy=y+rand(101,1).*2.*dy;
        xx=xlim(1)+dx.*(0:100);
		patch([xx(:);flipud(xx(:))], ...
            [yy(:);flipud(yy(:)-2.*dy)], ...
            [.8 .8 .8])
end;

%ytick(ytick>break_start)=ytick(ytick>break_start)+break_mid;

ytick(ytick>break_start)=ytick(ytick>break_start)+(Y(Y>=break_end)*topYscale);

for i=1:length(ytick)
   yticklabel{i}=sprintf('%d',ytick(i));
end;
set(gca,'yticklabel',yticklabel);