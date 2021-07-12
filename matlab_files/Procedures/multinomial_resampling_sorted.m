function [ indx, m ] = multinomial_resampling_sorted( w )

np = length(w);

w = w';
cw = cumsum(w);

uu = rand(length(w), 1);
indx = zeros(np, 1);

lnMax = 0;
j = np;

for i = np:-1:1

    u = uu(i);
    lnMax = lnMax + log(u)/i;
    u = cw(end)*exp(lnMax);

    while u < cw(j)
        j = j-1;
        if j == 0
            j = 1;
            disp(i);
            break;
        end
    end

    indx(i) = j;

end

m = 0;
