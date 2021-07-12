function [ indx, m ] = multinomial_resampling3( w )

np = length(w);

x=mnrnd(np,w)';

k = 0;
J = find(x);

indx = zeros(np, 1);
for j = 1:size(J,1)
    if x(J(j)) > 0
        indx(k+1:k+x(J(j)))=J(j);
    end
    k=k+x(J(j));
end

m = 0;
