function bin_summaries = bin_summaries(binner,observations)
% Calculates mean, SD, and median (excluding outliers, if desired, and NaN) for all bins
% in a dataset. Bin width is given by the user.

bin_size = input('Enter the desired bin width: ') ;

y = 1;
n = 0;
outliers = input('Exclude outliers? y/n: ') ;
while ~(outliers==y) && ~(outliers==n)
	warning('Answer only y or n.')
	outliers = input('Exclude outliers? y/n: ') ;
end

binner_obsnonan = binner( isnan(observations) == 0) ;
outlier_upper = median(observations(isnan(observations)==0)) + 1.5*iqr(observations(isnan(observations)==0)) ;
outlier_lower = median(observations(isnan(observations)==0)) - 1.5*iqr(observations(isnan(observations)==0)) ;

tmp = zeros(ceil(max(binner_obsnonan)/bin_size),3) ;

i = 1 ;

if outliers == y
	while bin_size*(i-1) <= max(binner_obsnonan)
		tmp(i,1) = mean(observations(isnan(observations)==0 & observations<=outlier_upper & observations>=outlier_lower & binner >= bin_size*(i-1) & binner < bin_size*i)) ;
		tmp(i,2) = std(observations(isnan(observations)==0 & observations<=outlier_upper & observations>=outlier_lower & binner >= bin_size*(i-1) & binner < bin_size*i)) ;
		tmp(i,3) = median(observations(isnan(observations)==0 & observations<=outlier_upper & observations>=outlier_lower & binner >= bin_size*(i-1) & binner < bin_size*i)) ;
		i = i + 1 ;
	end
end

if outliers == n
	while bin_size*(i-1) <= max(binner_obsnonan)
		tmp(i,1) = mean(observations(isnan(observations)==0 & binner >= bin_size*(i-1) & binner < bin_size*i)) ;
		tmp(i,2) = std(observations(isnan(observations)==0 & binner >= bin_size*(i-1) & binner < bin_size*i)) ;
		tmp(i,3) = median(observations(isnan(observations)==0 & binner >= bin_size*(i-1) & binner < bin_size*i)) ;
		i = i + 1 ;
	end
end

bin_summaries = tmp ;

bin_averages = tmp(:,1)
bin_stdevs = tmp(:,2)
bin_medians = tmp(:,3)

end