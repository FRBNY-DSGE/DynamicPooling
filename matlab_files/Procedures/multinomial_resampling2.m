function [ indx, m ] = multinomial_resampling2( w )

np = length(w);

w = w';
cw = cumsum(w);

uu = rand(length(w), 1);
indx = zeros(np, 1);
for i = 1:np

    u = uu(i);

    [a,~] = binSearch(cw,u);

    indx(i) = a;

end

m = 0;

    function [b,c]=binSearch(x,searchfor)
        a=1;
        b=numel(x);
        c=1;
        d=numel(x);
        while (a+1<b||c+1<d)
            lw=(floor((a+b)/2));
            if (x(lw)<searchfor)
                a=lw;
            else
                b=lw;
            end
            lw=(floor((c+d)/2));
            if (x(lw)<=searchfor)
                c=lw;
            else
                d=lw;
            end
        end
    end
end
