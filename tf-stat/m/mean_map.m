function av_map=mean_map(mapa,c)
%%%%%%%%%%%%%%%%%%%%%%%%%%%% MEAN map %%%%%%%%%%%%%%%%%%%%%%%%%%%%
av_map=squeeze(mean(mapa,1)); % map of mean energy
if c.map_y_size==1
    av_map=av_map';
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

