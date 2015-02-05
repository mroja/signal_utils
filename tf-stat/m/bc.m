function [tr_data, best_lam,zz] = bc(varargin)
switch nargin
case 1
        x = varargin{1};
   % if size(x, 1) ~= 1 & size(x, 2) ~= 1
     %   disp('Input DATA must be a vector.');
    % end
    % if any(x < 0)
      % disp('Input DATA must be positive.');
    % end
   options = optimset('MaxFunEvals', 2000, 'Display', 'off');
    best_lam = fminsearch('bc', 0, options, x, 2);
    tr_data = bc(best_lam, x, 1);
case 2
    lam = varargin{1};
    x = varargin{2};
    n = length(x);
   % lam = lam(:);
    x_tr = zeros(length(x), length(lam));
    nzlam = find(lam ~= 0);
    zlam = find(lam == 0);

    mx = x * ones(1, length(lam));
    mlam = (lam * ones(length(x), 1)')';
    tr_data(:, nzlam) = ((mx(:, nzlam).^mlam(:, nzlam))-1) ./mlam(:, nzlam);
    tr_data(:, zlam) = log(mx(:, zlam));
case 3
    flag = varargin{3};
    lam = varargin{1};
    x = varargin{2};
    n = length(x);
    x_tr = bc(lam, x, 1);
    tr_data = -(n/2).*log(std(x_tr', 1, 2).^2) + (lam-1)*(sum(log(x)));
    tr_data = -tr_data;
% otherwise
 %  disp('Too many input arguments. Maximum of 3 inputs.');
end