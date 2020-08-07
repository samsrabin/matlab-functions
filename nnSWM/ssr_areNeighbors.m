function N=ssr_areNeighbors(xcoord,ycoord,maxDist)
% SSR: ADAPTED FROM NNSWM() FUNCTION BY PATRICK WALSH
% ------------------------------------------------------
% USAGE: N=ssr_areNeighbors(xcoord,ycoord,maxDist)
% where:     xcoord = x-direction coordinate
%            ycoord = y-direction coordinate
%            maxDist = maximum distance to be considered a "neighbor"
% ------------------------------------------------------
% RETURNS: 
%          N = a sparse matrix based on the given maximum "neighbor"
%              distance. A 1 is entered at (i,j) if i and j are 
%              deemed neighbors.
% ------------------------------------------------------
%
% written by: Patrick Walsh
% Walsh.Patrick@epa.gov
% Economist
% National Center for Environmental Economics, US EPA

% % % % % % First, preallocate a matrix for the nearest neighbor results
% % % % % Neighbors = zeros(length(xcoord)*N,3);
% SSR: Since I'm not finding the nearest N neighbors, I don't know how
% large the matrix is going to be, so I will have to build it as I go
% along.
Neighbors = [] ;

% Start looping over all observations
for i = 1:length(xcoord)
	% Create a matrix to put all the distances between i and j and i and j
	DistMat = zeros(length(xcoord),3);
	
	% Start loop between i and all other j
	for j=1:length(xcoord)
		% Calculate distance between observations
		Xdist=abs(xcoord(i)-xcoord(j));
		Ydist=abs(ycoord(i)-ycoord(j));
		D = sqrt(Xdist^2 + Ydist^2);
		DistMat(j,:) = [i j D];
	end
	% Now that we have the matrix of distances and is and js, want to take the nearest
	% N neighbors by distance,  excluding the self distance (i==j)
	% First, find i==j and remove it (don't want an observation to be a neighbor to itself)
	A = find(DistMat(:,1)==DistMat(:,2));
	DistMat(A,:)=[];
% % % % % 	% Next sort the distance matrix
% % % % % 	DistMatSort = sortrows(DistMat,3);
% % % % % 	% Keep the closest N items
% % % % % 	Nneighbors = DistMatSort(1:N,:);
% % % % % 	% this matrix contains the N nearest neighbors
    % SSR: Keep all neighbors that are within maxDist
    Nneighbors = DistMat(DistMat(:,3)<=maxDist,:) ;
	
% % % % % 	% Put this set of N observations into the preallocated matrix.
% % % % % 	Neighbors(((i-1)*N+1):i*N,:) = Nneighbors;
    Neighbors = cat(1,Neighbors,Nneighbors) ;
end
% % % % % n=length(xcoord);
% % % % % S = sparse(Neighbors(:,1),Neighbors(:,2),Neighbors(:,3),n,n);
% Neighbors(:,3) = ones(size(Neighbors,1))
N = Neighbors ;
	


