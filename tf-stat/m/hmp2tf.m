function [wigXY,xx,yy]=mp2tf(book, header, params, Dt, Df, minF, maxF, minT, maxT)
%function [wigXY,xx,yy]=mp2tf(book, header, Dt, Df, minF, maxF, minT, maxT)
% minF, maxF, minT, maxT, dt, df -- in samples

%Input parameters
% book - book of atoms
% header - header of signal
%Algorithm paramters
% params = '(exp|integral), (no correction |(strict resel|strict limits),(real|points))'
% (exp|integral)
% exp - no interpolation; energy of an atom is proportional to gaussian function     
% integral - integral interpolation; energy of an atom is proportional to
%            integral from a gaussian function taken betwwen two nearest points on a
%            grid
% (strict resel|strict limits)
% strict resel - trims the signal in order to preserve the value
% of given resel
% strict limit - size of resel is adapted in order to preserve the value
% of signal size
% (real|points)
% points - minF, maxF, minT, maxT, dt, df are defined in points/bits
% real - minF, maxF, minT, maxT, dt, df are defined in sec/Hz  
%Signal parameters
% minF, maxF, minT, maxT, dt, df - could be defined in points/bits or sec/Hz 
%

H_SAMPLING_FREQ=1;
H_SIGNAL_SIZE=2;

dimBase=header(H_SIGNAL_SIZE);
Fsamp=header(H_SAMPLING_FREQ);


deltaf=dimBase/Fsamp;% konwersja Hz na punkty

defminF=0;
defmaxF=dimBase/2;
defminT=0;
defmaxT=dimBase;

if nargin<6
    minF=defminF;
    maxF=defmaxF;
    minT=defminT;
    maxT=defmaxT;
end
if nargin<4
    Dt=1;
    Df=1;
end
if nargin<3
    params='';
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Setting params:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[p_int, p_exp, p_strict_limits, p_strict_resel, p_real, p_points, p_no_correction] = set_params(params);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%ew. przeliczenie Dt, Df, minF, maxF, minT, maxT z czestosci na punkty 
if p_real == 1
    Df = round(Df*deltaf);
    Dt = round(Dt*Fsamp);
    minF = round(minF*deltaf);
    maxF = round(maxF*deltaf);
    minT = round(minT*Fsamp);
    maxT = round(maxT*Fsamp);
end;

% od tej pory wyrazamy sie w punktach

%check for arguments inconsistency:
if maxT==floor(abs(maxT)) & maxT<=defmaxT & ...
        minT==floor(abs(minT)) & minT>=defminT & ...
        maxF==floor(abs(maxF)) & maxF<=defmaxF & ...
        minF==floor(abs(minF)) & minF>=defminF & ...
        Dt==floor(abs(Dt)) & Dt>=1 & Dt<=maxT-minT & ...
        Df==floor(abs(Df)) & Df>=1 & Df<=maxF-minF & ...
        maxT>minT & maxF>minF
    %ok
    1;
else
    disp(sprintf('(Dt, Df, minF, maxF, minT, maxT) == (%d, %d, %d, %d, %d, %d)\n',Dt, Df, minF, maxF, minT, maxT));
    error('Some of arguments (Dt, Df, minF, maxF, minT, maxT) (in points) not an integer or out of bounds');
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Setting t, f, Tsize, Fsize, Xsize and Ysize
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% At first before correction:
t=1:maxT-minT; % time scale in points
f=1:maxF-minF; % frequency scale in points
Tsize=length(t);
Fsize=length(f);
Xsize=(maxT-minT)/Dt;
Ysize=(maxF-minF)/Df;

