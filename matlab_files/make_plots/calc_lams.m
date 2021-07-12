function f = calc_lams(lam_draws, para_draws)

para_dims = size(para_draws);

pd = makedist('Normal');
lamhat_tplush    = lam_draws;
lamhat_tplushrho = lam_draws;
for t = 1:78
        if para_dims(2) == 1

            for hstep = 1:4
                lamhat_tplush(:,t) = cdf(pd, norminv(lamhat_tplush(:,t)) .* para_draws(:,1,t));
                %(1 - para_draws(:,1,t)));


            end
        else

            for hstep = 1:4
                lamhat_tplush(:,t) = cdf(pd, norminv(lamhat_tplush(:,t)) .* para_draws(:,1,1) + ...
                    (1 - para_draws(:,1,t)) .* para_draws(:,3,t));
            end
        end

        lamhat_tplushrho(:,t) = cdf(pd, norminv(lam_draws(:,t)) .* para_draws(:,1,t).^4);

end
    

    f     = mean(lamhat_tplush, 1);

end

