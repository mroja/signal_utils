function p=p_perm_test(mapa, c, name)
% PURE RESAMPLING -- PERMUATTION TESTS


p_filename=sprintf('calc_p/%s%sNb%dref%d-%dpPerm.mat', name,  lower(c.ENERGY_SCALE), c.Nboot, c.ref(1), c.ref(length(c.ref)));
disp(sprintf('stats: %s', p_filename));

if exist(p_filename)==2
    ref1=c.ref;
    load(p_filename);
    % check whether the same reference regions were used in config and p-file
    % -- redundant, now ref included in p file name
    if length(ref)~=length(ref1) 
        disp('in file:');    disp(ref)
        disp('in config:');   disp(ref1)
        error('different reference used in stored file')
    else if ref~=ref1
            disp('in file:');    disp(ref)
            disp('in config:');   disp(ref1)
            error('different reference used in stored file')
        end
    end
    
else
    p=zeros(c.map_y_size, c.map_x_size);
    for f=1:c.map_y_size
        %matrix of values in the reference region
        rr=zeros(c.N*length(c.ref),1);
        for i=1:c.N:c.N*length(c.ref)
            rr(i:i+c.N-1) =mapa(:,f,c.ref(ceil(i/c.N)));
        end
        mean_rr=mean(rr);
        for i=c.ref(length(c.ref))+1:c.map_x_size
            %point for which difference is assesed
            point=mapa(:,f,i);
            %h=meandiff_perm(rr, point, c.Nboot);
            h=meandiff_perm(point, rr, c.Nboot); %chyba w tej kolejnosci HAK
            realmean=mean(point)-mean_rr;
            if realmean>0
                p(f,i)=sum(h>=realmean)/c.Nboot;
            else
                p(f,i)=sum(h<=realmean)/c.Nboot;
            end
            disp(sprintf('%d/%d %d/%d  %9.2f %9.2f   p=%12.9f', f, c.map_y_size, i, c.map_x_size, mean(rr), mean(point), p(f,i)) )
        end
    end
    ref=c.ref;
    save(p_filename, 'p', 'ref') 
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function m=meandiff_perm(a, b, N)
s_a=length(a);
s_b=length(b);
s=s_a+s_b;
s_min = min(s_a, s_b);
s_max = max(s_a, s_b);
reverse = (s_min<s_a);
v=zeros(s,1);
v(1:s_a)=a;
v(s_a+1:s)=b;
m=zeros(1,N);%HAK 22.01.2003
K1=s/(s_min*s_max);
K2=1/s_max*sum(v);
idx = zeros(1,s);
for i=1:N
    [dummy, idx] = sort(rand(1,s)); %HAK bez powtorzen
    %idx = ceil(s*rand(1,s_min)); %HAK z powtorzeniami
    v_min=v(idx(1:s_min));
    %vp=v(randperm(s));
    %m(i)=mean(vp(1:s_a))-mean(vp(s_a+1:s));
    m(i)=K1*sum(v_min)-K2;%HAK
end
if reverse
    m = -m;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function m=meandiff_perm_old(a, b, N)
s_a=length(a);
s_b=length(b);
s=s_a+s_b;
v=zeros(s,1);
v(1:s_a)=a;
v(s_a+1:s)=b;
for i=1:N
    vp=v(randperm(s));
    m(i)=mean(vp(1:s_a))-mean(vp(s_a+1:s));
end
