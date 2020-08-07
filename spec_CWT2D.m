%spec_CWT2D.m:   Computes the wavelet power spectral density using a 2-D Continous Wavelet Transform
%
%default options
% opts=struct('mother','isomor2d',... 
%             's0',2, ...   
%             'PAD',0, ...   
%             'param',[8 1], ...    
%             'angle',0,...
%             'fun',0,...
%             'J1',-1, ...   
%             'dj',0.15, ...
%             'dx',1,...
%             'scale',0,...
%             'order',2,...
%             'graph','n');
%
%
% Matteo Detto, PhD
% Biometeorology lab, Ecosystem Science Division
% Dept. of Environmental Science, Policy, and Management (ESPM)
% University of California, Berkeley, CA 94720
% Phone: 1-510-642 9048
% Fax: 1-510-643-5098
% last update: 5 October 2013
% -------------------------------------------------------------------------
%   2007-2014, Matteo Detto
%   This software may be used, copied, or redistributed as long as it is not
%   sold and this copyright notice is reproduced on each copy made.  This
%   routine is provided as is without any express or implied warranties
%   whatsoever.
%
% example:
% s=randn(120,400);
% s(s>0)=1;s(s<=0)=0;
% [E,scale] = spec_CWT2D(s);loglog(scale,2*E/mean(s(:)))
%%% or
% [E,scale] = spec_CWT2D(s,'graph','y');
 
function [E,scale,varargout] = spec_CWT2D(s,varargin)
 
%default options
opts=struct('mother','morlet',... 
            's0',2, ...   
            'PAD',0, ...   
            'param',[8 1 1], ...   
            'angle',[],...
            'fun',0,...
            'J1',-1, ...   
            'dj',0.15, ...
            'dx',1,...
            'scale',[],...
            'mask',0,...
            'order',2,...
            'L',100,...
            'graph','n');
opts=parseArgs(varargin,opts);
[m,n]=size(s);
 
dx=opts.dx;
dj=opts.dj;
k0=opts.param(1);
sd=opts.param(2);
if n==2
    s=map_maker(s(:,1),s(:,2),opts.L,dx);
    [m,n]=size(s);
end
 
    if strcmp(opts.mother,'morlet')
        Ff=4*pi/(k0+sqrt(4/sd^2+k0^2));
    elseif strcmp(opts.mother,'mexican')
        Ff=2*pi/sqrt(k0+1);
    end
s0=opts.s0/Ff;
if opts.J1==-1 && isempty(opts.scale)
    J1=floor((log(min(m/2,n/2)/s0)/log(2))/dj)-1;
    scale(:,1) = s0*2.^((0:J1)*dj);
elseif opts.J1>0 && isempty(opts.scale)
    scale(:,1) = s0*2.^((0:opts.J1)*dj);
elseif ~isempty(opts.scale)
    scale(:,1)=opts.scale/opts.dx/Ff;
end
S=length(scale);
f=fft2(s);
FS(1,:)=abs(f(:)).^2/m/n;
npuls_2   = floor((n-1)/2);
pulsx     = 2*pi/n*[ 0:npuls_2  (npuls_2-n+1):-1 ];
npuls_2   = floor((m-1)/2);
pulsy     = 2*pi/m*[ 0:npuls_2  (npuls_2-m+1):-1 ];
[kx,ky] = meshgrid(pulsx,pulsy);
%dkxdky = abs( (kx(1,2) - kx(1,1)) * (ky(2,1) - ky(1,1)) );
if isempty(opts.angle)
     K=sqrt(kx.^2+ky.^2);
     KS=(K(:)*scale');
    if strcmp(opts.mother,'morlet')
        H=exp(-(KS-k0).^2);
    elseif strcmp(opts.mother,'mexican')
        H=abs((-1i*kx(:)*ones(1,S)).^k0+(-1i*ky(:)*ones(1,S)).^k0).^2.*exp(-KS.^2);
    end
E(:,1)=(FS*H)./sum(H);
else
   
     ang=opts.angle;
     A=length(ang);
     epsilon=opts.param(3);
     E=zeros(S,A);
     A_2=floor(A/2);
     for i=1:A_2
         A_2-i
          kxa = cos(ang(i))*kx - sin(ang(i))*ky;
          kya = sin(ang(i))*kx + cos(ang(i))*ky;
          H=exp( - ( (kxa(:)*scale' - k0).^2 + (epsilon*kya(:)*scale').^2 ));
          E(:,i)=(FS*H)./sum(H);
          E(:,i+A_2)=E(:,i);
     end
    E(:,A)=E(:,1);
% [th,r] = meshgrid(angle,log(scale));
% [X,Y] = pol2cart(th,r);
% figure(2);clf
% h = polar([0 2*pi], log([scale(1) scale(end)]));
% delete(h)
% hold on
% contourf(X,Y,log(E),10)
end
 
 
    
% E=zeros(S,1);
% for i=1:S
%    
%     H=abs(psi(scale(i)*K,k0,sd)).^2;
% %     H=abs(psi(scale(i)*kx,scale(i)*ky,k0,sd)).^2;
%     E(i,1)=sum(FS(:).*H(:))/sum(H(:));
%
% end
if nargout>2 || opts.graph=='y'
dof=sqrt(2)*sum(H)';
varargout{1}=dof;
%  varargout{2}=norm;
end
% %
%   surf(kx,ky,H);shading flat
%convert wavelet scale in Fourier period
scale=scale*dx*Ff;
if opts.graph=='y'
    figure(1)
    loglog(scale,2*E/mean(s(:)),'k','linewidth',2);hold all
    loglog(scale,chi2inv(0.975,dof)./dof,'r--')
    loglog(scale,chi2inv(0.025,dof)./dof,'r--')
    refline(0,1)
    xlabel('scale','fontsize',14)
    ylabel('wavelet variance','fontsize',14)
end
   
 
 function f = map_maker(x,y,L,dx)
 
if length(L)==1
  [XI,YI]=meshgrid(0:dx:L,0:dx:L);
elseif length(L)==2
  [XI,YI]=meshgrid(0:dx:L(1),0:dx:L(2));
elseif length(L)>2
[XI,YI]=meshgrid(L,dx);
end
    [J I]=size(XI);
    f=zeros(J,I-1);
for i=1:I-1
%     I-i
    use1= x>=XI(1,i) & x<XI(1,i+1);
    f(:,i)=histc(y(use1),YI(:,1));
  
end
dd=f(end,:)==1;
f(end-1,dd)=f(end-1,dd)+1;
f=f(1:end-1,:);
end
 
end