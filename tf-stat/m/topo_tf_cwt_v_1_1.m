function y=topo_tf(c)
c=compute_consts(c);
c

lab=make_labels(c);
c.lab=lab;
% search for minimum and maksimum values to be displayed
min_map_val=-0.01;
max_map_val=0.01;
topo=struct('mapa',{[]});
for k=1:c.m.N
    c.current_channel=c.m.chan(k);
    tic
    mapa=r_multi_v_cwt(c);
    toc
    min_map_val=min(min(min(mapa)),min_map_val);
    max_map_val=max(max(max(mapa)),max_map_val);
    topo(k).mapa=mapa;
end
% scalling maps to common extrema
for k=1:c.m.N
    switch c.OUTPUT_TYPE
        case 'MEAN_MAP'% scale map of mean energy distribution
            topo(k).mapa=topo(k).mapa/max_map_val;
        case {'ERD_ERS','ACCEPTED'} % scale raw or accepted map of ERD/ERS
           
            if strcmp(c.ERD_ERS_COLOR,'AUTO')
            
            ERS_extr=max(max_map_val, 0.01);
            ERD_extr=min(min_map_val, -0.01);
            else
                  ERS_extr=c.ers/100;
                  ERD_extr=c.erd/100;
            end


            scala=max(max_map_val, abs(min_map_val));
            erds_map=topo(k).mapa;
            erds_map_sc=erds_map;
            erds_map_sc(find(erds_map>0))=erds_map(find(erds_map>0))/ERS_extr*100; % w %
            erds_map_sc(find(erds_map<=0))=erds_map(find(erds_map<=0))/abs(ERD_extr)*100; % w %
            if c.MAX_RES==0
                topo(k).mapa=erds_map_sc(:,c.ref(end)+1:c.map_x_size-c.right_time_margin_px);
            else
                ref_max_res = c.ref*c.Tsize/c.map_x_size;
                right_time_margin_px_max_res = c.right_time_margin_px*c.Tsize/c.map_x_size;
                topo(k).mapa=erds_map_sc( : , ref_max_res(end)+1:c.Tsize-right_time_margin_px_max_res);
            end
            CLIM = [-100 100];
    end
end

% DISPLAY
figure(1)
% c.m
switch c.MAP_TYPE
    case 'MP'
        name=sprintf('%s_%s_%s_%.2fx%.2f_%.1f-%.1fs_%.0f-%.0fHz_scale_%.2f-%.2f_OscNum_%.2f_%s', c.base_name,c.STATISTICS, c.MULTIPLE_TEST_CORRECTION,c.dt, c.df, c.tmin, c.tmax, c.f_min, c.f_max, c.filter_scale(1), c.filter_scale(2), c.OSC_NUM , c.ENERGY_SCALE);
    case 'SP'
        name=sprintf('%s_%s_%s_%.2fx%.2f_%.1f-%.1fs_%.0f-%.0fHz_%s', c.base_name, c.STATISTICS, c.MULTIPLE_TEST_CORRECTION,c.dt, c.df, c.tmin, c.tmax, c.f_min, c.f_max, c.ENERGY_SCALE);
    case 'CWT'
        name=sprintf('%s_%s_%s_%.2fx%.2f_%.1f-%.1fs_%.0f-%.0fHz_w_%d_%s', c.base_name, c.STATISTICS, c.MULTIPLE_TEST_CORRECTION, c.dt, c.df, c.tmin, c.tmax, c.f_min, c.f_max,c.WAVE, c.ENERGY_SCALE);
end


for k=1:c.m.N
    subplot( c.m.YSize, c.m.XSize, c.m.Pos(k),'align');
    pos=get(gca,'Position');
    switch c.OUTPUT_TYPE
        case 'MEAN_MAP'% Display map of mean energy distribution
            DisplayMeanMap(topo(k).mapa,lab,c);
        case {'ERD_ERS', 'ACCEPTED'}% Display raw map of ERD/ERS or accepted ERD/ERS
            DisplayMapERD_ERS(topo(k).mapa,lab,c);
    end
    title(c.m.label(k),'HorizontalAlignment','left','VerticalAlignment','top')
end

% eval(config);
% [pathstr,fname,ext,versn] = fileparts(bookname);

%title(sprintf('average ERD/ERS of %d trials', c.N));
axis on
switch c.OUTPUT_TYPE
    case 'MEAN_MAP'
        set(gca,'xtick', lab.ttick, 'xticklabel', lab.tticklabels, 'ytick', lab.ftick, 'yticklabel', lab.fticklabels);
    case {'ERD_ERS', 'ACCEPTED'}
        set(gca,'xtick', lab.test_ttick, 'xticklabel', lab.test_tticklabels);
        set(gca,'ytick', lab.ftick, 'yticklabel', lab.fticklabels);
