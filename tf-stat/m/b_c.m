function [bct, bclambda] = b_c(x)
        if size(x, 1) ~= 1 & size(x, 2) ~= 1
            disp('       Input DATA must be a vector.');
        end
        if any(x < 0)
            disp(     'Input DATA must be positive.');
        end
        
        % Find the lambda that minimizes of the Log-Likelihood function;
        options = optimset('MaxFunEvals', 2000, 'Display', 'off');
        bclambda = fminsearch('b_c_optim', 0, options, x);
        
        % Generate the transformed data using the optimal lambda.
        bct = b_c_transform(bclambda, x);

 