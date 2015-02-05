function mapa=CalculateRawMapOf_ERD_ERS(c)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 					CALCULATING MAPS OF ERD_ERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% eval(config)
tmp_energy_scale=c.ENERGY_SCALE; % for ERS ERD we need LIN scale !!!
c.ENERGY_SCALE  ='LIN' ;              
switch c.MAX_RES
    case 0,  mapa = ERD_ERS_map(c);
    case 1,  mapa = ERDS_max_res_map(c);
end
c.ENERGY_SCALE  = tmp_energy_scale; % here we restore declared energy scale for statistics and mean maps
