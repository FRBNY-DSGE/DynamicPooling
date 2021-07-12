

% Choose settings for what you want to plot.
estim_fn = 'right805orig904'; % should be either 'wrongorigmatlab' or 'right805orig904'
prior = 1; % should be either 1, 2, or 3
static_vintage = '210615'; % vintage date of estimation for static pool
vintage_date   = '210615'; % vintage date of estimationfor dynamic pool & predictive densities
draws_vint     = '20210615';

% select correct pm_ss string for use in file paths
if (strcmp(estim_fn, 'wrongorigmatlab'))
    if prior == 1
        pm_ss = 'spec04';
    elseif prior == 2
        pm_ss = 'spec06';
    elseif prior == 3
        pm_ss = 'spec13';
    end
elseif (strcmp(estim_fn, 'right805orig904'))
    if prior == 1
        pm_ss = 'spec04_correct';
    elseif prior == 2
        pm_ss = 'spec06_correct';
    elseif prior == 3
        pm_ss = 'spec13_correct';
    end 
end

data = readtable('../input_data/data_dsid=1922016_vint=210615.csv');
dates = table2array(data(:,1));
data = table2array(data(:,2:3));
%%% compute logscore for equal weighting (lambda = 0.5)
% compute 0.5 * data(i,1) + 0.5 * data(i,2) for all i
lambda_equal = 0.5 * ones(78,2);
ew_logscore_t = log(dot(lambda_equal, data,2));

equal_logscore = sum(ew_logscore_t(5:end));

%%% BMA
% compute lambdas 
bma_lams       = estimate_bma(data, 0.5);
% compute log scores for bayesian model averaging 
bma_logscore_t = log(bma_lams .* data(:,1) + (1 - bma_lams) .* data(:,2));
bma_logscore   =  sum(log(bma_lams(1:end-4) .* data(5:end,1) + ...
                           (1 - bma_lams(1:end-4)) .* data(5:end,2)));

%%%% Static Weights
% set file path based on prior 
if (strcmp(estim_fn,'wrongorigmatlab')); which_static_prior = 1; else which_static_prior = 2; end
static_filep = sprintf('../../matlab_save_files/static_lambda_ss%d_vint=%s.mat',... 
                           which_static_prior, static_vintage);

% load in static weight lambda draws
sw_lams = load(static_filep);
sw_lams = sw_lams.draws_lam;
static_lams = zeros(size(data,1),1);

% at each time t, choose lambda which maximizes logscore
for t = 1:size(data,1)
    lams = sw_lams(:,t);
    lams = lams(1001:end); % burn first 1000
    logscores = zeros(size(lams));
    
    for t1 = 1:t
        logscores = logscores +  log(lams .* data(t1,1) + (1 - lams) .* data(t1,2));
        test = log(lams .* data(t1,1) + (1 - lams) .* data(t1,2));
        
    end
    [argvalue, argmax] = max(logscores);
    static_lams(t) = lams(argmax);
end

% calculate logscores, note difference in indexing for expost 
static_logscore_t = log(static_lams(1:end-4) .* data(5:end,1) + ...
    (1 - static_lams(1:end-4)) .* data(5:end,2));
static_logscore = sum(static_logscore_t);
expost_static_logscore = sum(log(static_lams .* data(:,1) + ...
    (1 - static_lams) .* data(:,2)));


% load in lambda and para draws for dynamic pooling 
para_draws_fp = sprintf('../../matlab_save_files/draws_para_vint=%s_R_%s.mat', draws_vint, pm_ss);
lam_draws_fp = sprintf('../../matlab_save_files/draws_lam_vint=%s_R_%s.mat', draws_vint, pm_ss);
para_draws = load(para_draws_fp);
lam_draws  = load(lam_draws_fp);

para_draws = para_draws.draws_para;
lam_draws  = lam_draws.draws_lam;

para_dims = size(para_draws);

pd = makedist('Normal');
lamhat_tplush    = lam_draws;
lamhat_tplushrho = lam_draws;

% the number of dimensions in the parameter vector determines the form of the 
% equation, note that para_draws(:,3,t) are the mus 
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

lams     = mean(lamhat_tplush, 1);
lamhat_t = mean(lam_draws, 1);
lam_rho  = mean(lamhat_tplushrho, 1);

dp_logscore_t     = log(lams' .* data(:,1) + (1 - lams') .* data(:,2));
dp_logscore_t_rho = log(lam_rho' .* data(:,1) + (1 - lam_rho') .* data(:,2));

