function bct = b_c_optim(lambda, x)
        n = length(x);
        xhat = b_c_transform(lambda, x);
        
        % The algorithm calls for maximizing the LLF; however, since we have
        % only functions that minimize, the LLF is negated so that we can 
        % minimize the function instead of maximixing it to find the optimum
        % lambda.
        bct = -(n/2).*log(std(xhat', 1, 2).^2) + (lambda-1)*(sum(log(x)));
        bct = -bct;
