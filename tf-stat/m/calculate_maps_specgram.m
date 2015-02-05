function [out_map,t,f]=calculate_maps_specgram(c, res_max);
Xsize=c.Tsize;
Ysize=c.map_y_size;


DX=c.Tsize/Xsize;
DY=c.Fsize/Ysize;

xx=(1:Xsize)+floor(c.minT/DX);%+floor((c.NOVERLAP-1)/(2*(c.NFFT-c.NOVERLAP)));
yy=(1:Ysize)+floor(c.f_min/c.df);
FS = c.sampling;

eval(c.read_raw_data); %wczytanie danych wg recepty z config'a
if res_max==1
    out_map=zeros(Ysize,Xsize);
else
    out_map=zeros(c.N,c.map_y_size,c.map_x_size);
end

for i=1:c.N
    %drawing single map
    if mod(c.NFFT,2)==0
        [sgram, f, t] = specgram([zeros(1,(c.NOVERLAP+1)/2) data(i,:) zeros(1,(c.NOVERLAP-1)/2);], c.NFFT, FS, c.FFT_window, c.NOVERLAP); %przeliczenie defaultowego spektrogramu
    else
        [sgram, f, t] = specgram([zeros(1,c.NOVERLAP/2+1) data(i,:) zeros(1,c.NOVERLAP/2)], c.NFFT, FS, c.FFT_window, c.NOVERLAP); %przeliczenie defaultowego spektrogramu
    end
    %obliczenie mocy
    sgram_power = abs(sgram); % tak to powinno byc w skali liniowej
    map_linear=sgram_power(yy,xx); %wycinamy ten kawalek mapy co trzeba
    if res_max==1
        out_map = out_map+map_transform(map_linear, c.ENERGY_SCALE)/c.N;
    else
        DT=c.dt*c.sampling;
        % DF=floor(c.df/(c.sampling/2)*c.dimBase/2);
        t=linspace(c.tmin,c.tmax,c.map_x_size);
        f=linspace(c.f_min, c.f_max,c.map_y_size);
        tmp_map=zeros(c.map_y_size,c.map_x_size);
        for x=1:c.map_x_size
            for y=1:c.map_y_size
                tmp_map(y,x)= (sum(map_linear(y,1+(x-1)*DT:x*DT) ))  ;%out_map(i,y,x)
            end
        end
        out_map(i,:,:)=map_transform(tmp_map, c.ENERGY_SCALE);%map_linear
    end
end

t=t/FS;
f=f*FS/c.dimBase;

