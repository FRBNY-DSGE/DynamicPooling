function [pr] = epanechenikov(l,u,x)

if u >= l
    error('choose a non-empty interval (l<u)');
end

ul = (u-l)/2;
m  = l + ul;

x_norm = (x-m)/(ul);

pr = (3/4)*(1-x_norm^2)*(abs(x_norm) <= 1);
