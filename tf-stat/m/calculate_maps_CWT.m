function [out_map,t,f] =calculate_maps_CWT(c,  res_max)

VOICES=c.Fsize;
xx=(1:c.Tsize);
yy=(1:c.Fsize);


eval(c.read_raw_data); % wczytanie danych wg recepty z config'a

map_linear=zeros(c.Fsize,c.Tsize);
map_transformed=zeros(c.Fsize,c.Tsize);
if res_max==1
    out_map=zeros(c.Fsize,c.Tsize);
else
    out_map=zeros(c.N,c.map_y_size,c.map_x_size);
end
str='';
for i=1:c.N
    % drawing single map
    %for ss=1:length(str)
    %        fprintf(1,'\b')
    %    end
        
    str=sprintf('channel %d map:%3d/%-3d\r',c.current_channel, i,c.N);
    fprintf(1,'%s',str);
    X=data(i,:)';
    [map_linear,t,f]=scalo_jz(X,xx,c.WAVE,c.f_min/c.sampling,c.f_max/c.sampling,VOICES );% mapaXY
    pause(0);
    if res_max==1
        out_map = out_map+map_transform(map_linear, c.ENERGY_SCALE)/c.N;
    else
        DT=c.dt*c.sampling;
        DF=floor(c.df/(c.sampling/2)*c.dimBase/2);
	t=linspace(c.tmin,c.tmax,c.map_x_size);
	f=linspace(c.f_min, c.f_max,c.map_y_size);
        for x=1:c.map_x_size
            for y=1:c.map_y_size
                out_map(i,y,x)= map_transform(sum(sum(map_linear(1+(y-1)*DF:y*DF,1+(x-1)*DT:x*DT) ))  , c.ENERGY_SCALE);
            end
        end
    end
end






function [tfr,t,f]=scalo_jz(X,time,wave,fmin,fmax,N)
FAST=1;
t=time;
tcol=length(time);
X=X(1:tcol);
s = (real(X) - mean(real(X)))';
z = hilbert(s) ;
%wt =zeros(N,tcol);
tfr=zeros(N,tcol);
if fmin==0
    disp('fmin MUST be greater then 0 for CWT')
    return
end
f = linspace((fmin),(fmax),N);
a = f(end)./f;

si_f=f/wave; % 40; % 7 wsp.czestosci do szerokosci
si_t=1./(2*pi*si_f);
A=1./sqrt(si_t*sqrt(pi));
AA=sqrt(2)./A;
BB=-2*pi*pi;

    xhat=fft(z); % to do liczenia splotow w dzidzinie czestosci
    len_fft=length(xhat);
    xhat=xhat/sqrt(len_fft);
    if mod(tcol,2)==0
        f_scale= [ (0: (tcol/2)) (((-tcol/2)+1):-1) ] .* (1/tcol);
    else
        f_scale= [ (0: ((tcol-1)/2)) (((-(tcol+1)/2)+1):-1) ] .* (1/tcol);
    end
    

for ptr=1:N,
        window=AA(ptr)*exp(BB*(f_scale-f(ptr)).^2*si_t(ptr)^2);
        what = window .* xhat;
        w    = ifft(what);
        tfr(ptr,:)  = abs(w);

    
end




