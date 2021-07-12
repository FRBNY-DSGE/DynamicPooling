function [p] = betapdf2(x,mu,sigma)

if nargin == 1
    mu = 0.5;
    sigma = 0.1;
    fprintf(1,'mu and sigma unspecified - using default values: (%4.7f,%4.7f)',...
        mu,sigma);
end

mu_prime = (1-mu)/mu;

a = (mu_prime/(sigma*(1+mu_prime))^2-1)/(1+mu_prime);
b = a*mu_prime;

if a<=0 || b<=0
    error('mu and sigma values cannot be obtained by beta distribution');
end

p = betapdf(x,a,b);
