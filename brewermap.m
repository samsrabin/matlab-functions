function [map,num,typ] = brewermap(N,scheme)
% The complete selection of ColorBrewer colorschemes (RGB colormaps).
%
% (c) 2015 Stephen Cobeldick
%
% Returns any RGB colormap from the ColorBrewer colorschemes, especially
% intended for mapping and plots with attractive, distinguishable colors.
%
% Syntax (basic):
%  map = brewermap(N,scheme); % Select colormap length, select any colorscheme.
%  brewermap('demo')          % View a figure showing all ColorBrewer colorschemes.
%  schemes = brewermap('list')% Return a list of all ColorBrewer colorschemes.
%  [map,num,typ] = brewermap(...); % The current colorscheme's number of nodes and type.
%
% Syntax (preselect colorscheme):
%  old = brewermap(scheme); % Preselect any colorscheme, return the previous scheme.
%  map = brewermap(N);      % Use preselected scheme, select colormap length.
%  map = brewermap;         % Use preselected scheme, length same as current figure's colormap.
%
% This product includes color specifications and designs developed by Cynthia Brewer.
% See the ColorBrewer website for further information about each colorscheme,
% colour-blind suitability, licensing, and citations: http://colorbrewer.org/
%
% See also CUBEHELIX RGBPLOT3 RGBPLOT COLORMAP COLORBAR PLOT PLOT3 SURF IMAGE AXES SET JET LBMAP PARULA
%
% ### Color Schemes ###
%
% To reverse the colormap sequence simply prefix the string token with '*'.
%
% Each colorscheme is defined by a set of hand-picked RGB values (nodes).
% If <N> is greater than the requested colorscheme's number of nodes then:
%  * Sequential and Diverging schemes are interpolated to give larger colormaps.
%  * Qualitative schemes throw an error.
% Else:
%  * Exact values from the ColorBrewer sequences are returned for all schemes.
%
% # Diverging #
%
% Scheme|'BrBG'|'PRGn'|'PiYG'|'PuOr'|'RdBu'|'RdGy'|'RdYlBu'|'RdYlGn'|'Spectral'|
% ------|------|------|------|------|------|------|--------|--------|----------|
% Nodes |  11  |  11  |  11  |  11  |  11  |  11  |   11   |   11   |    11    |
%
% # Qualitative #
%
% Scheme|'Accent'|'Dark2'|'Paired'|'Pastel1'|'Pastel2'|'Set1'|'Set2'|'Set3'|
% ------|--------|-------|--------|---------|---------|------|------|------|
% Nodes |   8    |   8   |   12   |    9    |    8    |   9  |  8   |  12  |
%
% # Sequential #
%
% Scheme|'Blues'|'BuGn'|'BuPu'|'GnBu'|'Greens'|'Greys'|'OrRd'|'Oranges'|'PuBu'|
% ------|-------|------|------|------|--------|-------|------|---------|------|
% Nodes |   9   |  9   |  9   |  9   |   9    |   9   |  9   |    9    |  9   |
%
% Scheme|'PuBuGn'|'PuRd'|'Purples'|'RdPu'|'Reds'|'YlGn'|'YlGnBu'|'YlOrBr'|'YlOrRd'|
% ------|--------|------|---------|------|------|------|--------|--------|--------|
% Nodes |   9    |  9   |    9    |  9   |  9   |  9   |   9    |   9    |   9    |
%
% ### Examples ###
%
% % Plot a scheme's RGB values:
% rgbplot(brewermap(9,'Blues'))  % standard
% rgbplot(brewermap(9,'*Blues')) % reversed
%
% % View information about a colorscheme:
% [~,num,typ] = brewermap(0,'Paired')
% num = 12
% typ = 'Qualitative'
%
% % Multi-line plot using matrices:
% N = 6;
% axes('ColorOrder',brewermap(N,'Pastel2'),'NextPlot','replacechildren')
% X = linspace(0,pi*3,1000);
% Y = bsxfun(@(x,n)n*sin(x+2*n*pi/N), X(:), 1:N);
% plot(X,Y, 'linewidth',4)
%
% % Multi-line plot in a loop:
% N = 6;
% set(0,'DefaultAxesColorOrder',brewermap(N,'Accent'))
% X = linspace(0,pi*3,1000);
% Y = bsxfun(@(x,n)n*sin(x+2*n*pi/N), X(:), 1:N);
% for n = 1:N
%     plot(X(:),Y(:,n), 'linewidth',4);
%     hold all
% end
%
% % New colors for the "colormap" example:
% load spine
% image(X)
% colormap(brewermap([],'YlGnBu'))
%
% % New colors for the "surf" example:
% [X,Y,Z] = peaks(30);
% surfc(X,Y,Z)
% colormap(brewermap([],'RdYlGn'))
% axis([-3,3,-3,3,-10,5])
%
% % New colors for the "contourcmap" example:
% brewermap('PuOr'); % preselect the colorscheme.
% load topo
% load coast
% figure
% worldmap(topo, topolegend)
% contourfm(topo, topolegend);
% contourcmap('brewermap', 'Colorbar','on', 'Location','horizontal',...
% 'TitleString','Contour Intervals in Meters');
% plotm(lat, long, 'k')
%
% ### Input and Output Arguments ###
%
% Inputs (*==default):
% N = NumericScalar, N>=0, an integer to define the colormap length.
%   = *[], use the length of the current figure's colormap (see "colormap").
%   = StringToken, to preselect this ColorBrewer scheme for later use.
%   = 'demo', create a figure showing all of the ColorBrewer schemes.
%   = 'list', return a cell array of strings listing all ColorBrewer schemes.
% scheme = StringToken, a ColorBrewer scheme name to select the colorscheme.
%        = *none, use the preselected colorscheme (must be set previously!).
%
% Outputs:
% map = NumericMatrix, size Nx3, a colormap of RGB values between 0 and 1.
% num = NumericScalar, the number of nodes defining the ColorBrewer scheme.
% typ = String, the colorscheme type: 'Diverging'/'Qualitative'/'Sequential'.
% OR
% schemes = CellArray of Strings, a list of every ColorBrewer scheme.
%
% [map,num,typ] = brewermap(*N,*scheme)
% OR
% schemes = brewermap('list')

