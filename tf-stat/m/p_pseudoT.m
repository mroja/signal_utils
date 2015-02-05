function p3=p_pseudoT(mapa, c, name);
% CALCULATING PSEUDO-T AND PROBABILITIES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% version rev. 19.05.2004 by JZ
% change:
%           p=P(|T|>=|t|)) to 
%           if t<0 
%               p=2*P(T<=t)
%           else
%               p=2*P(T>=t)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


p3_filename=sprintf('calc_p/%s%sNb%dref%d-%dpPseudoT.mat', name,  lower(c.ENERGY_SCALE), c.Npseudot, c.ref(1), c.ref(length(c.ref)));

disp(sprintf('stats: %s', p3_filename));

mat_ver = str2num(version('-release'));

if exist(p3_filename)==2
    ref1=c.ref;
    load(p3_filename);
% check whether the same reference regions were used in config and p-file
% -- redundant, now ref included in p file name
    if length(cr)~=length(ref1)
        disp('in file:');    disp(c.ref)
        disp('in config:');   disp(ref1)
        error('different reference used in stored file')
    else if cr~=ref1
            disp('in file:');    disp(c.ref)
            disp('in config:');   disp(ref1)
            error('different reference used in stored file')
        end
    end

else
    r_length=length(c.ref);
    p3=zeros(c.map_y_size, c.map_x_size);
    N1=c.N*length(c.ref); % LENGTH OF THE REFERENCE VECTOR
    T_DF=(1/N1+1/c.N)/(N1+c.N-2);
    %t1=clock;
    h=zeros(c.Npseudot,1);
    pp1=zeros(N1,1);
    pp2=zeros(c.N,1);
    mean_pp1=0;
    mean_pp2=0;
    N1_var_pp1=0;
    N_var_pp2=0;
    rr=zeros(N1,1);
    if mat_ver >= 13
        % for Matlab R13 or later
        for f=1:c.map_y_size
            for i=1:c.N:N1
                rr(i:i+c.N-1) = mapa(:,f,c.ref(ceil(i/c.N)));
            end
            %ESTYMACJA ROZKLADU ROZNICY DWOCH PROB PRZED
            %losujemy ze zwracaniem dwie proby:
            % N i N*length(r[ef]r[egion]) elementow z rr
            % N*length(ref)=length(rr)
            
            %tic
            for k=1:c.Npseudot
                for m=1:N1
                    pp1(m)=rr(ceil(N1*rand));
                end
                for m=1:c.N
                    pp2(m)=rr(ceil(N1*rand));
                end
                mean_pp1=sum(pp1)/N1;
                mean_pp2=sum(pp2)/c.N;
                N1_var_pp1=sum((pp1-mean_pp1).*(pp1-mean_pp1));
                N_var_pp2=sum((pp2-mean_pp2).*(pp2-mean_pp2));
                h(k)=(mean_pp2-mean_pp1)/sqrt(T_DF*( N1_var_pp1+N_var_pp2) );
            end
            % disp(sprintf('t1=%5.3f\n', toc));
            
            % graph. output -- histograms (log) of values and distributions of statistics
            %         figure(3);
            %         subplot (map_y_size/4,8,2*(f-1)+1);
            %         EDGES=0:.2:6;
            %         bar(EDGES,log(histc(rr,EDGES)+1),'histc'); %title(sprintf('f=%d', f));
            %         set(gca,'xlim',[0 MAX_STAT_VAL],'xtick',[],'ytick',[]); %!!!! ARBITRARY VALUES read from config
            %         subplot (map_y_size/4,8,2*(f-1)+2);
            %         EDGES=-MAX_STAT_VAL:.1:MAX_STAT_VAL;
            %         bar(EDGES,histc(h,EDGES),'histc'); %title(sprintf('f=%d', f));
            %         set(gca,'xlim',[-MAX_STAT_VAL MAX_STAT_VAL],'xtick',[],'ytick',[]); %!!!! ARBITRARY VALUES read from config
            %         pause(0.01);
            
            mean_rr=mean(rr); var_rr=var(rr);
            for i=c.ref(length(c.ref))+1:c.map_x_size
                point=mapa(:,f,i); % point for which difference is assesed
                point_t=(mean(point)-mean_rr)/sqrt( T_DF*((N1-1)*var_rr+(c.N-1)*var(point)) );
                if point_t<0 % czyli mamy spadek energii
                    p3(f,i)=(sum(h<=point_t))/c.Npseudot*2; % to mnozenie przez dwa bo test dwustronny
                else
                     p3(f,i)=(sum(h>=point_t) )/c.Npseudot*2; % to mnozenie przez dwa bo test dwustronny
                end
                % disp(sprintf('%d/%d %d/%d  d:%8.2f   p=%8.5f', f, map_y_size, i, map_x_size, mean(rr)-mean(point), p3(f,i)) )
            end
            disp(sprintf('%d/%d', f, c.map_y_size));
        end
        
    else
        
        for f=1:c.map_y_size
            %matrix of values in the reference region
            %rr=zeros(N*length(ref),1);
            %         rr=zeros(N1,1);
            for i=1:c.N:N1
                rr(i:i+c.N-1) = mapa(:,f,c.ref(ceil(i/c.N)));
            end
            % ESTYMACJA ROZKLADU ROZNICY DWOCH PROB PRZED
            % losujemy ze zwracaniem dwie proby:
            % N i N*length(r[ef]r[egion]) elementow z rr
            % N*length(ref)=length(rr)
            
            % tic
            for k=1:c.Npseudot
                ind1=ceil(N1.*rand(N1,1));
                ind2=ceil(N1.*rand(c.N,1));
                pp1=rr(ind1);
                pp2=rr(ind2);
                mean_pp1=sum(pp1)/N1;
                mean_pp2=sum(pp2)/c.N;
                N1_var_pp1=sum((pp1-mean_pp1).*(pp1-mean_pp1));
                N_var_pp2=sum((pp2-mean_pp2).*(pp2-mean_pp2));
                h(k)=(mean_pp2-mean_pp1)/sqrt(T_DF*( N1_var_pp1+N_var_pp2) );
            end
            % disp(sprintf('t1=%5.3f\n', toc));
            
            % graph. output -- histograms (log) of values and distributions of statistics
            %         figure(3);
            %         subplot (map_y_size/4,8,2*(f-1)+1);
            %         EDGES=0:.2:6;
            %         bar(EDGES,log(histc(rr,EDGES)+1),'histc'); %title(sprintf('f=%d', f));
            %         set(gca,'xlim',[0 MAX_STAT_VAL],'xtick',[],'ytick',[]); %!!!! ARBITRARY VALUES read from config
            %         subplot (map_y_size/4,8,2*(f-1)+2);
            %         EDGES=-MAX_STAT_VAL:.1:MAX_STAT_VAL;
            %         bar(EDGES,histc(h,EDGES),'histc'); %title(sprintf('f=%d', f));
            %         set(gca,'xlim',[-MAX_STAT_VAL MAX_STAT_VAL],'xtick',[],'ytick',[]); %!!!! ARBITRARY VALUES read from config
            %         pause(0.01);
            
            %tic
            mean_rr=mean(rr); var_rr=var(rr);
            for i=c.ref(length(c.ref))+1:c.map_x_size
                point=mapa(:,f,i); %point for which difference is assesed
                point_t=(mean(point)-mean_rr)/sqrt( T_DF*((N1-1)*var_rr+(c.N-1)*var(point)) );
                %p3(f,i)=(sum(h>=abs(point_t))+sum(h<=-abs(point_t)))/c.Npseudot;
                if point_t<0 % czyli mamy spadek energii
                    p3(f,i)=(sum(h<=point_t))/c.Npseudot*2; % to mnozenie przez dwa bo test dwustronny
                else
                    p3(f,i)=(sum(h>=point_t) )/c.Npseudot*2; % to mnozenie przez dwa bo test dwustronny
                end

                %disp(sprintf('%d/%d %d/%d  d:%8.2f   p=%8.5f', f, map_y_size, i, map_x_size, mean(rr)-mean(point), p3(f,i)) )
            end
            disp(sprintf('%d/%d', f, c.map_y_size));
            %disp(sprintf('t2=%5.3f\n', toc));
        end
    end
    
    %czas=etime(clock,t1)
    %error('KONIEC');
    p3(:,1:c.ref(length(c.ref)))=ones(c.map_y_size, c.ref(length(c.ref)));
    cr=c.ref;
    save(p3_filename, 'p3', 'cr')
end
