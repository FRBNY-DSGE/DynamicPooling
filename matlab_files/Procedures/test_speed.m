kk = 2.^[1:14];

tt3 = nan(size(kk));

for i_ = 1:length(kk)
    w = ones(kk(i_),1)/kk(i_);
    tic;
    [indx,~] = multinomial_resampling3(w);
    tt3(i_) = toc;
end
plot(kk,tt3,'b');