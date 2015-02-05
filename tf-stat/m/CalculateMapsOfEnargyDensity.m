function mapa=CalculateMapsOfEnargyDensity(c,FLAG)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 					CALCULATING MAPS OF ENERGY DENSITY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FLAG 0 - low resolution maps
% 		 1	- high resolution maps
switch c.MAP_TYPE
    case 'MP'
    name=sprintf('%s_%d_%s_%.2fx%.2f_%.0f-%.0fs_%.0f-%.0fHz_scale_%.2f_%.2f_osc_num_%.2f',...
    c.base_name,c.current_channel, c.MAP_TYPE, c.dt, c.df, c.tmin, c.tmax, c.f_min, c.f_max, c.filter_scale(1), c.filter_scale(2), c.OSC_NUM);
disp(name);
        if FLAG==0
            [mapa, t, f] =calculate_maps_MP(c, name);
        else
            [mapa, t_max_res, f_max_res] =calculate_maps_MP(c, name, 1);
        end
    case 'CWT'
        [mapa, t, f] =calculate_maps_CWT(c,FLAG);
    case 'SP'
        [mapa, t, f] =calculate_maps_specgram(c,FLAG);
    otherwise
        error('unknown map type');
end
