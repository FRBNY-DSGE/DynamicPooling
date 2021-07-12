function [ indx, m ] = multinomial_resampling_par( w )

np = length(w);

w = w';
cw = cumsum(w);

uu = rand(length(w), 1);
indx = zeros(np, 1);
parfor i = 1:np

    u = uu(i);

    j=1;
    while j <= np
       if (u < cw(j)), break, end;

       j = j+1;

    end

    indx(i) = j;

end

m = 0;
