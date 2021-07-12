function [p] = invgampdf(x,a,b)

p = (b^a/gamma(a))*x.^(-a-1).*exp(-b./x);