%for debug diplay:
%disp('before correction:')
%disp(sprintf('(Dt, Df, minF, maxF, minT, maxT) == (%d, %d, %d, %d, %d, %d)\n',Dt, Df, minF, maxF, minT, maxT));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% possible correction:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if p_no_correction==0
    if p_strict_limits==1
        % possible resel size change
        % minF, maxF, minT, maxT unchanged
        % Df, Dt may change
        if mod(Tsize,Xsize)~=0 | Xsize~=floor(Xsize)
            Dtcor=1:Tsize;
            Dtcor=Dtcor(mod(Tsize,Dtcor)==0);
            disp(sprintf('wrong Dt=%d, possible values are:', Dt));
            disp(sprintf('%d, ',Dtcor));
            %    error('... so the end');
            Dt=max(Dtcor(abs(Dtcor-Dt)==min(abs(Dtcor-Dt)))); %new Dt, in case of 2 candidates greater is chosen
            disp(sprintf('... taking nearest possible: %d\n', Dt));
        end
        if mod(Fsize,Ysize)~=0 | Ysize~=floor(Ysize)
            Dfcor=1:Fsize;
            Dfcor=Dfcor(mod(Fsize,Dfcor)==0);
            disp(sprintf('wrong Df=%d, possible values are:', Df));
            disp(sprintf('%d, ',Dfcor));
            %    error('... so the end');
            Df=max(Dfcor(abs(Dfcor-Df)==min(abs(Dfcor-Df)))); %new Df, in case of 2 candidates greater is chosen
            disp(sprintf('... taking nearest possible: %d\n', Df));
        end
    elseif p_strict_resel==1
        % possible limits change
        % minF, maxF, minT, maxT may change
        % Df, Dt unchanged
        if mod(Tsize,Xsize)~=0 | Xsize~=floor(Xsize)
            % Tsize correction:
            % first attempt - bigger area
            for minTcor=minT:-1:defminT
                maxTcor=maxT:defmaxT;
                Tsizecor=(maxTcor-minTcor);
                idx=(mod(Tsizecor,Dt)==0);
                [Tsize, m_idx]=min(Tsizecor(idx));
                if ~isempty(Tsize)
                    minT=minTcor;
                    maxT=maxTcor(idx);
                    maxT=maxT(m_idx);
                    break
                end
            end
            if isempty(Tsize)
                % second attempt - smaller area
                for minTcor=minT:-1:defminT
                    maxTcor=minTcor:maxT;
                    Tsizecor=(maxTcor-minTcor);
                    idx=(mod(Tsizecor,Dt)==0);
                    [Tsize, m_idx]=max(Tsizecor(idx));
                    if ~isempty(Tsize)
                        minT=minTcor;
                        maxT=maxTcor(idx);
                        maxT=maxT(m_idx);
                        break
                    end
                end
            end
            if isempty(Tsize)
                error('Correction minT and maxT limits failed');
            end
            if p_real==1
                disp(sprintf('Assumed time limits: minT=%-5.2f   maxT=%-5.2f\n', minT/Fsamp, maxT/Fsamp));
            else
                disp(sprintf('Assumed time limits: minT=%d   maxT=%d\n', minT, maxT));
            end
        end
        if mod(Fsize,Ysize)~=0 | Ysize~=floor(Ysize)
            % Tsize correction:
            % first attempt - bigger area
            for minFcor=minF:-1:defminF
                maxFcor=maxF:defmaxF;
                Fsizecor=(maxFcor-minFcor);
                idx=(mod(Fsizecor,Df)==0);
                [Fsize, m_idx]=min(Fsizecor(idx));
                if ~isempty(Fsize)
                    minF=minFcor;
                    maxF=maxFcor(idx);
                    maxF=maxF(m_idx);
                    break
                end
            end
            if isempty(Fsize)
                % second attempt - smaller area
                for minFcor=minF:-1:defminF
                    maxFcor=minFcor:maxF;
                    Fsizecor=(maxFcor-minFcor);
                    idx=(mod(Fsizecor,Df)==0);
                    [Fsize, m_idx]=max(Fsizecor(idx));
                    if ~isempty(Fsize)
                        minF=minFcor;
                        maxF=maxFcor(idx);
                        maxF=maxF(m_idx);
                        break
                    end
                end
            end
            if isempty(Fsize)
                error('Correction minF and maxF limits failed');
            end
            if p_real==1
                disp(sprintf('Assumed frequency limits: minF=%-6.2f   maxF=%-6.2f\n', minF/deltaf, maxF/deltaf));
            else
                disp(sprintf('Assumed frequency limits: minF=%d   maxF=%d\n', minF, maxF));
            end
        end
    else
        error('Inconsistency in params: none of "strict limits" and "strict resel"');
    end