% ### Input Wrangling ###
%
persistent dcs
%
str = 'A colorscheme must be preselected before calling without a scheme token.';
%
if nargin==0 % Current figure's colormap length and the preselected colorscheme.
	assert(~isempty(dcs),str)
	[map,num,typ] = cbSample([],dcs);
elseif nargin==2 % Input colormap length and colorscheme.
	assert(isnumeric(N),'The first argument must be a numeric scalar, or empty.')
	assert(ischar(scheme)&&isrow(scheme),'The second argument must be a string.')
	[map,num,typ] = cbSample(N,scheme);
elseif isnumeric(N) % Input colormap length and the preselected colorscheme.
	assert(~isempty(dcs),str)
	[map,num,typ] = cbSample(N,dcs);
else% String
	assert(ischar(N)&&isrow(N),'The first argument must be a string or numeric.')
	% The order of <vec>: case-insensitive sort by type and then name.
	vec = {'BrBG';'PiYG';'PRGn';'PuOr';'RdBu';'RdGy';'RdYlBu';'RdYlGn';'Spectral';'Accent';'Dark2';'Paired';'Pastel1';'Pastel2';'Set1';'Set2';'Set3';'Blues';'BuGn';'BuPu';'GnBu';'Greens';'Greys';'OrRd';'Oranges';'PuBu';'PuBuGn';'PuRd';'Purples';'RdPu';'Reds';'YlGn';'YlGnBu';'YlOrBr';'YlOrRd'};
	switch lower(N)
	case 'demo' % Plot all colorschemes in a figure.
		cbDemoFig(vec)
	case 'list' % Return a list of all colorschemes.
		[num,typ] = cellfun(@cbSelect,vec,'UniformOutput',false);
		num = cat(1,num{:});
		map = vec;
	otherwise % Store the preselected colorscheme token.
		map = dcs;
		isr = strncmp('*',N,1);
		scm = N(1+isr:end);
		[num,typ] = cbSelect(scm);
		dcs = [N(1:+isr),vec{strcmpi(vec,scm)}];
	end
