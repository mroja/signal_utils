function [tr_data, best_lam] = normalize_bc(varargin)

% Input checks.
switch nargin
case 1      % Syntax:  tr_data = normalize_bc(DATA);
    flag = 0;
case 2      % Syntax:  tr_data = normalize_bc(LAMBDA, DATA);
    flag = 1;
case 3      % Syntax:  tr_data = normalize_bc(LAMBDA, DATA, FLAG);
    flag = varargin{3};
otherwise   % Error if number of input arguments is not 1, 2, or 3.
    error('Too many input arguments. Maximum of 3 inputs.');
end

% SWITCH yard for function calls.
switch flag
case 0  
    x = varargin{1};
    if size(x, 1) ~= 1 & size(x, 2) ~= 1
        error('Input DATA must be a vector.');
    end
    if any(x < 0)
        error('Input DATA must be positive.');
    end
    
    % Find the lambda that minimizes of the Log-Likelihood function;
    % FMINSEARCH is used here so that we don't need to provide a set
    % of boundary initial conditions.  We only need a number as the 
    % starting point of search.
    options = optimset('MaxFunEvals', 2000, 'Display', 'off');
    best_lam = fminsearch('normalize_bc', 0, options, x, 2);
    
    % Generate the transformed data using the optimal lambda.
    tr_data = normalize_bc(best_lam, x, 1);
case 1   % Calculates the Box-Cox Transformation of data .
   
    lambda = varargin{1};
    x = varargin{2};
    n = length(x);
    lambda = lambda(:);
    xhat = zeros(length(x), length(lambda));
    
    % Find where the non-zero and zero lambda's are.
    nzlambda = find(lambda ~= 0);
    zlambda = find(lambda == 0);
    
    % Create a matrix of the data by replicating the data vector 
    % columnwise.
    mx = x * ones(1, length(lambda));
    
    % Create a matrix of the lambda by replicating the lambda vector 
    % rowwise.
    mlambda = (lambda * ones(length(x), 1)')';
    
    % Calculate the transformed data vector, xhat.
    tr_data(:, nzlambda) = ((mx(:, nzlambda).^mlambda(:, nzlambda))-1) ./mlambda(:, nzlambda);
    tr_data(:, zlambda) = log(mx(:, zlambda));
case 2   % The Log-Likelihood function (LLF) to be minimized.
    % Get the lambda and data vectors.
    lambda = varargin{1};
    x = varargin{2};
    n = length(x);
    
    % Transform data using a particular lambda.
    xhat = normalize_bc(lambda, x, 1);
    
    % The algorithm calls for maximizing the LLF; 
    tr_data = -(n/2).*log(std(xhat', 1, 2).^2) + (lambda-1)*(sum(log(x)));
    tr_data = -tr_data;
end