end
axh=gca;
axes('Position',[0 0 1 1],'Visible','off')
hx=gca;
set(gcf,'CurrentAxes',hx)
text(0.1,0.02,name,'FontSize',10,'interpreter','none');
switch c.OUTPUT_TYPE
    case {'ERD_ERS', 'ACCEPTED'}
        % axes;axis off;
        h=colorbar('vert','peer',axh);
        set(h,'YTick',[-100 -50 0 50 100]);
        set(h,'YTicklabel',round(100*[ERD_extr ERD_extr/2 0 ERS_extr/2 ERS_extr]));
        set(h,'Xtick',[1],'XTicklabel','%');
        set(gca,'tickdir','out');
        set(h,'Position' , [0.91,pos(2),0.02,pos(4)]);
        set(axh,'Position' , pos);
end




if exist(c.output_directory)==0
    mkdir(c.output_directory)
end
prname=sprintf('%s/%s_%s.eps',c.output_directory,name,c.OUTPUT_TYPE);

%set(gcf, 'paperposition', [0.25 0.35188 11.193 7.564]);
%print('-depsc', prname);

orient landscape
print('-depsc2', prname);

figname=sprintf('%s/%s_%s.fig',c.output_directory,name,c.OUTPUT_TYPE);
hgsave(figname)

%set(gcf, 'paperposition', [0.25 0.35188 11.193 7.564]);
%print('-depsc', prname);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function DisplayMeanMap(mapa,l,c)
imagesc(mapa);
colormap(jet)
set(gca,'FontSize',[6]);
% eval(config);
set(gca,'ydir','normal');
% set(gca,'xtick', l.ttick, 'xticklabel', l.tticklabels, 'ytick', l.ftick, 'yticklabel', l.fticklabels);
% set(gca,'xtick', l.ttick, 'xticklabel', [], 'ytick', l.ftick, 'yticklabel', []);
% set(gca,'tickdir','out');
axis off
switch c.MAX_RES
    case 1
        line([c.ref(1)-1 c.ref(1)-1]*c.Tsize/c.map_x_size, [0 c.maxF-c.minF],'Color',[0 0 0])
        line([c.ref(end) c.ref(end)]*c.Tsize/c.map_x_size, [0 c.maxF-c.minF] ,'Color',[0 0 0])
        line([c.map_x_size-c.right_time_margin_px c.map_x_size-c.right_time_margin_px]*c.Tsize/c.map_x_size+0.5, [0 c.maxF-c.minF] ,'Color',[0 0 0]);
    case 0
        line([c.ref(1) c.ref(1)]-0.5,[0  c.f_max-c.f_min]/c.df+0.5 ,'Color',[0 0 0])
        line([c.ref(end) c.ref(end)]+0.5,[0  c.f_max-c.f_min]/c.df+0.5 ,'Color',[0 0 0])
        line([c.map_x_size-c.right_time_margin_px c.map_x_size-c.right_time_margin_px]+0.5,[0  c.f_max-c.f_min]/c.df+0.5 ,'Color',[0 0 0])
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function DisplayMapERD_ERS(mapa,l,c)
CLIM = [-100 100];
imagesc(mapa,CLIM);
colormap(jet(65))
mapOfColours = colormap;
mapOfColours(33,:) = [1 1 1];
colormap(mapOfColours);
set(gca,'FontSize',[6]);
set(gca,'ydir', 'normal');
set(gca,'xtick', l.test_ttick, 'xticklabel', l.test_tticklabels);
set(gca,'ytick', l.ftick, 'yticklabel', l.fticklabels);
axis off
for i=1:length(c.lines)

    switch c.MAX_RES
        case 1
            line([c.lines(i)-c.ref_sec(end) c.lines(i)-c.ref_sec(end)]*c.Tsize/c.map_x_size/c.dt, [0 c.maxF-c.minF],'Color',[0 0 0])
        case 0
            line([c.lines(i) c.lines(i)]-0.5,[0  c.f_max-c.f_min]/c.df+0.5 ,'Color',[0 0 0])
    end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function lab=make_labels(c)
%%LABELS
% eval(config)

lab.fticklabels=c.f_min :c.numfreq:c.f_max;
lab.ftick=0:c.numfreq*c.map_y_size/(c.f_max-c.f_min):c.map_y_size;
lab.tticklabels=c.tmin:c.num_time:c.tmax;
lab.ttick=0:c.num_time*c.map_x_size/(c.tmax-c.tmin):c.map_x_size;
lab.test_tticklabels=c.ref_sec(2):c.num_time:c.tmax-c.right_time_margin;
lab.test_ttick=0:c.num_time*c.map_x_size/(c.tmax-c.tmin):c.map_x_size-c.right_time_margin_px-c.ref(end)-1;

if c.MAX_RES==1 %%LABELS max res
    lab.ftick=lab.ftick*c.Fsize/c.map_y_size;
    lab.ttick=lab.ttick*c.Tsize/c.map_x_size;
    lab.test_ttick=lab.test_ttick*c.Tsize/c.map_x_size;
end
lab.ftick=lab.ftick+0.5;
lab.ttick=lab.ttick+0.5;
lab.test_ttick=lab.test_ttick+0.5;