end
    
%for debug diplay:
%disp('after correction:')
%disp(sprintf('(Dt, Df, minF, maxF, minT, maxT) == (%d, %d, %d, %d, %d, %d)\n\n',Dt, Df, minF, maxF, minT, maxT));

% At last after correction
t=1:maxT-minT; % time scale in points
f=1:maxF-minF; % frequency scale in points
Tsize=length(t);
Fsize=length(f);
Xsize=(maxT-minT)/Dt;
Ysize=(maxF-minF)/Df;


% Test for proper correction
% just in case ;-)

if mod(Tsize,Xsize)~=0 | Xsize~=floor(Xsize)
    disp(sprintf('wrong Xsize, possible values are: \n'));
    for i=1:Tsize
        if mod(Tsize,i)==0
            disp(i)
        end
    end
    error('... so the end');
elseif mod(Fsize,Ysize)~=0 | Ysize~=floor(Ysize)
    disp(sprintf('wrong Ysize, possible values are: \n'));
    for i=1:Fsize
        if mod(Fsize,i)==0
            disp(i)
        end
    end
    error('... so the end');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% end of setting t, f, Tsize, Fsize, Xsize and Ysize
% and possible corrections
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% CAUTION: the values below are correct only if the MP decomposition
% was calculated with border conditions as zeros outside
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
book_min_t_points = 0;
book_max_t_points = dimBase;
book_min_f_points = 0;
book_max_f_points = dimBase/2;

[wigXY, xx, yy] = deal([],[],[]);

% tlow = (t-1); %granice calkowania - male piksele
% tupp = t;  %granice calkowania - male piksele
%
% flow = (f-1); %granice calkowania - male piksele
% fupp = f; %granice calkowania - male piksele
%
% wig=zeros(Tsize,Fsize);
% wigTF=zeros(Tsize,Fsize);

DX=Tsize/Xsize;
DY=Fsize/Ysize;
tx=minT+t(1:DX:Tsize); %brzegi duzych pikseli na osi czasu
fy=minF+f(1:DY:Fsize); %brzegi duzych pikseli na osi czestosci


if p_exp==1
    tmedx = tx-1+DX/2; % srodki duzych pikseli na osi czasu (T==>X) do liczenia
    fmedy = fy-1+DY/2; % srodki duzych pikseli na osi czestosci (F==>Y) do liczenia
else
    tlowx = ((tx-1)); %granice calkowania - duze piksele
    tuppx = ( tx-1 + DX); %granice calkowania - duze piksele
    
    flowy = ((fy-1));  %granice calkowania - duze piksele
    fuppy = ( fy-1 + DY);  %granice calkowania - duze piksele
end;

xx = tx+DX/2; % srodki duzych pikseli na osi czasu (T==>X) do wypisania wyniku
yy = fy+DY/2; % srodki duzych pikseli na osi czestosci (F==>Y) do wypisania wyniku

PI4=4.0*pi;
SQRT_PI = sqrt(pi);
BI_SQRT_PI = 2*SQRT_PI;
num_atom=size(book, 1);

wigXY=zeros(Xsize,Ysize);
wig_gabXY=sparse([]);