end
%
end
%----------------------------------------------------------------------END:brewermap
function [map,num,typ] = cbSample(N,tok)
% Pick a colorscheme, downsample/interpolate to the requested colormap length.
%
if isempty(N)
	N = size(get(gcf,'colormap'),1);
else
	assert(isscalar(N)&&isreal(N),'First argument must be a real numeric scalar, or empty.')
end
%
% obtain nodes:
isr = strncmp('*',tok,1);
tok = tok(1+isr:end);
[num,typ,rgb] = cbSelect(tok);
% downsample:
map = rgb(cbIndex(N,num,typ,tok,isr),:);
% interpolate:
if N>num
	map = interp1(1:num,map,linspace(1,num,N),'pchip');
end
%
end
%----------------------------------------------------------------------END:cbSample
function cbDemoFig(seq)
% Creates a figure showing all of the ColorBrewer colorschemes.
%
persistent cbh axh
%
xmx = max(cellfun(@cbSelect,seq));
ymx = numel(seq);
%
if ishghandle(cbh)
	figure(cbh);
	delete(axh);
else
	cbh = figure('HandleVisibility','callback', 'IntegerHandle','off',...
		'NumberTitle','off', 'Name',[mfilename,' Demo'],'Color','white');
end
%
axh = axes('Parent',cbh, 'Color','none',...
	'XTick',0:xmx, 'YTick',0.5:ymx, 'YTickLabel',seq, 'YDir','reverse');
title(axh,['ColorBrewer Color Schemes (',mfilename,'.m)'], 'Interpreter','none')
xlabel(axh,'Scheme Nodes')
ylabel(axh,'Scheme Name')
axf = get(axh,'FontName');
%
for y = 1:ymx
	[num,typ,rgb] = cbSelect(seq{y});
	rgb = rgb(cbIndex(num,num,typ,seq{y},false),:); % downsample
	for x = 1:num
		patch([x-1,x-1,x,x],[y-1,y,y,y-1],1, 'FaceColor',rgb(x,:), 'Parent',axh)
	end
	text(xmx+0.1,y-0.5,typ, 'Parent',axh, 'FontName',axf)
end
%
end
%----------------------------------------------------------------------END:cbDemoFig
function idx = cbIndex(N,num,typ,tok,isr)
% Ensure exactly the same colors as in the online ColorBrewer schemes.
%
if strcmp(typ,'Qualitative')
	assert(N<=num,'Colorscheme "%s" maximum colormap length: %d. Requested: %d.',tok,num,N)
	idx = 1:N;
elseif strcmp(typ,'Diverging')
	switch min(N,num)
	case 1 % extrapolated
		idx = 8;
	case 2 % extrapolated
		idx = [4,12];
	case 3
		idx = [5,8,11];
	case 4
		idx = [3,6,10,13];
	case 5
		idx = [3,6,8,10,13];
	case 6
		idx = [2,5,7,9,11,14];
	case 7
		idx = [2,5,7,8,9,11,14];
	case 8
		idx = [2,4,6,7,9,10,12,14];
	case 9
		idx = [2,4,6,7,8,9,10,12,14];
	case 10
		idx = [1,2,4,6,7,9,10,12,14,15];
	case 11
		idx = [1,2,4,6,7,8,9,10,12,14,15];
	end
elseif strcmp(typ,'Sequential')
	switch min(N,num)
	case 1 % extrapolated
		idx = 6;
	case 2 % extrapolated
		idx = [4,8];
	case 3
		idx = [3,6,9];
	case 4
		idx = [2,5,7,10];
	case 5
		idx = [2,5,7,9,11];
	case 6
		idx = [2,4,6,7,9,11];
	case 7
		idx = [2,4,6,7,8,10,12];
	case 8
		idx = [1,3,4,6,7,8,10,12];
	case 9
		idx = [1,3,4,6,7,8,10,11,13];
	end
