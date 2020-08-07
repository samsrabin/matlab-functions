function [output] = GFEDv3_ReadAsciiData_ssr(input);
%
%  Read in the ascii data sets released April 2010 coincident with Giglio
%  et al 2010 Biogeosciences paper for combined burned area analysis from
%  July 1996 to December 2009 (wow!) at half degree resolution.
%
%  Run as:  [GFEDv3p1BurnedArea] = GFEDv3_ReadAsciiData;
%           [GFEDv3p1Deforestation] = GFEDv3_ReadAsciiData;
%           save('/home/bim/matlablibrary/GFEDv3p1.emissions.deforestation.2000-2009.mat','GFEDv3p1Deforestation','-mat');
%           save('/home/bim/matlablibrary/GFEDv3p1BurnedArea.[yearsmin]-[yearsmax].mat','GFEDv3p1BurnedArea','-mat');
%
if nargin==0;
    pathname = '/home/bim/data/GFEDv3p1/';
    % filenames are GFED3.1_yyyymm_[BA,UncertBA].txt where units of BA and
    % UncertBA (1 sigma uncertainty) are hectares (100 hectares = 1 km2, 1
    % hectare = 1e4 m2)
    filenamesPrefix = 'GFED3.1_';
    % years = [2000:2009];
    % years = [2000:2000];
    years = [2000,2005];     % ssr
    %
    datasetsMultiplier = {[],[]};
    datasets = {'BA','UncertBA'};
    datasetsUnits = {'km2','km2'};
    aggregationMethod = {'sum','quad'};
