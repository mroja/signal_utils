function var_map=variance_map(mapa)
%%%%%%%%%%%%%%%%%%%%%%%%%%%% VAR map %%%%%%%%%%%%%%%%%%%%%%%%%%%%
[map_y_size, map_x_size]=size(mapa);
var_map=zeros(map_y_size, map_x_size);
for t=1:map_x_size
    for f=1:map_y_size
        var_map(f,t)=var( mapa(:, f, t) );
    end
end