else
	error('The colorscheme type "%s" is not recognized',typ)
end
%
if isr
	idx = idx(end:-1:1);
end
%
end
%----------------------------------------------------------------------END:cbIndex
function [num,typ,rgb] = cbSelect(tok)
% Return the length, type and RGB values of any colorscheme.
%
switch lower(tok) % ColorName
case 'brbg' % BrBG
	rgb = [84,48,5;140,81,10;166,97,26;191,129,45;216,179,101;223,194,125;246,232,195;245,245,245;199,234,229;128,205,193;90,180,172;53,151,143;1,133,113;1,102,94;0,60,48];
	typ = 'Diverging';
case 'brbg_ssr' % BrBG with darker gray in the middle
	rgb = [84,48,5;140,81,10;166,97,26;191,129,45;216,179,101;223,194,125;246,232,195;230,230,230;199,234,229;128,205,193;90,180,172;53,151,143;1,133,113;1,102,94;0,60,48];
	typ = 'Diverging';
case 'piyg' % PiYG
	rgb = [142,1,82;197,27,125;208,28,139;222,119,174;233,163,201;241,182,218;253,224,239;247,247,247;230,245,208;184,225,134;161,215,106;127,188,65;77,172,38;77,146,33;39,100,25];
	typ = 'Diverging';
case 'piyg_ssr' % PiYG with darker gray in the middle
%     new_gray = [230,230,230] ;
    new_gray = [200,200,200] ;
	rgb = [142,1,82;197,27,125;208,28,139;222,119,174;233,163,201;241,182,218;253,224,239;new_gray;230,245,208;184,225,134;161,215,106;127,188,65;77,172,38;77,146,33;39,100,25];
	typ = 'Diverging';
case 'prgn' % PRGn
	rgb = [64,0,75;118,42,131;123,50,148;153,112,171;175,141,195;194,165,207;231,212,232;247,247,247;217,240,211;166,219,160;127,191,123;90,174,97;0,136,55;27,120,55;0,68,27];
	typ = 'Diverging';
case 'prgn_ssr' % PRGn with darker gray in the middle
	rgb = [64,0,75;118,42,131;123,50,148;153,112,171;175,141,195;194,165,207;231,212,232;230,230,230;217,240,211;166,219,160;127,191,123;90,174,97;0,136,55;27,120,55;0,68,27];
	typ = 'Diverging';
case 'puor' % PuOr
	rgb = [127,59,8;179,88,6;230,97,1;224,130,20;241,163,64;253,184,99;254,224,182;247,247,247;216,218,235;178,171,210;153,142,195;128,115,172;94,60,153;84,39,136;45,0,75];
	typ = 'Diverging';
case 'rdbu' % RdBu
	rgb = [103,0,31;178,24,43;202,0,32;214,96,77;239,138,98;244,165,130;253,219,199;247,247,247;209,229,240;146,197,222;103,169,207;67,147,195;5,113,176;33,102,172;5,48,97];
	typ = 'Diverging';
case 'rdbu_ssr' % RdBu with darker gray in the middle
    rgb = [103,0,31;178,24,43;202,0,32;214,96,77;239,138,98;244,165,130;253,219,199;230,230,230;209,229,240;146,197,222;103,169,207;67,147,195;5,113,176;33,102,172;5,48,97];
	typ = 'Diverging';
case 'rdgy' % RdGy
	rgb = [103,0,31;178,24,43;202,0,32;214,96,77;239,138,98;244,165,130;253,219,199;255,255,255;224,224,224;186,186,186;153,153,153;135,135,135;64,64,64;77,77,77;26,26,26];
	typ = 'Diverging';
case 'rdylbu' % RdYlBu
	rgb = [165,0,38;215,48,39;215,25,28;244,109,67;252,141,89;253,174,97;254,224,144;255,255,191;224,243,248;171,217,233;145,191,219;116,173,209;44,123,182;69,117,180;49,54,149];
	typ = 'Diverging';
