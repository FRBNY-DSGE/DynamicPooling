function p = rtnormpdf(r,a,b,mu,sigma)

% Check input arguments
if nargin ~= 3 && nargin ~=5,
    error('Wrong number of arguments.');
end

if r<a
    p = 0;
    return;
end

% default to std. normal
if nargin == 3
    mu    = 0;
    sigma = 1;
end

% scale
a = (a-mu)/sigma;
b = (b-mu)/sigma;

Z = sqrt(pi/2)*sigma * (erf(b/sqrt(2))-erf(a/sqrt(2)));
Z = max(Z,1e-15);      % Avoid NaN
p = exp(-(r-mu).^2/2/sigma^2) / Z;
