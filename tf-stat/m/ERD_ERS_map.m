function erds_map=ERD_ERS_map(c)
%%%%%%%%%%%%%%%%%%%%%%%%%%%% ERDS map %%%%%%%%%%%%%%%%%%%%%%%%%%%%% eval(config);
mapa=CalculateMapsOfEnargyDensity(c,0);
erds_map=zeros(c.map_y_size, c.map_x_size);
av_map=mean_map(mapa,c);

for f=1:c.map_y_size
    erds_map(f,c.ref)=ones(size(c.ref)).*mean(av_map(f,c.ref));
end
for t=c.ref(length(c.ref))+1:c.map_x_size
    for f=1:c.map_y_size
        erds_map(f,t)=(av_map(f,t)-erds_map(f,c.ref(1)))./erds_map(f,c.ref(1));
    end
end
for f=1:c.map_y_size
    erds_map(f,c.ref)= zeros(size(c.ref));% ones(size(ref)).*mean(av_map(f,ref));
    if c.right_time_margin_px >= 1
        erds_map(f,end-c.right_time_margin_px+1:end)=0;
end
end