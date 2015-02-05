function [out_map,t,f] =calculate_maps_CWT(config, name, res_max)

eval(config); %read the same parameters as the main function

Xsize=Tsize;
Ysize=Fsize;
VOICES=Ysize;
xx=(1:Xsize);
yy=(1:Ysize);
FS = sampling;
WAVE=dt*FS/2;
%map_filename=sprintf('calc_map/%s.mat', name);
%if exist(map_filename)~=2 %jesli plik nie istnieje
%    fo=fopen(map_filename,'wb');
%    if fo==-1 
%        disp('error opening map file for writing');
%        return;
%    end
    
eval(read_raw_data); %wczytanie danych wg recepty z config'a
mapaXY=zeros(Xsize,Ysize);
map_linear=zeros(Ysize,Xsize);
map_transformed=zeros(Ysize,Xsize);
if res_max==1
    out_map=zeros(Ysize,Xsize);
else
    out_map=zeros(N,map_y_size,map_x_size);
end

for i=1:N
    %drawing single map
    fprintf(1,'map1:%3d/%-3d\n',i,N);
    X=data(i,:)';
    [mapaXY,xx,yy,WT_jz]=scalo_jz(X,xx,WAVE,f_min/sampling,f_max/sampling,VOICES ); 
  %  fwrite(fo,mapaXY','double');
    pause(0);
    %end
%fclose(fo);
fprintf(1,'\n');
%end %jesli plik nie istnieje
%tu plik juz istnieje
%fid=fopen(map_filename,'rb');
%if fid==-1
%    disp('error opening map file for reading');
%    return;
%end



for i=1:N
    map_linear = fread(fid,[Xsize, Ysize],'double')';
    if res_max==1
        map_transformed=map_transform(map_linear, ENERGY_SCALE);
        out_map = out_map+map_transformed/N;
    else
        DT=dt*sampling;
        DF=floor(df/(sampling/2)*dimBase/2);
        for x=1:map_x_size
            for y=1:map_y_size
                out_map(i,y,x)= sum(sum(map_linear(1+(y-1)*DF:y*DF,1+(x-1)*DT:x*DT) ))  ;
            end
        end
    end
end
fclose(fid);





function [tfr,t,f,wt]=scalo_jz(X,time,wave,fmin,fmax,N) 
FAST=1
t=time;
tcol=length(time);
X=X(1:tcol);
s = (real(X) - mean(real(X)))';  
z = hilbert(s) ;
wt =zeros(N,tcol);
tfr=zeros(N,tcol);
if fmin==0 
    disp('fmin MUST be greater then 0 for CWT')
    return
end
f = linspace((fmin),(fmax),N);
a = f(end)./f;

si_f=f/7; % 7 wsp.czestosci do szerokosci
si_t=1./(2*pi*si_f);
A=1./sqrt(si_t*sqrt(pi));
AA=sqrt(2)./A;
BB=-2*pi*pi;
if FAST==1
    xhat=fft(z); % to do liczenia splotow w dzidzinie czestosci
    len_fft=length(xhat);
    xhat=xhat/sqrt(len_fft);
    f_scale= [ (0: (tcol/2)) (((-tcol/2)+1):-1) ] .* (1/tcol);
end
for ptr=1:N,
    if FAST==1  
        window=AA(ptr)*exp(BB*(f_scale-f(ptr)).^2*si_t(ptr)^2);
        what = window .* xhat;
        w    = ifft(what);
        wt(ptr,:)  = w;
        tfr(ptr,:)  = w.*conj(w);
    else
        nha = wave*a(ptr);
        tha = -round(nha) : round(nha);
        ha  =exp(-(2*log(10)/nha^2)*tha.^2).*exp(i*2*pi*f(ptr)*tha)/sqrt(nha*sqrt(pi/(4*log(10))) ) ;
        detail = conv(z,ha);
        detail = detail(round(nha)+1:length(detail)-round(nha)) ;
        wt(ptr,:)  = detail(time) ;
        tfr(ptr,:) = detail(time).*conj(detail(time))/N/4;
    end
    
end


function y = map_transform(x, energy_scale)

switch energy_scale
    case 'LIN'
        y = x;
    case 'LOG'
        y = log((x+1));
    case 'SQRT'
        y =sqrt(x);
    otherwise
        error('unknown energy scale type');
end