case 'rdylgn' % RdYlGn
	rgb = [165,0,38;215,48,39;215,25,28;244,109,67;252,141,89;253,174,97;254,224,139;255,255,191;217,239,139;166,217,106;145,207,96;102,189,99;26,150,65;26,152,80;0,104,55];
	typ = 'Diverging';
case 'spectral' % Spectral
	rgb = [158,1,66;213,62,79;215,25,28;244,109,67;252,141,89;253,174,97;254,224,139;255,255,191;230,245,152;171,221,164;153,213,148;102,194,165;43,131,186;50,136,189;94,79,162];
	typ = 'Diverging';
case 'accent' % Accent
	rgb = [127,201,127;190,174,212;253,192,134;255,255,153;56,108,176;240,2,127;191,91,23;102,102,102];
	typ = 'Qualitative';
case 'dark2' % Dark2
	rgb = [27,158,119;217,95,2;117,112,179;231,41,138;102,166,30;230,171,2;166,118,29;102,102,102];
	typ = 'Qualitative';
case 'paired' % Paired
	rgb = [166,206,227;31,120,180;178,223,138;51,160,44;251,154,153;227,26,28;253,191,111;255,127,0;202,178,214;106,61,154;255,255,153;177,89,40];
	typ = 'Qualitative';
case 'pastel1' % Pastel1
	rgb = [251,180,174;179,205,227;204,235,197;222,203,228;254,217,166;255,255,204;229,216,189;253,218,236;242,242,242];
	typ = 'Qualitative';
case 'pastel2' % Pastel2
	rgb = [179,226,205;253,205,172;203,213,232;244,202,228;230,245,201;255,242,174;241,226,204;204,204,204];
	typ = 'Qualitative';
case 'set1' % Set1
	rgb = [228,26,28;55,126,184;77,175,74;152,78,163;255,127,0;255,255,51;166,86,40;247,129,191;153,153,153];
	typ = 'Qualitative';
case 'set2' % Set2
	rgb = [102,194,165;252,141,98;141,160,203;231,138,195;166,216,84;255,217,47;229,196,148;179,179,179];
	typ = 'Qualitative';
case 'set3' % Set3
	rgb = [141,211,199;255,255,179;190,186,218;251,128,114;128,177,211;253,180,98;179,222,105;252,205,229;217,217,217;188,128,189;204,235,197;255,237,111];
	typ = 'Qualitative';
case 'blues' % Blues
	rgb = [247,251,255;239,243,255;222,235,247;198,219,239;189,215,231;158,202,225;107,174,214;66,146,198;49,130,189;33,113,181;8,81,156;8,69,148;8,48,107];
	typ = 'Sequential';
case 'bugn' % BuGn
	rgb = [247,252,253;237,248,251;229,245,249;204,236,230;178,226,226;153,216,201;102,194,164;65,174,118;44,162,95;35,139,69;0,109,44;0,88,36;0,68,27];
	typ = 'Sequential';
case 'bupu' % BuPu
	rgb = [247,252,253;237,248,251;224,236,244;191,211,230;179,205,227;158,188,218;140,150,198;140,107,177;136,86,167;136,65,157;129,15,124;110,1,107;77,0,75];
	typ = 'Sequential';
case 'gnbu' % GnBu
	rgb = [247,252,240;240,249,232;224,243,219;204,235,197;186,228,188;168,221,181;123,204,196;78,179,211;67,162,202;43,140,190;8,104,172;8,88,158;8,64,129];
	typ = 'Sequential';
case 'greens' % Greens
	rgb = [247,252,245;237,248,233;229,245,224;199,233,192;186,228,179;161,217,155;116,196,118;65,171,93;49,163,84;35,139,69;0,109,44;0,90,50;0,68,27];
	typ = 'Sequential';
case 'greys' % Greys
	rgb = [255,255,255;247,247,247;240,240,240;217,217,217;204,204,204;189,189,189;150,150,150;115,115,115;99,99,99;82,82,82;37,37,37;37,37,37;0,0,0];
	typ = 'Sequential';
