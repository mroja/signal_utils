function bct=b_c_transform(lambda, x)
        n = length(x);
        % Make sure that the lambda vector is a column vector.
        lambda = lambda(:);
        
        % Pre-allocate the matrix for the transformed data vector, xhat.
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
        bct(:, nzlambda) = ((mx(:, nzlambda).^mlambda(:, nzlambda))-1) ./ ...
            mlambda(:, nzlambda);
        bct(:, zlambda) = log(mx(:, zlambda));