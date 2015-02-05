function erds_map_max_res=ERDS_max_res_map(c)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                  ERDS_max_res map
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% eval(config);
av_map_max_res=CalculateMapsOfEnargyDensity(c,1);
mmin=min(min(av_map_max_res));
if mmin<0
    av_map_max_res=av_map_max_res-mmin;
end
ref_max_res = c.ref(1)*c.Tsize/c.map_x_size : c.ref(end)*c.Tsize/c.map_x_size;
right_time_margin_px_max_res = c.right_time_margin_px*c.Tsize/c.map_x_size;
erds_map_max_res=zeros(c.Fsize, c.Tsize);
for f=1:c.Fsize
    erds_map_max_res(f,ref_max_res)= ones(size(ref_max_res)).*mean(av_map_max_res(f,ref_max_res));
end
for t=ref_max_res(length(ref_max_res))+1:c.Tsize
    for f=1:c.Fsize
        erds_map_max_res(f,t)=(av_map_max_res(f,t)-erds_map_max_res(f,ref_max_res(1)))./erds_map_max_res(f,ref_max_res(1));
    end
end
for f=1:c.Fsize
    erds_map_max_res(f,ref_max_res)= zeros(size(ref_max_res));
    if c.right_time_margin_px >= 1
        erds_map_max_res(f,end-right_time_margin_px_max_res+1:end)= 0;
    end
end
