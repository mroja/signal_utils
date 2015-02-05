function [hip, pval]=ad_test(x)
% function implements "Anderson-Darling normality test" code based on the R code ad.test
% hip=0 we cannot reject null hipothesis -> we assume x has normal distibution
% hip =1 we reject null hipothesis -> x has non normal distribution
   x=sort(x);
   [r c]=size(x);
	if r>c
		x=x';
	end
     n=length(x);
    if n < 8
       disp('sample size must be greater than 7')
       return;
    end
    p = normcdf((x - mean(x))/std(x));
    h = (2 *(1:n) - 1).* (log(p) + log(1 - fliplr(p)));
    A = -n - mean(h);
    AA = (1 + 0.75/n + 2.25/n^2) * A;
    if AA < 0.2
        pval = 1 - exp(-13.436 + 101.14 * AA - 223.73 * AA^2);
     elseif AA < 0.34
        pval = 1 - exp(-8.318 + 42.796 * AA - 59.938 * AA^2);
    elseif AA < 0.6
        pval = exp(0.9177 - 4.279 * AA - 1.38 * AA^2);
    else
        pval = exp(1.2937 - 5.709 * AA + 0.0186 * AA^2);
    end
    if pval< 0.01
    	hip=1;
    else
	hip=0;
    end