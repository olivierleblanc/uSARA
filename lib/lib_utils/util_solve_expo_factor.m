function res = util_solve_expo_factor(sigma_0, sigma)

    fun = @(a) (1+a*sigma)^(1/sigma_0) - a;
    
    est_c = sigma ^ -(1/( 1/sigma_0 - 1));
    est_a = (est_c - 1) / sigma;
    
    res = fsolve(fun, est_a, optimset('Display','off'));
    obj = fun(res);
    
    if obj > 1e-6 || res < 40
        fprintf('Possible wrong solution. sigma = %f, a = %f, f(a) = %f\n', sigma, res, obj);
    end
    
    end