hm = floor((num_atom/10):(num_atom/10):num_atom); %for info display
tic
for k=1:num_atom
    toc
    %    disp(sprintf('atom %d',k));
    modulus=book(k,4);
    amplitude=book(k,5)/2;
    scale=book(k,1)*Fsamp; % skala atomu  w punktach
    freq=(deltaf*book(k,2));   % czestosc atomu w punktach
    trans=(book(k,3)*Fsamp); %pozycja atomu w punktach
    u=book(k,3); %u=trans/Fsamp;
    
    if scale~=0
        if scale==dimBase % sinus
            idx = 1+floor((freq-minF)/DY);
            if (idx>0) & (idx<=length(fy))
                freqXY=fy(idx);  % przesuwamy czestosc - floor -zeby pasowala do siatki wig, +1 bo w matlabie macierze maja indeksy od 1
                if (freqXY>=1) & (freqXY<=Ysize)
                    wigXY(:,freqXY)=wigXY(:,freqXY)+(modulus^2)/Tsize; % normalizacja HAK
                end;
            end;
        else %gabor
            %f_scale=PI4*(dy*scale/(2.0*pi))^2;
            %             gab_t=exp(-PI4 * ((t-(trans+1))/scale).^2 )';
            %             gab_f= exp(-pi*(scale/dimBase*(f-(freq+1))).^2);
            
            %          gab_t=exp(-PI4 * ((t-(trans+0.5))/scale).^2 )'; %popr. HAK
            %          gab_f= exp(-pi*(scale/dimBase*(f-(freq+0.5))).^2); %popr. HAK
            %
            %          wig_gab=kron(gab_t, gab_f);
            %          NORM=sum(sum(wig_gab));
            %          if NORM~=0
            %             wig=wig+modulus.^2*wig_gab/NORM;
            %          end
            
            
            %liczenie w osiach TxF
            %          g1=(BI_SQRT_PI/scale)*(tlow - trans);
            %          g2=(BI_SQRT_PI/scale)*(tupp - trans);
            %          hgab_t=(scale/4)*(erf(g2)-erf(g1))';
            %
            %          gf1=(SQRT_PI*scale/dimBase)*(flow - freq);
            %          gf2=(SQRT_PI*scale/dimBase)*(fupp - freq);
            %          hgab_f=0.5*(dimBase/scale)*(erf(gf2)-erf(gf1));
            %
            %          wig_gabTF=kron(hgab_t, hgab_f);
            %
            %          NORM_TF=sum(sum(wig_gabTF));
            %          if NORM_TF~=0
            %             wigTF=wigTF+modulus.^2*wig_gabTF/NORM_TF;
            %          end
            
            %liczenie w osiach XxY
            if p_exp == 1
                gmed=(BI_SQRT_PI/scale)*(tmedx - trans);
                gfmed=(SQRT_PI*scale/dimBase)*(fmedy - freq);

                hgab_tx=4*(exp(-gmed.*gmed))'; %normowanie ponizej
                hgab_fy=(2/dimBase)*(exp(-gfmed.*gfmed));%normowanie ponizej
            else
                g1=(BI_SQRT_PI/scale)*(tlowx - trans);
                g2=(BI_SQRT_PI/scale)*(tuppx - trans);
                %hgab_tx=(scale/4)*(erf(g2)-erf(g1))';
                gf1=(SQRT_PI*scale/dimBase)*(flowy - freq);
                gf2=(SQRT_PI*scale/dimBase)*(fuppy - freq);
                %hgab_fy=0.5*(dimBase/scale)*(erf(gf2)-erf(gf1));
                hgab_tx=(erf(g2)-erf(g1))'; %normowanie ponizej
                hgab_fy=(erf(gf2)-erf(gf1));%normowanie ponizej
            end;
            
            wig_gabXY=fkron(hgab_tx, hgab_fy);%sparse(hgab_tx), sparse(hgab_fy));
            %           wig_gabXY=kron(hgab_tx, hgab_fy);
            %NORM_XY=sum(sum(wig_gabXY));
            
            g1_book=(BI_SQRT_PI/scale)*(book_min_t_points - trans);
            g2_book=(BI_SQRT_PI/scale)*(book_max_t_points - trans);
            gf1_book=(SQRT_PI*scale/dimBase)*(book_min_f_points - freq);
            gf2_book=(SQRT_PI*scale/dimBase)*(book_max_f_points - freq);
            
            %calka z czesci atomu ktora jest w granicach liczenia ksiazki MP
            NORM_XY = (erf(g2_book)-erf(g1_book))*(erf(gf2_book)-erf(gf1_book));
            if NORM_XY~=0
                wigXY=wigXY+modulus.^2*full(wig_gabXY)./NORM_XY;
            end
        end;
    else % dirac
        %       transTF=1+floor((trans-minT));% przesuwamy czestosc - floor -zeby pasowala do siatki wig,
        % +1 bo w matlabie macierze maja indeksy od 1
        idx = 1+floor((trans-minT)/DX);
        if (idx>0) & (idx<=length(tx))
            transXY=tx(idx);% przesuwamy czestosc - floor -zeby pasowala do siatki wig,
            % +1 bo w matlabie macierze maja indeksy od 1
            if transXY>=1 & transXY<=Xsize
                wigXY(transXY,:)=wigXY(transXY,:)+(modulus^2)/Fsize; %normalizacja HAK
            end;
        end;
    end;
    if sum(hm==k)==1, fprintf(1,'*'); end
