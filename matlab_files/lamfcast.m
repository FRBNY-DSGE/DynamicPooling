%% ------------------------------------------------------------------------
% lamfcast.m: input is lambda_{t-h|t-h}, output is lambda_{t|t-h}
% -------------------------------------------------------------------------
function [l_f] = lamfcast(l_h,r,mu, sigma ,h)

if any(size(r) ~= [1 1])
    r = repmat(r,size(l_h)./size(r));
end
l_f = nan(size(l_h));
for i = 1:h
    l_h = normcdf(norminv(l_h,0,1) .* r + (1 - r) .* mu + ...
        sqrt(1 - r.^2) .* sigma .* randn(size(l_h)));
end
l_f = l_h;
