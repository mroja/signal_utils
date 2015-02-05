function [newDt, newDf, newminF, newmaxF, newminT, newmaxT]=correction_mp2tf(dimBase, Fsamp, params, Dt, Df, minF, maxF, minT, maxT)

%Input parameters
% dimBase  - number of points in single epoch
% Fsamp    - sampling frequency in Hz
% params = '(strict resel|strict limits),(real|points))'
% % (strict resel|strict limits)
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
[p_strict_limits, p_strict_resel, p_real, p_points] = set_params2(params);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%ew. przeliczenie Dt, Df, minF, maxF, minT, maxT z czestosci na punkty 
if p_real == 1
    Df = round(Df*deltaf);
    Dt = round(Dt*Fsamp);
    minF = round(minF*deltaf);
    maxF = floor(maxF*deltaf); %round(maxF*deltaf);
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


if p_real==1
    newDt = Dt/Fsamp;
    newminT = minT/Fsamp;
    newmaxT = maxT/Fsamp;
    newDf = Df/deltaf;
    newminF = minF/deltaf;
    newmaxF = maxF/deltaf;
else
    [newDt, newDf, newminF, newmaxF, newminT, newmaxT]=deal(Dt, Df, minF, maxF, minT, maxT);
end

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
function [p_strict_limits, p_strict_resel, p_real, p_points] = set_params2(params)

% start values
p_strict_limits=0;
p_strict_resel=0;
p_real=0;
p_points=0;

% parsing
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
if p_strict_limits==1 & p_strict_resel==1
    error('Inconsistency in params: "strict limits" and "strict resel"');
elseif p_strict_limits==0 & p_strict_resel==0
    disp('using strict limits')
    p_strict_limits = 1;
end

if p_real==1 & p_points==1
    error('Inconsistency in params: "points" and "real"');
elseif p_real==0 & p_points==0
    disp('using points');
    p_points = 1;
end

return; %end of set_params2


