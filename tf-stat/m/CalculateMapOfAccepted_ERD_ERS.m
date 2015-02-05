function mapa=CalculateMapOfAccepted_ERD_ERS(c)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 					CALCULATING MAPS OF ACCEPTED ERD_ERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% eval(config)
tmp_energy_scale=c.ENERGY_SCALE; % for ERS ERD we need LIN scale !!!
c.ENERGY_SCALE  ='LIN' ;              
switch c.MAX_RES
    case 0,  mapa_ERSD = ERD_ERS_map(c);
    case 1,  mapa_ERSD = ERDS_max_res_map(c);
end
c.ENERGY_SCALE  = tmp_energy_scale; % here we restore declared energy scale for statistics and mean maps

mapa=CalculateMapsOfEnargyDensity(c,0); % for statistics we need the low resolution maps

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 		STATISTICS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% CALCULATING P %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch c.MAP_TYPE
	case 'MP'
		name=sprintf('%s_chan_%d_%s_%s_%.2fx%.2f_%.1f-%.1fs_%.0f-%.0fHz_scale_%.2f-%.2f_OscNum_%.2f_%s', c.base_name,c.current_channel,c.STATISTICS, c.MULTIPLE_TEST_CORRECTION,c.dt, c.df, c.tmin, c.tmax, c.f_min, c.f_max, c.filter_scale(1), c.filter_scale(2), c.OSC_NUM , c.ENERGY_SCALE);
	case 'SP'
name=sprintf('%s_chan_%d_%s_%s_%.2fx%.2f_%.1f-%.1fs_%.0f-%.0fHz_%s', c.base_name,c.current_channel, c.STATISTICS, c.MULTIPLE_TEST_CORRECTION,c.dt, c.df, c.tmin, c.tmax, c.f_min, c.f_max, c.ENERGY_SCALE);
	case 'CWT'
	name=sprintf('%s_chan_%d_%s_%s_%.2fx%.2f_%.1f-%.1fs_%.0f-%.0fHz_w_%d_%s', c.base_name,c.current_channel, c.STATISTICS, c.MULTIPLE_TEST_CORRECTION, c.dt, c.df, c.tmin, c.tmax, c.f_min, c.f_max,c.WAVE, c.ENERGY_SCALE);
end


switch c.STATISTICS
    case 'NONE_STAT'
        MULTIPLE_TEST_CORRECTION='NONE';
        p=[];
    case 'PSEUDO_T'
        p=p_pseudoT(mapa, c, name);
    case 'PERM_TEST'
        p=p_perm_test(mapa, c, name);
    case 'T_TEST'
        p=p_T(mapa, c, name);
    case 'WELCH'
        p=p_T_WELCH(mapa, c, name);
    case 'Z_TEST'
        p=p_Z(mapa, c, name);
    otherwise
        error('unknown statistics')
end
p(:,c.ref)=ones(size(p(:,c.ref)));

%%%%%%%%%%%%%%% multiple tests correction & cutoff %%%%%%%%%%%%%
switch c.MULTIPLE_TEST_CORRECTION
    case 'NONE'
        eff_p = c.p_level;
	accepted = p<eff_p;
    case 'NONE_CORR'
        eff_p = c.p_level;
        accepted = p<eff_p;
    case 'BY_COLUMN'
        eff_p = c.p_level/c.map_y_size;
        accepted = p<eff_p;
        adjustetd_p=p/c.map_y_size;
    case 'FULL_BONFERRONI'
        N_tests=c.map_y_size * ( c.map_x_size-c.ref(end) )
        eff_p = c.p_level/N_tests;
        accepted = p<eff_p;
        adjustetd_p=p/N_tests;
    case 'BH'
        [accepted, adjustetd_p, eff_p]=multiple_test_BH_correction(p,c);
    case 'FDR'
        [accepted, adjustetd_p, eff_p]=multiple_test_FDR_correction(p,c);
    otherwise
        error('unknown multiple test correction method')
end
if ~isempty(p)
    accepted(:,c.ref)=ones(size(p(:,c.ref)));
else
    accepted=[];
end
disp( sprintf('Effective p: p< %f in %s %s',eff_p, c.MULTIPLE_TEST_CORRECTION, c.ENERGY_SCALE))

if c.MAX_RES==1
    %accepted matrix in maximum resolution
    [HH , GG] =TRANSFORM_HH_GG(c);
    accepted = HH*accepted*GG;
end

mapa=accepted.*mapa_ERSD;