end;


%PJD
wigXY=wigXY';

fprintf(1,'\n');
xx=xx/Fsamp;
yy=yy*Fsamp/dimBase;
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%tools:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%function set_params:
% - parser for argument params of hmp2tf 
% - setting p_int, p_exp, p_strict_limits, p_strict_resels values
function [p_int, p_exp, p_strict_limits, p_strict_resel, p_real, p_points, p_no_correction] = set_params(params)

% start values
p_int=0;
p_exp=0;
p_strict_limits=0;
p_strict_resel=0;
p_real=0;
p_points=0;
p_no_correction=0;

% parsing
% integral vs. exp
if strfind(params, 'integral')
    p_int=1;
    params=strrep(params,'integral','');
end
if strfind(params, 'exp')
    p_exp=1;
    params=strrep(params,'exp','');
end
% if no correction
if strfind(params, 'no correction')
    p_no_correction=1;
    params=strrep(params,'no correction','');
end
% "strict limits" vs. "strict resel"
if strfind(params, 'strict limits')
    p_strict_limits=1;
    params=strrep(params,'strict limits','');
end
if strfind(params, 'strict resel')
    p_strict_resel=1;
    params=strrep(params,'strict resel','');
end
% "real" vs. "points"
if strfind(params, 'real')
    p_real=1;
    params=strrep(params,'real','');
end
if strfind(params, 'points')
    p_points=1;
    params=strrep(params,'points','');
end
% sprawdzenie, czy wyczerpane parametry
p1=unique([find(isspace(params)) ...
        strfind(params,',') ...
        strfind(params,';')]);
if length(p1) < length(params)
    % zostaly jakies znaczki
    p2=length(params)
    p1=deblank(strrep(strrep(strrep(strrep(params,' ,',','),' ;',';'),',,',','),';;',';'))
    while p2>length(p1)
        p2=length(p1)
        p1=deblank(strrep(strrep(strrep(strrep(p1,' ,',','),' ;',';'),',,',','),';;',';'))
    end
    warning(sprintf('unknown parameter name(s) in "params" argument: \n"%s"\n', p1));
end

% check inconsistency:
if p_int==1 & p_exp==1
    error('Inconsistency in params: "integral" and "exp" together');
elseif p_int==0 & p_exp==0
    disp('using integral')
    p_int = 1;
end

if p_strict_limits==1 & p_strict_resel==1
    error('Inconsistency in params: "strict limits" and "strict resel"');
elseif p_strict_limits==0 & p_strict_resel==0
    if p_no_correction==0
        disp('using strict limits')
        p_strict_limits = 1;
    end
end

if p_real==1 & p_points==1
    error('Inconsistency in params: "points" and "real"');
elseif p_real==0 & p_points==0
    if p_no_correction==0
        disp('using points');
        p_points = 1;
    end
end

return; %end of set_params


