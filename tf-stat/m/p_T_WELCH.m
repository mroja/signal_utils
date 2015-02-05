function p=p_T_WELCH(mapa, c, name);

p=zeros(c.map_y_size, c.map_x_size);
rej_map=zeros(c.map_y_size, c.map_x_size);

sum_ref=0;
sum_p=0;


ref_len=length(c.ref);
N_ref=c.N*ref_len;
rr=zeros(N_ref,1);

for f=1:c.map_y_size
    for i=1:c.N
        rr(1+(i-1)*ref_len:i*ref_len) = mapa(i,f,c.ref);
    end
    [rr,lam(f)]=b_c(rr);% box-cox normalization
    [h_rr, p_rr,ls,cv]=lillietest(rr,0.01);

    if h_rr == 1
        rej_map(f,c.ref)=1;
    end
    sum_ref=sum_ref+h_rr;
    for i=c.ref(end)+1:c.map_x_size
        point=mapa(:,f,i); % point for which difference is assesed
        % for this test we have to check normality of  rr and point
        point=b_c_transform(lam(f),point);
        [h_p, p_p,ls,cv]=lillietest(point,0.01);
        sum_p=sum_p+h_p;
        if h_p == 1
            rej_map(f,i)=1;
        end
        p(f,i)=welch_t(rr,point);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(4)
k=find(c.current_channel==c.m.chan);
if isfield(c.m,'v')
    if c.m.v=='mtg'
        subplot( c.m.YSize, c.m.XSize, c.m.Pos(k),'align');
    elseif c.m.v=='s2d'
        subplot('position',[c.m.X(k) c.m.Y(k) c.m.width c.m.height]);
    end
else
    subplot( c.m.YSize, c.m.XSize, c.m.Pos(k),'align');
end
imagesc(rej_map)
lab.fticklabels=c.f_min :c.numfreq:c.f_max;
lab.ftick=0:c.numfreq*c.map_y_size/(c.f_max-c.f_min):c.map_y_size;
lab.tticklabels=c.tmin:c.num_time:c.tmax;
lab.ttick=0:c.num_time*c.map_x_size/(c.tmax-c.tmin):c.map_x_size;
lab.test_tticklabels=c.ref_sec(2):c.num_time:c.tmax-c.right_time_margin;
lab.test_ttick=0:c.num_time*c.map_x_size/(c.tmax-c.tmin):c.map_x_size-c.right_time_margin_px-c.ref(end)-1;

set(gca,'FontSize',[6]);
set(gca,'ydir','normal');
set(gca,'xtick', lab.ttick, 'xticklabel', lab.tticklabels, 'ytick', lab.ftick, 'yticklabel', lab.fticklabels);
set(gca,'tickdir','out');

line([c.ref(1) c.ref(1)]-0.5,[0  c.f_max-c.f_min]/c.df+0.5 ,'Color',[0 0 0])
line([c.ref(end) c.ref(end)]+0.5,[0  c.f_max-c.f_min]/c.df+0.5 ,'Color',[0 0 0])
line([c.map_x_size-c.right_time_margin_px c.map_x_size-c.right_time_margin_px]+0.5,[0  c.f_max-c.f_min]/c.df+0.5 ,'Color',[0 0 0])

%str=sprintf('DATA: %s LT',name)
%xlabel(str);
% ytl=get(gca,'YTickLabel');
% yt=get(gca,'YTick');
% %yt=(yt(2)-yt(1))/10*([20 40 60 80 100]-4.63608);%-5);%
% get(gca,'XTickLabel');
% xt=get(gca,'XTick');




if k==c.m.N
    if exist(c.output_directory)==0
    mkdir(c.output_directory)
end
    prname=sprintf('%s/%s_%s.eps',c.output_directory,name,'REJECTED_NORMALITY');
    orient landscape
    print('-depsc2', prname);

    figname=sprintf('%s/%s_%s.fig',c.output_directory,name,'REJECTED_NORMALITY');
    hgsave(figname)
end

