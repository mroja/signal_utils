%  CONFIG
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                signal parameters,
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N = 41;                      %number of repetitions
dimBase = 400;               % number of points in single epoch
sampling = 200;               %sampling frequency in Hz
time_length = dimBase/sampling;       %time length in seconds
% for SP - function reading the selected channel into 'data'
%read_raw_data = 'fid=fopen(''DATA/fecaras_c22.bin'',''rb'');data=(fread(fid,[dimBase,N],''int16''))'';fclose(fid);';
% for MP
bookname = 'B/patfaces.b';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%		   MAPS
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ENERGY_SCALE  = 'LIN';              % 'LOG' or 'SQRT' or 'LIN'
MAP_TYPE     = 'MP';                   % 'SP' or 'MP'
dt = 0.2;                              % time width of resel in sec
left_time_margin=0.2;                    % number of seconds to skip on map ...
right_time_margin=0.2;                   % ... to avoid border problems
f_min = 2; 		% in Hz
f_max = 28;		% in Hz
tmin  = 0.3;		% in sec
tmax  = time_length-0.15;	% in sec

correction_mode = 'real, strict limits';
% params = '(exp|integral),(strict resel|strict limits),(real|points))'


calculating_maps_mode = 'integral, real, no correction';
% (exp|integral)

calculating_max_res_mode = 'exp, points, no correction';


% only for MP maps
filter_scale = [0 inf];	% in sec

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%                      STATISTICS
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
STATISTICS   = 'PSEUDO_T';              % 'PSEUDO_T' or 'PERM_TEST'
MULTIPLE_TEST_CORRECTION = 'FDR'; 	% or 'BH' or 'BY_COLUMN' or 'FDR' or 'FULL_BONFERRONI' or 'NONE'
p_level=0.05/2; 			% two-sided test
FDR_q=0.05/2;				% max % of falsely rejected true hyp. in FDR
Nboot    = 20000;                      % number of permutations in PERM_TEST
Npseudot = 20000;                      % number of rep. in estimating PSEUDO_T statistics
					% for the points in the reference period
ref_sec = [0.2 .4];          		% reference period in seconds

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%                         DISPLAY
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FULL_PRES=0;           % FULL PRESENTATION -- MORE PLOTS for MP
PLOT_FDR =0;           % opens extra window (2) for FDR display
numfreq = 10;          % number of frequency ticks on the axis - affects only display
num_time =5;          % number of TIMEticks on the axis - affects only display








%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%		        THE END 
%		 OF THE EDITABLE PART 
%                       !!!!!
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CALCULATING SOME CONSTANTS %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% the part below should not be changed %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% setting the frequency width of a resel  (Heisenberg box)
% requires extra checks so that integer number of resels fit into the time and frequency ranges

switch MAP_TYPE
    case 'SP'
        %obliczamy
        NFFT = dt*sampling*2;%2 bo 2=NFFT/(NFFT-NOVERLAP)
        FFT_window = hanning(NFFT);
        NOVERLAP = ceil(NFFT/2);
        df = sampling/NFFT;
    case 'MP'
        df =  1/(2*dt);
    otherwise
        %wpisujemy
        df = 0.5; %1/(4*pi*dt);%1;
end

% tu korekta parametrów
[dt, df, f_min, f_max, tmin, tmax]=correction_mp2tf(dimBase, sampling, correction_mode, dt, df, f_min, f_max, tmin, tmax);
% tu korekta parametrów

%dla "nieciekawych parametrów trzeba zaokr¹glenia
% minT=tmin*sampling; % czas poczatku mapy w punktach probkowania
% maxT=tmax*sampling;  % czas konca mapy w punktach probkowania
% minF=f_min*(dimBase)/sampling;
% maxF=f_max*(dimBase)/sampling;
minT=round(tmin*sampling); % czas poczatku mapy w punktach probkowania
maxT=round(tmax*sampling);  % czas konca mapy w punktach probkowania
minF=round(f_min*(dimBase)/sampling);
maxF=round(f_max*(dimBase)/sampling);

t=1:maxT-minT; % skala czasu w punktach
f=1:maxF-minF; % skala czestosci w punktach
Tsize=length(t);
Fsize=length(f);


map_x_size = round((tmax-tmin)/dt);
map_y_size = round((f_max-f_min)/df);

if mod(Tsize,map_x_size)~=0
    disp(sprintf('Wrong dt , possible values are: \n'));
    for i=1:Tsize
        if mod(Tsize,i)==0
            disp((tmax-tmin)/i)
        end
    end
    s=dbstack;
    error(sprintf('Please correct dt value in %s\n',s.name));
elseif mod(Fsize,map_y_size)~=0
    % df value correction
    if strcmp(MAP_TYPE,'MP');
       df_old = abs(df);
       i=1:Fsize;
       i=i(mod(Fsize,i)==0);
       df_new=abs((f_max-f_min)./i);
       df_new=df_new((df_new-df_old)>=0);
       df=df_new(end);
       if df ~= df_old
           disp(sprintf('Wrong df=%.4f value...\n...it was corrected to the nearest possible. New df=%.4f', df_old, df));
           map_x_size = round((tmax-tmin)/dt);
           map_y_size = round((f_max-f_min)/df);
       end
    end
end

ref = round(ref_sec(1)/dt)+1:round(ref_sec(2)/dt);  % points in the reference period
left_time_margin_px=floor(left_time_margin/dt+0.5);
right_time_margin_px=floor(right_time_margin/dt+0.5);

%%LABELS
fticklabels=f_min :(f_max-f_min)/numfreq:f_max;
ftick=0:map_y_size/numfreq:map_y_size;
ftick=ftick+0.5;

tticklabels=tmin:(tmax-tmin)/num_time:tmax;
ttick=0:map_x_size/num_time:map_x_size;
ttick=ttick+0.5;

test_tticklabels=ref_sec(2):(tmax-tmin)/num_time:tmax-right_time_margin;
test_ttick=0:map_x_size/num_time:map_x_size-right_time_margin_px-ref(end)-1;
test_ttick=test_ttick+0.5;

%%LABELS max res
fticklabels_max_res=fticklabels;
ftick_max_res=ftick*Fsize/map_y_size;
ftick_max_res=ftick_max_res+0.5;

tticklabels_max_res=tticklabels;
ttick_max_res=ttick*Tsize/map_x_size;
ttick_max_res=ttick_max_res+0.5;

test_tticklabels_max_res=test_tticklabels;
test_ttick_max_res=test_ttick*Tsize/map_x_size;
test_ttick_max_res=test_ttick_max_res+0.5;




% labelsy poszly do rst4
if FULL_PRES==1 & strcmp(MAP_TYPE,'MP')
    NS=3;                   % vertical number of subplots
    NSx = 2;                % horizontal number of subplots
elseif FULL_PRES==-1 & MAP_TYPE=='SP'
    NS=1;
    NSx=2;
else
    NS=1;
    NSx=3;
end


% set(gcf,'paperposition', [1 1 9 2.4]); print -deps jsp.eps
%

