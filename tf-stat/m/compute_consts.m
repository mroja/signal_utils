function c=compute_consts(c)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%		        THE END
%		 OF THE EDITABLE PART
%                       !!!!!
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CALCULATING SOME CONSTANTS %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% the part below should not be changed %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



switch c.MAP_TYPE
    case 'SP'
        c.NFFT = floor(c.dt*c.sampling*2);
        c.FFT_window = hanning(c.NFFT);
        if mod(c.NFFT,2)==0
            c.df = c.sampling/2/(c.NFFT/2+1); %round((c.f_max-c.f_min)/c.df);
        else
            c.df = c.sampling/((c.NFFT+1));
        end
        if c.MAX_RES==0; 	% obliczamy dla low_res
            c.NOVERLAP = ceil(c.NFFT/2);
        else% obliczamy dla high res
            c.NOVERLAP = c.NFFT-1;%ceil(c.NFFT/2);
        end
        disp(sprintf('dt: %f NFFT %f, df: %f',c.dt,c.NFFT,c.df ))
    case {'MP', 'CWT'}
        c.df =  1/(2*c.dt);
    otherwise
        %wpisujemy
        c.df = 0.5; %1/(4*pi*c.dt);%1;
end

% tu korekta parametrów
[c.dt, c.df, c.f_min, c.f_max, c.tmin, c.tmax]=correction_mp2tf(c.dimBase, c.sampling, c.correction_mode, c.dt, c.df, c.f_min, c.f_max, c.tmin, c.tmax);
% tu korekta parametrów

%dla "nieciekawych parametrów trzeba zaokraglenia
% minT=tmin*sampling; % czas poczatku mapy w punktach probkowania
% maxT=tmax*sampling;  % czas konca mapy w punktach probkowania
% minF=f_min*(dimBase)/sampling;
% maxF=f_max*(dimBase)/sampling;
c.minT=round(c.tmin*c.sampling); % czas poczatku mapy w punktach probkowania
c.maxT=round(c.tmax*c.sampling);  % czas konca mapy w punktach probkowania
c.minF=round(c.f_min*(c.dimBase)/c.sampling);
c.maxF=round(c.f_max*(c.dimBase)/c.sampling);

c.t=1:c.maxT-c.minT; % skala czasu w punktach
c.f=1:c.maxF-c.minF; % skala czestosci w punktach
c.Tsize=length(c.t);
c.Fsize=length(c.f);


c.map_x_size = round((c.tmax-c.tmin)/c.dt);
c.map_y_size = round((c.f_max-c.f_min)/c.df);
if (strcmp(c.MAP_TYPE,'SP')) & (c.MAX_RES==1)
      c.NFFT = floor(c.dt*c.sampling*2);
      c.FFT_window = hanning(c.NFFT);
      c.NOVERLAP = c.NFFT-1;
    %B with NFFT/2+1 rows for NFFT even and (NFFT+1)/2 rows  for NFFT odd. 
    if mod(c.NFFT,2)==0 
        c.map_y_size =(c.f_max-c.f_min)/c.sampling*2* (c.NFFT/2+1); %round((c.f_max-c.f_min)/c.df); 
        c.df = c.sampling/2/(c.NFFT/2+1); %round((c.f_max-c.f_min)/c.df);
    else
        c.map_y_size = (c.f_max-c.f_min)/c.sampling*2*((c.NFFT+1)/2);
        c.df = c.sampling/2/((c.NFFT+1)/2); %round((c.f_max-c.f_min)/c.df);
    end
    c.map_y_size=round(c.map_y_size);
	c.Fsize=c.map_y_size ;
  %  c.map_x_size=fix((c.dimBase-c.NOVERLAP)/(c.NFFT-c.NOVERLAP));

end
if (strcmp(c.MAP_TYPE,'SP')) & (c.MAX_RES==0)
	c.Fsize=c.map_y_size ;
end

c.ref = round(c.ref_sec(1)/c.dt)+1:round(c.ref_sec(2)/c.dt);  % points in the reference period
c.left_time_margin_px=floor(c.left_time_margin/c.dt+0.5);
c.right_time_margin_px=floor(c.right_time_margin/c.dt+0.5);






% labelsy poszly do rst4
if c.FULL_PRES==1 & strcmp(c.MAP_TYPE,'MP')
    c.NS=3;                   % vertical number of subplots
    c.NSx = 2;                % horizontal number of subplots
elseif c.FULL_PRES==-1 & strcmp(c. MAP_TYPE,'SP')
    c.NS=1;
    c.NSx=2;
else
    c.NS=1;
    c.NSx=3;
end

c.base_name=sprintf('%s_%s',c.base_name,c.MAP_TYPE);