case 'orrd' % OrRd
	rgb = [255,247,236;254,240,217;254,232,200;253,212,158;253,204,138;253,187,132;252,141,89;239,101,72;227,74,51;215,48,31;179,0,0;153,0,0;127,0,0];
	typ = 'Sequential';
case 'oranges' % Oranges
	rgb = [255,245,235;254,237,222;254,230,206;253,208,162;253,190,133;253,174,107;253,141,60;241,105,19;230,85,13;217,72,1;166,54,3;140,45,4;127,39,4];
	typ = 'Sequential';
case 'pubu' % PuBu
	rgb = [255,247,251;241,238,246;236,231,242;208,209,230;189,201,225;166,189,219;116,169,207;54,144,192;43,140,190;5,112,176;4,90,141;3,78,123;2,56,88];
	typ = 'Sequential';
case 'pubugn' % PuBuGn
	rgb = [255,247,251;246,239,247;236,226,240;208,209,230;189,201,225;166,189,219;103,169,207;54,144,192;28,144,153;2,129,138;1,108,89;1,100,80;1,70,54];
	typ = 'Sequential';
case 'purd' % PuRd
	rgb = [247,244,249;241,238,246;231,225,239;212,185,218;215,181,216;201,148,199;223,101,176;231,41,138;221,28,119;206,18,86;152,0,67;145,0,63;103,0,31];
	typ = 'Sequential';
case 'purples' % Purples
	rgb = [252,251,253;242,240,247;239,237,245;218,218,235;203,201,226;188,189,220;158,154,200;128,125,186;117,107,177;106,81,163;84,39,143;74,20,134;63,0,125];
	typ = 'Sequential';
case 'rdpu' % RdPu
	rgb = [255,247,243;254,235,226;253,224,221;252,197,192;251,180,185;250,159,181;247,104,161;221,52,151;197,27,138;174,1,126;122,1,119;122,1,119;73,0,106];
	typ = 'Sequential';
case 'reds' % Reds
	rgb = [255,245,240;254,229,217;254,224,210;252,187,161;252,174,145;252,146,114;251,106,74;239,59,44;222,45,38;203,24,29;165,15,21;153,0,13;103,0,13];
	typ = 'Sequential';
case 'ylgn' % YlGn
	rgb = [255,255,229;255,255,204;247,252,185;217,240,163;194,230,153;173,221,142;120,198,121;65,171,93;49,163,84;35,132,67;0,104,55;0,90,50;0,69,41];
	typ = 'Sequential';
case 'ylgnbu' % YlGnBu
	rgb = [255,255,217;255,255,204;237,248,177;199,233,180;161,218,180;127,205,187;65,182,196;29,145,192;44,127,184;34,94,168;37,52,148;12,44,132;8,29,88];
	typ = 'Sequential';
case 'ylorbr' % YlOrBr
	rgb = [255,255,229;255,255,212;255,247,188;254,227,145;254,217,142;254,196,79;254,153,41;236,112,20;217,95,14;204,76,2;153,52,4;140,45,4;102,37,6];
	typ = 'Sequential';
case 'ylorrd' % YlOrRd
	rgb = [255,255,204;255,255,178;255,237,160;254,217,118;254,204,92;254,178,76;253,141,60;252,78,42;240,59,32;227,26,28;189,0,38;177,0,38;128,0,38];
	typ = 'Sequential';
otherwise
	error('Colorscheme "%s" is not supported. Check the token tables.',tok)
end
%
rgb = rgb./255;
%
switch typ
case 'Diverging'
	num = 11;
case 'Qualitative'
	num = size(rgb,1);
case 'Sequential'
	num = 9;
otherwise
	error('The colorscheme type "%s" is not recognized',typ)
end
%
end
%----------------------------------------------------------------------END:cbSelect
% Copyright (c) 2015 Stephen Cobeldick
% Copyright (c) 2002 Cynthia Brewer, Mark Harrower, and The Pennsylvania State University.
%
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
%
% http://www.apache.org/licenses/LICENSE-2.0
%
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and limitations under the License.
%----------------------------------------------------------------------END:license