%     % 2001-2007 for comparisons with Ramankutty data sets
%     years = [2001:2007];
%     datasetsMultiplier = {[]};
%     datasets = {'BA'};
%     datasetsUnits = {'km2'};
%     aggregationMethod = {'sum'};
    % % %     % when emissions are partitioned into sectors like 'deforestation' then
    % % %     % those values are actually fractions of the total emissions; if you
    % % %     % want to do total emissions, just include a [] as the
    % % %     % datasetsMultiplier field.
    % % %     datasetsMultiplier = {[],[],[],'CO','C','PM2p5',[],[]};
    % % %     datasets = {'CO','C','PM2p5','CO_deforestation','C_deforestation','PM2p5_deforestation','BA','UncertBA'};
    % % %     datasetsUnits = {'gCO/m2/month','gC/m2/month','gPM2p5/m2/month','gCO/m2/month','gC/m2/month','gPM2p5/m2/month','km2','km2'};
    % % %     aggregationMethod = {'sum','sum','sum','sum','sum','sum','sum','quad'};
    %
    % % %     datasetsMultiplier = {'CO'};
    % % %     datasets = {'CO_deforestation'};
    % % %     datasetsUnits = {'gCO/m2/month'};
    % % %     aggregationMethod = {'sum'};
    filenamesSuffix = '.txt';
    output.pathname = pathname;
    output.filename = 'GFED3.1_yyyymm_[datasets].txt';
    output.years = years;
    output.datasets = datasets;
    output.datasetsUnits = datasetsUnits;
    % fill out a yyyy,mm,dd field
    for ii=1:length(output.years);
        output.yyyymmdd(1+12*(ii-1):12+12*(ii-1),1:3) = ...
            cat(2,repmat(output.years(ii),12,1),[1:12]',ones(12,1));
    end;  % for ii loop
    % half degree grid
    output.original.lat = [89.75:-0.5:-89.75]';
    output.original.lon = [-179.75:0.5:179.75]';
    IGBPhalfdegree = GetLandFraction(2);
    output.original.area = IGBPhalfdegree.area;
    output.original.landfrac = IGBPhalfdegree.landfrac;
    output.original.areaUnits = IGBPhalfdegree.area_units;
    output.original.years = output.years;
    output.original.yyyymmdd = output.yyyymmdd;
    aggregateData = 0;
    if aggregateData;
% ssr        % just load this file for lat lon grid
% ssr        load('/home/bim/fireModel/fireModelOfflineInput.mat');
        lat2p0 = -180:1:179;	%ssr, changed RHS
        lon2p5 = -89:1:83;		%ssr, changed RHS
        output.aggregated.lat = lat2p0;
        output.aggregated.lon = lon2p5;
        output.aggregated.years = years;
        output.aggregated.yyyymmdd = output.yyyymmdd;
        output.aggregated.area(:,:) = %ssr fireModelOfflineInput.area3D;
            % ssr note: Converts array of dimension (1,dim2,dim3) to
            % (dim2,dim3. I need to change this!
        area3D(1,:,:) = output.aggregated.area;
        output.aggregated.areaUnits = 'km2';
        output.aggregated.landfrac(:,:) = fireModelOfflineInput.landfrac3D;
    end;  % if aggregateData loop
    % cycle over datasets
    for ii=1:length(datasets);
        clear temp tempMultiplier;
        disp(cat(2,'-> Working on dataset = ',datasets{ii}));
        % cycle over years
        for jj=1:length(years);
            % cycle over months
            for kk=1:12;
                if kk<10;
                    monthsStr = cat(2,'0',num2str(kk));
                else;
                    monthsStr = num2str(kk);
                end;  % if kk loop
                filename = cat(2,filenamesPrefix,num2str(years(jj)),monthsStr,'_',datasets{ii},filenamesSuffix);
                fid = fopen(cat(2,pathname,filename));
                if ~isempty(datasetsMultiplier{ii});
                    filenameMultiplier = cat(2,filenamesPrefix,num2str(years(jj)),monthsStr,'_',datasetsMultiplier{ii},filenamesSuffix);
                else;
                    filenameMultiplier = 'NONE';
                end;  % if ~isempty loop
                fidMultiplier = fopen(cat(2,pathname,filenameMultiplier));
                % check to make sure file exists
                if fid>0;
                    fclose(fid);
                    disp(cat(2,'   Getting data from ',filename));
                    temp(kk+12*(jj-1),:,:) = load(cat(2,pathname,filename));
                    if fidMultiplier>0;
                        fclose(fidMultiplier);
                        disp(cat(2,'   (Getting multiplier data from ',filenameMultiplier,')'));
                        tempMultiplier(kk+12*(jj-1),:,:) = load(cat(2,pathname,filenameMultiplier));
                    else;
                        tempMultiplier = 1;
                    end;  % if fidMultiplier loop
                else;
                    disp(cat(2,'   File not found, storing blanks for ',filename));
                    temp(kk+12*(jj-1),:,:) = -999.9.*ones(1,length(output.original.lat),length(output.original.lon));
                end;  % if fid loop
            end;  % for kk loop
        end;  % for jj loop
        temp = temp.*tempMultiplier;
        switch datasets{ii}
            case {'BA','UncertBA'}
                % convert from hectares to km2 (1 hectare = 1/100 km2)
                temp = temp.*0.01;
                if aggregateData;
                    % aggregate the data from half to some multiple of half (gt half) and
                    % adjust the lat lon coord if necessary
                    output.aggregated.(datasets{ii}) = ...
                        AggregateData(output.original.lat,output.original.lon,lat2p0,lon2p5,temp,aggregationMethod{ii});
                else;
                    output.original.(datasets{ii}) = temp;
                end;  % if aggregateData loop
            otherwise
                if aggregateData;
                    % aggregate the data from half to some multiple of half (gt half) and
                    % adjust the lat lon coord if necessary
                    output.aggregated.(datasets{ii}) = ...
                        AggregateData(output.original.lat,output.original.lon,lat2p0,lon2p5,temp,aggregationMethod{ii}, ...
                        output.original.area.*1e6,output.aggregated.area.*1e6);
                else;
                    output.original.(datasets{ii}) = temp;
                end;  % if aggregateData loop
        end;  % switch loop
        % calculate annual total emissions in g(species)/year and these can
        % be compared with the unaggregated totals at
        % http://www.falw.vu/~gwerf/GFED/index.html and click on 'access
        % tables' to get something like
        % http://www.falw.vu/~gwerf/GFED/GFED3/tables/emis_CO_absolute.txt
        % cycle over years
        for jj=1:length(years);
            if aggregateData;
                switch datasets{ii}
                    case {'BA','UncertBA'}
                        temp = output.aggregated.(datasets{ii})(1+12*(jj-1):12+12*(jj-1),:,:);
                    otherwise
                        temp = output.aggregated.(datasets{ii})(1+12*(jj-1):12+12*(jj-1),:,:).*repmat(area3D,[12,1,1]).*1e6;
                end;  % switch loop
                tempsum(:,:) = sum(temp,1);
                output.aggregated.(cat(2,'total',datasets{ii}))(jj,1) = sum(tempsum(:));
                disp(cat(2,'   Total ',datasets{ii}));
                disp(output.aggregated.(cat(2,'total',datasets{ii}))(jj,1));
            else;
                switch datasets{ii}
                    case {'BA','UncertBA'}
                        temp = output.original.(datasets{ii})(1+12*(jj-1):12+12*(jj-1),:,:);
                    otherwise
                        temp = output.original.(datasets{ii})(1+12*(jj-1):12+12*(jj-1),:,:).*repmat(area3D,[12,1,1]).*1e6;
                end;  % switch loop
                tempsum(:,:) = sum(temp,1);
                output.original.(cat(2,'total',datasets{ii}))(jj,1) = sum(tempsum(:));
                disp(cat(2,'   Total ',datasets{ii}));
                disp(output.original.(cat(2,'total',datasets{ii}))(jj,1));
            end;  % if aggregateData loop
        end;  % for jj loop
    end;  % for ii loop
else;
    output = input;
end;  % if nargin loop
% send output.aggregated to write a netcdf of the aggregated
% GFEDv3.1
% UNCOMMENT IF YOU WANT THIS
% CreateNetCDFOfOutput(output.aggregated);
% send output.original to write a netcdf of the original 0.5 deg
% GFEDv3.1 (which can become quite large)
% UNCOMMENT IF YOU WANT THIS
% CreateNetCDFOfOutput(output.original);

function [output] = GetLandFraction(useres,fignum);
%
%  Put information from IGBP land classification into a matlab format.
%  Landfraction can easily be derived by looking at the fractional coverage
%  of ocean/water and doing 1-fc_ocean = fc_land.  other vegetation biomes
%  (IGBP) can be accessed but are not necessary.  Right now, just have
%  access to 1deg and 0.5deg resolution IGBP landcover maps, but 0.25deg
%  are ready to go.  i checked (visually) and the 0.5deg matches the one L
%  Giglio derived from MODIS 1km landcover products and sent me (accessed
%  using MODIS_Fire_GetLandFraction.m).  probably, the MODIS 0.5deg map is
%  better than the IGBP map since it is newer... i just wanted a quick 1deg
%  landcover for GFEDv2 (GFEDv3 should be 0.5deg and available by mid2008).
%  That's it!
% 
%  Run as [output] = GetLandFraction(1); for 1 degree
%         [output] = GetLandFraction(2); for 1/2 degree
%
%  output is pixel area in km2 and landfrac in percent of pixel area that
%  is land
%
if nargin==0;
    disp('!! Using DEFAULT gridcell resolution = 1 degree');
    useres = 1;
    fignum = 0;
elseif nargin==1;
    fignum = 0;    
end;  % if nargin loop
pathname2 = {'edc_lcover_igbp_1deg/','edc_lcover_igbp_hdeg/'};
pathname1 = '/home/bim/data/IGBP_landcover/';
filename = {'edc_lcover_igbp_1d_c00.asc','edc_lcover_igbp_hd_c00.asc'};
latstart = [89.5,89.75];
lonstart = [-179.5,-179.75];
res = [1,0.5];
IGBP_landfrac = load(cat(2,pathname1,pathname2{useres},filename{useres}));
% scale down by 100
IGBP_landfrac = 1-IGBP_landfrac./100;
% develop lat and lon coord (dependent on resolution)
for ii=1:180/res(useres);
    IGBP_lat(ii,1) = latstart(useres)-res(useres)*(ii-1);
end;  % for ii loop
for ii=1:360/res(useres);
    IGBP_lon(ii,1) = lonstart(useres)+res(useres)*(ii-1);
end;  % for jj loop
% calculate the total surface area in each pixel (depends on res)
R_E = 6371.0;
lat1 = 90-[0:(180/res(useres)-1)].*res(useres);
lat2 = lat1-res(useres);
d2r = pi/180;
% area in km2 (equations from L Giglio)
pixel_area = R_E^2*d2r*res(useres).*(sin(d2r.*lat1)-sin(d2r.*lat2));
% set up output
output.pathname = cat(2,pathname1,pathname2{useres});
output.filename = filename{useres};
output.lat = IGBP_lat;
output.lon = IGBP_lon;
output.area = (repmat(pixel_area,360/res(useres),1))';
output.area_units = 'km2';
output.landfrac = IGBP_landfrac;
% show an example plot
if fignum>0;
    coastlines = load('coastlines_180_180.dat');
    figure(fignum);
    clf reset;
    offset = res(useres)/2;
    pcolor(output.lon+offset,output.lat-offset, ...
        output.landfrac);
    shading flat;
    colormap bone;
    colorbar;
    hold on;
    plot(coastlines(:,1),coastlines(:,2),'b-','Linewidth',1);
end;  % if showexample loop
    
function [output] = AggregateData(lat,lon,latA,lonA,dataset,aggregationMethod,areaOriginal,areaAggregated);
%
%  Aggregate the half degree dataset to another lat and lon sent as input.
%  Assumes an integer magnitude of the half degree resolution is the
%  spatial aggregation.  Also, if we are aggregating uncertainty, sum these
%  in quadratures to prevent overestimate of uncertainty.
%
if nargin<7;
    areaOriginal = 1;
    areaAggregated = 1;
end;  % if nargin loop
checkAggregation = 0;
% GFEDv3 burned area are +90 to -90 and -180 to 180 in units of
% hectare originally, but have already been converted to km2
% aggregate from 0.5x0.5 to 2x2.5 in latxlon (factor of 4 for lat, factor
% of 5 for lon in terms of aggregation)
aggregationLat = round(length(lat)./length(latA));
aggregationLon = round(length(lon)./length(lonA));
disp(cat(2,'-> Aggregating from 0.5x0.5 to ', ...
    num2str(0.5*aggregationLat),'x',num2str(0.5*aggregationLon),' using ', ...
    aggregationMethod));
% cycle over timeseries
for ii=1:length(dataset(:,1,1));
    % cycle over lonA
    for kk=1:length(lonA);
        % cycle over latA
        for jj=1:length(latA);
            clear temp2D;
            temp2D(:,:) = dataset(ii,1+aggregationLat*(jj-1):aggregationLat+aggregationLat*(jj-1), ...
                1+aggregationLon*(kk-1):aggregationLon+aggregationLon*(kk-1));
            if size(areaOriginal)>1;
                temp2DAreaOriginal(:,:) = areaOriginal(1+aggregationLat*(jj-1):aggregationLat+aggregationLat*(jj-1), ...
                    1+aggregationLon*(kk-1):aggregationLon+aggregationLon*(kk-1));
                temp2DAreaAggregated = areaAggregated(jj,kk);
            else
                temp2DAreaOriginal = 1;
                temp2DAreaAggregated = 1;
            end;  % if size loop
            temp2D(find(temp2D<0)) = NaN;
            switch aggregationMethod
                case {'sum'}
                    checkAggregation = 0;
                    output(ii,jj,kk) = nansum(temp2D(:).*temp2DAreaOriginal(:))./temp2DAreaAggregated;
                case {'quad'}
                    checkAggregation = 0;
                    temp2D = temp2D.^2;
                    output(ii,jj,kk) = sqrt(nansum(temp2D(:)));
                case {'mean'}
                    checkAggregation = 0;
                    output(ii,jj,kk) = nanmean(temp2D(:));
                otherwise
                    disp('!! Default method is to sum');
                    output(ii,jj,kk) = nansum(temp2D(:));
            end;  % switch loop
        end;  % for jj loop
    end;  % for kk loop
    % switch to AM3 lat lon coord which are -90 to 90 and 0 to 360 rather
    % than 90 to -90 and -180 to 180 (oi)
    clear temp2D
    temp2D(:,:) = output(ii,:,:);
    temp2D = flipud(temp2D);
    halfway = length(lonA)/2;
    wholeway = length(lonA);
    WH = temp2D(:,1:halfway);
    EH = temp2D(:,halfway+1:wholeway);
    temp2D = cat(2,EH,WH);
    output(ii,:,:) = temp2D;
    %
    if checkAggregation;
        % note that area may be 1 if not relevant to the dataset (BA for
        % example is already in area units, whereas emissions are per m2
        % area and needs to be considered for global totals)
        clear temp2D;
        temp2D(:,:) = output(ii,:,:);
        temp2D = temp2D.*areaAggregated;
        checkSumAggregate = nansum(temp2D(:));
        clear temp2D;
        temp2D(:,:) = dataset(ii,:,:);
        temp2D(find(temp2D<0)) = NaN;
        temp2D = temp2D.*areaOriginal;
        checkSumOriginal = nansum(temp2D(:));
        disp(cat(2,'   checksum original = ',sprintf('%2.5e',checkSumOriginal), ...
            ' and checksum aggregate = ',sprintf('%2.5e',checkSumAggregate), ...
            ' for month ',num2str(ii)));
    end;  % if checkAggregation loop
end;  % for ii loop

function [] = CreateNetCDFOfOutput(input,savetag);
%
%
%
fieldNames = {'BA','UncertBA'};
fieldNamesLong = {'GFED version 3.1 burned area','GFED version 3.1 burned area 1 sigma uncertainty'};
fieldNamesUnits = {'km2','km2'};
%
fieldNames = {'CO_deforestation'};
fieldNamesLong = {'GFED version 3.1 CO from deforestation'};
fieldNamesUnits = {'kgCO/m2/month'};
%
fieldNames = {'CO','C','PM2p5','CO_deforestation','C_deforestation','PM2p5_deforestation','BA','UncertBA'};
fieldNamesLong = {'GFED version 3.1 CO','GFED version 3.1 C','GFED version 3.1 PM2p5', ...
    'GFED version 3.1 CO from deforestation','GFED version 3.1 C from deforestation','GFED version 3.1 PM2p5 from deforestation', ...
    'GFED version 3.1 burned area','GFED version 3.1 burned area 1 sigma uncertainty'};
fieldNamesUnits = {'gCO/m2/month','gC/m2/month','gPM2p5/m2/month','gCO/m2/month','gC/m2/month','gPM2p5/m2/month','km2','km2'};
%  for comparison with Ramankutty
fieldNames = {'BA'};
fieldNamesLong = {'GFED version 3.1 burned area'};
fieldNamesUnits = {'km2'};
%
if nargin==1;
    savetag = [];
else;
    savetag = cat(2,savetag,'.');
end;  % if nargin loop
savefilename = cat(2,'GFEDv3p1.BurnedArea.AM3.',savetag,num2str(min(input.years)),'-', ...
    num2str(max(input.years)),'.nc');
savefilename = cat(2,'GFEDv3p1.emissions.burnedarea.deforestation.2x2.5.',savetag,num2str(min(input.years)),'-', ...
    num2str(max(input.years)),'.nc');
savefilename = cat(2,'GFEDv3p1.burnedarea.0.5x0.5.',savetag,num2str(min(input.years)),'-', ...
    num2str(max(input.years)),'.nc');
savepath = '/home/bim/matlablibrary/';
savefilename = cat(2,savepath,savefilename);
disp(cat(2,'-> Creating NetCDF file of input/outputs in ',savefilename));
%%%%%%%%%%%%%%%%%%
% add time, lat, lon dimensions
%%%%%%%%%%%%%%%%%%
mode=bitor(nc_clobber_mode,nc_64bit_offset_mode);
nc_create_empty(savefilename,mode);
%%%%%%%%%%%%%%%%%%
% lon
%%%%%%%%%%%%%%%%%%
nc_add_dimension(savefilename,'lon',length(input.lon));
lon_varstruct.Name = 'lon';
lon_varstruct.Dimension = {'lon'};
lon_varstruct.Nctype = nc_float;
nc_addvar(savefilename,lon_varstruct);
nc_attput(savefilename,'lon','long_name','longitude');
nc_attput(savefilename,'lon','units','degrees_E');
nc_attput(savefilename,'lon','resolution','0.5 degrees');
% nc_attput(savefilename,'lon','resolution','2.5 degrees');
nc_attput(savefilename,'lon','note','0 to 360');
nc_varput(savefilename,'lon',input.lon);
%%%%%%%%%%%%%%%%%%
% lat
%%%%%%%%%%%%%%%%%%
nc_add_dimension(savefilename,'lat',length(input.lat));
lat_varstruct.Name = 'lat';
lat_varstruct.Dimension = {'lat'};
lat_varstruct.Nctype = nc_float;
nc_addvar(savefilename,lat_varstruct);
nc_attput(savefilename,'lat','long_name','latitude');
nc_attput(savefilename,'lat','units','degrees_N');
nc_attput(savefilename,'lat','resolution','0.5 degrees');
% nc_attput(savefilename,'lat','resolution','2 degrees');
nc_attput(savefilename,'lat','note','-90 to 90');
nc_varput(savefilename,'lat',input.lat);
%%%%%%%%%%%%%%%%%%
% time, add time after data put into nc file
%%%%%%%%%%%%%%%%%%
nc_add_dimension(savefilename,'time',0);
time_varstruct.Name = 'time';
time_varstruct.Dimension = {'time'};
time_varstruct.Nctype = nc_double;
nc_addvar(savefilename,time_varstruct);
nc_attput(savefilename,'time','long_name','time');
nc_attput(savefilename,'time','units','days since 1850-01-01 00:00:00');
nc_attput(savefilename,'time','calendar','julian');
%%%%%%%%%%%%%%%%%%
% gridcell area in km2
%%%%%%%%%%%%%%%%%%
area_varstruct.Name = 'area';
area_varstruct.Dimension = {'lat','lon'};
area_varstruct.Nctype = nc_float;
nc_addvar(savefilename,area_varstruct);
nc_attput(savefilename,'area','long_name','gridcell area');
nc_attput(savefilename,'area','units','km2');
nc_varput(savefilename,'area',input.area);
%%%%%%%%%%%%%%%%%%
% landfrac (fraction of gridcell that is land)
%%%%%%%%%%%%%%%%%%
landfrac_varstruct.Name = 'landfrac';
landfrac_varstruct.Dimension = {'lat','lon'};
landfrac_varstruct.Nctype = nc_float;
nc_addvar(savefilename,landfrac_varstruct);
nc_attput(savefilename,'landfrac','long_name','gridcell land fraction');
nc_attput(savefilename,'landfrac','units','none');
nc_varput(savefilename,'landfrac',input.landfrac);
%%%%%%%%%%%%%%%%%%
% add variables
%%%%%%%%%%%%%%%%%%
% cycle over AOP
for jj=1:length(fieldNames);
    if isfield(input,fieldNames{jj});
        disp(cat(2,'   Working on ',fieldNames{jj}));
        % replace NaN with -999.9 for missing data
        input.(fieldNames{jj})(find(isnan(input.(fieldNames{jj}))==1)) = -999.9;
        varstruct.Name = fieldNames{jj};
        varstruct.Nctype = nc_float;
        varstruct.Dimension = {'time','lat','lon'};
        nc_addvar(savefilename,varstruct);
        nc_attput(savefilename,fieldNames{jj},'long_name',fieldNamesLong{jj});
        nc_attput(savefilename,fieldNames{jj},'units',fieldNamesUnits{jj});
        nc_attput(savefilename,fieldNames{jj},'missing_value',-999.9);
        start = [0,0,0];
        count = [length(input.yyyymmdd),length(input.lat),length(input.lon)];
        % depending on the input resolution (annual, meanmonthly, monthly),
        % output to the netCDF slightly differently
        clear tempOutput;
        % monthly time series
        tempOutput = input.(fieldNames{jj});
        nc_attput(savefilename,fieldNames{jj},'note','monthly time series');
        nc_varput(savefilename,fieldNames{jj},tempOutput,start,count);
    else;
        disp(cat(2,'   Field not available for netcdf:  ',fieldNames{jj}));
    end;  % if ~isempty loop
end;  % for jj loop
% cycle over yyyymmdd
for mm=1:length(input.yyyymmdd);
    julianDates(mm,1) = datenum(input.yyyymmdd(mm,:))-datenum([1850,1,1]);
    if input.yyyymmdd(mm,2)<10;
        monthString = cat(2,'0',num2str(input.yyyymmdd(mm,2)));
    else
        monthString = num2str(input.yyyymmdd(mm,2));
    end;  % if output loop
    yyyymmddString(mm,1) = str2num(cat(2,num2str(input.yyyymmdd(mm,1)), ...
        monthString,'01'));
end;  % for mm loop
start = [0];
count = [length(input.yyyymmdd)];
nc_varput(savefilename,'time',julianDates,start,count);
%%%%%%%%%%%%%%%%%%
% date, add date after data put into nc file
%%%%%%%%%%%%%%%%%%
date_varstruct.Name = 'date';
date_varstruct.Dimension = {'time'};
date_varstruct.Nctype = nc_int;
nc_addvar(savefilename,date_varstruct);
nc_attput(savefilename,'date','long_name','date');
nc_attput(savefilename,'date','units','YYYYMMDD');
start = [0];
count = [length(input.yyyymmdd)];
nc_varput(savefilename,'date',yyyymmddString,start,count);
%%%%%%%%%%%%%%%%%%
% add global attributes
%%%%%%%%%%%%%%%%%%
nc_attput(savefilename,nc_global,'source','/home/bim/data/GFEDv3p1/');
nc_attput(savefilename,nc_global,'reference','http://www.biogeosciences.net/7/1171/2010/bg-7-1171-2010.pdf (Giglio et al, Biogeosciences, 2010)');
nc_attput(savefilename,nc_global,'data','ftp fuoco.geog.umd.edu, login fire, password burnt');
nc_attput(savefilename,nc_global,'script','/home/bim/matlablibrary/GFEDv3_ReadAsciiData.m');
nc_attput(savefilename,nc_global,'note','original data is at 0.5x0.5 degree resolution');
nc_attput(savefilename,nc_global,'history','-');
nc_attput(savefilename,nc_global,'author','brian.magi@noaa.gov');
