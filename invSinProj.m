function [lat, long] = invSinProj(x,y) 

% From http://se.cs.ait.ac.th/cvwiki/matlab:tutorial:modis_dataset_manipulation_in_matlab#modis_sinusoidal-projection_to_mercator_projection

 R = 6371007.18100; % Earth's radius
 long_0 = 0;
 lat = y/R;
 long = long_0 + x/(R*cos(lat));
 lat = lat*180/pi; %degree
 long = long*180/pi;
 end 