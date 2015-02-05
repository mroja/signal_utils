function [HH , GG] =TRANSFORM_HH_GG(c)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 							  TRANSFORM FROM XxY INTO TxF
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% eval(config);
HH=zeros(c.Fsize, c.map_y_size);        %transfer matrix HH
for k=1:c.map_y_size
    HH((1:(c.Fsize/c.map_y_size))+c.Fsize/c.map_y_size*(k-1),k) = 1;
end
GG=zeros(c.map_x_size, c.Tsize);    %transfer matrix GG
for k=1:c.map_x_size
    GG(k,(1:(c.Tsize/c.map_x_size))+c.Tsize/c.map_x_size*(k-1)) = 1;
end