dp_logscore     = sum(log(lams(1:end-4)' .* data(5:end,1) + (1 - lams(1:end-4)') .* data(5:end,2)));
dp_logscore_rho = sum(log(lam_rho(1:end-4)' .* data(5:end,1) + ... 
    (1 - lam_rho(1:end-4)') .* data(5:end,2)));


%%% We can now make our figures 

% datenums array used for plotting date chars
datenums = datenum(dates);

% make first figure
fig1 = figure();
plot(datenums, log(data(:,2)'), 'b-', 'LineWidth', 1.5);
datetick('x', 'yyyy');
hold on;
plot(datenums, log(data(:,1)'), 'r-', 'LineWidth', 1.5);
datetick('x', 'yyyy');
xlim([datenums(1) datenums(end)]);
legend('SW\pi', 'SWFF', 'Location', 'southwest')

fig1_fp = sprintf('figures/log_pred_dens_swpi_swff=%s_prior_%d_vint=%s.pdf',...
    estim_fn, prior,vintage_date);
saveas(fig1, fig1_fp);
hold off;

% make second figure
fig2 = figure();

plot(datenum(dates),bma_lams, 'o-', 'MarkerFaceColor', rgb('DarkGreen'), 'MarkerEdgeColor',...
    rgb('DarkGreen'), 'Color', rgb('DarkGreen'), 'MarkerSize', 3);
datetick('x', 'yyyy');
hold on;
plot(datenum(dates), static_lams, '^-', 'MarkerFaceColor', rgb('DarkViolet'), ... 
    'MarkerEdgeColor', rgb('DarkViolet'), 'Color', rgb('DarkViolet'), 'MarkerSize',3);
plot(datenum(dates), lamhat_t, 'ks-', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', ...
    'k', 'MarkerSize', 3);

xlim([datenums(1) datenums(end)]);
legend('BMA', 'MSP', 'DP')

fig2_fp = sprintf('figures/lambdahat_t=%s_prior=%d_vint=%s.pdf', estim_fn, prior, vintage_date);
saveas(fig2, fig2_fp);
hold off;

% make third figure
fig3 = figure();
hist(para_draws(:,1,end), 50)
fig3_fp = sprintf('figures/post_rho_preddens=%s_prior=%d_vint=%s.pdf', estim_fn, prior, vintage_date);
saveas(fig3, fig3_fp);


if prior == 2
    fig3_1 = figure();
    hist(cdf(pd, para_draws(:,2,end)), 50)
    fig3_1_fp = sprintf('figures/post_mu_preddens=%s_prior=%d_vint=%s.pdf', ...
        estim_fn, prior, vintage_date);
    saveas(fig3_1, fig3_1_fp);
    
    fig3_2 = figure();
    hist(para_draws(para_draws <= sqrt(20),3,end) .^2, 150)
    fig3_2_fp = sprintf('figures/post_mu_preddens=%s_prior=%d_vint=%s.pdf', ...
        estim_fn, prior, vintage_date);
    saveas(fig3_2, fig3_2_fp);
end

% recompute logscores to be ex-ante
exante_ew_logscore_t     = log((data(5:end,1) + data(5:end,2)) ./ 2);
exante_bma_logscore_t    = log(bma_lams(1:end-4) .* data(5:end,1) + ...
    (1 - bma_lams(1:end-4)) .* data(5:end,2));
exante_static_logscore_t = log( static_lams(1:end-4) .* data(5:end,1) + ...
    (1 - static_lams(1:end-4)) .* data(5:end, 2));
exante_dp_logscore_t     = log(lams(1,1:end-4)' .* data(5:end,1) + ...
    (1 - lams(1, 1:end-4)') .* data(5:end,2));

% make 4th figure
fig4 = figure(); 
plot(datenums(5:end), log(data(5:end,2)'), 'Color', rgb('Blue'))
hold on;
plot(datenums(5:end), log(data(5:end,1)'), 'Color', rgb('Red'))
plot(datenums(5:end), exante_dp_logscore_t, 'Color', rgb('Green'))
xlabel = 'Date';
ylabel = ' Log predictive densities';
title('Log Score Comparison Over Time');
datetick('x', 'yyyy');
xlim([datenums(5) datenums(end)]);
legend('SW\pi', 'SWFF', 'DP', 'Location', 'southwest')

fig4_fp = sprintf('figures/log_pred_dens_compare_preddens=%s_prior=%d_vint=%s.pdf', ...
    estim_fn, prior, vintage_date);
saveas(fig4, fig4_fp);
hold off;

zeds = zeros(length(dp_logscore_t));
dp_min_ew = exante_dp_logscore_t - exante_ew_logscore_t;
dp_min_bma = exante_dp_logscore_t - exante_bma_logscore_t;
dp_min_msp = exante_dp_logscore_t - exante_static_logscore_t;

% make 5th figure
fig5 = figure();
area(datenums(5:end), dp_min_bma, 0, 'FaceColor', rgb('Green'))
hold on;
area(datenums(5:end), dp_min_msp, 0, 'FaceColor', rgb('Purple'))
plot(datenums(5:end), dp_min_ew, 'Color', rgb('Black'))
xlabel = 'Date';
xlim([datenums(5) datenums(end)]);
datetick('x', 'yyyy');
legend('BMA', 'MSP', 'EW', 'Location', 'northwest');

fig5_fp = sprintf('figures/log_pred_dens_relative_preddens=%s_prior=%d_vint=%s.pdf', ...
    estim_fn, prior, vintage_date);
saveas(fig5, fig5_fp);
hold off;


