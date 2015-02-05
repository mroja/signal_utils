function y = map_transform(x, energy_scale)

switch energy_scale
case 'LIN'
  y = x;
case 'LOG'
 y = log(x);
case 'LOG_SQRT'
 y = log(sqrt(x));

case 'LOGIT'
  y = log(x./(1-x));
 case 'LOG+1',
 y = log(1+x);
case '1_2'
   y =sqrt(x);
case '1_3'
   y =(x).^(1/3);
case '1_4'
   y =sqrt(sqrt(x));
otherwise
   error('unknown energy scale type');
end
