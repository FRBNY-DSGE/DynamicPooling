% ---------------------------------------------------- 
% produce figure 8
% ---------------------------------------------------- 

% make sure to choose appropriate vint
draws_vint     = '20210615';

% Load in lambdas for priors 1 and 2 for both wrong and right data

m1_lam_fp = sprintf('../../matlab_save_files/draws_lam_vint=%s_R_%s.mat', draws_vint, 'spec04');
m2_lam_fp = sprintf('../../matlab_save_files/draws_lam_vint=%s_R_%s.mat', draws_vint, 'spec04_correct');
m3_lam_fp = sprintf('../../matlab_save_files/draws_lam_vint=%s_R_%s.mat', draws_vint, 'spec06');
m4_lam_fp = sprintf('../../matlab_save_files/draws_lam_vint=%s_R_%s.mat', draws_vint, 'spec06_correct');

m1_para_fp = sprintf('../../matlab_save_files/draws_para_vint=%s_R_%s.mat', draws_vint, 'spec04');
m2_para_fp = sprintf('../../matlab_save_files/draws_para_vint=%s_R_%s.mat', draws_vint, 'spec04_correct');
m3_para_fp = sprintf('../../matlab_save_files/draws_para_vint=%s_R_%s.mat', draws_vint, 'spec06');
m4_para_fp = sprintf('../../matlab_save_files/draws_para_vint=%s_R_%s.mat', draws_vint, 'spec06_correct');





lam_draws_m1  = load(m1_lam_fp);
lam_draws_m2  = load(m2_lam_fp);
lam_draws_m3  = load(m3_lam_fp);
lam_draws_m4  = load(m4_lam_fp);

para_draws_m1 = load(m1_para_fp);
para_draws_m2 = load(m2_para_fp);
para_draws_m3 = load(m3_para_fp);
para_draws_m4 = load(m4_para_fp);

para_draws_m1 = para_draws_m1.draws_para;
para_draws_m2 = para_draws_m2.draws_para;
para_draws_m3 = para_draws_m3.draws_para;
para_draws_m4 = para_draws_m4.draws_para;

lam_draws_m1  = lam_draws_m1.draws_lam;
lam_draws_m2  = lam_draws_m2.draws_lam;
lam_draws_m3  = lam_draws_m3.draws_lam;
lam_draws_m4  = lam_draws_m4.draws_lam;

lams_m1 = calc_lams(lam_draws_m1, para_draws_m1);
lams_m2 = calc_lams(lam_draws_m2, para_draws_m2);
lams_m3 = calc_lams(lam_draws_m3, para_draws_m3);
lams_m4 = calc_lams(lam_draws_m4, para_draws_m4);

data = readtable('../../julia_files/save/input_data/data/data_dsid=1922016_vint=210615.csv');
dates = table2array(data(:,1));

datenums = datenum(dates);

% create and save figure for original prior

plot(datenums, lams_m1, '^-', 'MarkerFaceColor', rgb('Black'), 'MarkerEdgeColor', ...
    rgb('Black'), 'Color', rgb('Black'), 'MarkerSize', 3)
hold on;
plot(datenums, lams_m3, 'o-', 'MarkerFaceColor', rgb('DarkGreen'), 'MarkerEdgeColor', ...
    rgb('DarkGreen'), 'Color', rgb('DarkGreen'), 'MarkerSize', 3)
datetick('x', 'yyyy');
xlim([datenums(1) datenums(end)]);
legend('Prior 1', 'Prior 3');
hold off;

% create and save figure for corrected prior
fig8 = figure();

plot(datenums, lams_m2, '^-', 'MarkerFaceColor', rgb('Black'), 'MarkerEdgeColor', ...
    rgb('Black'), 'Color', rgb('Black'), 'MarkerSize', 3)
hold on;
plot(datenums, lams_m4, 'o-', 'MarkerFaceColor', rgb('DarkGreen'), 'MarkerEdgeColor', ...
    rgb('DarkGreen'), 'Color', rgb('DarkGreen'), 'MarkerSize', 3)
datetick('x', 'yyyy');
xlim([datenums(1) datenums(end)]);
legend('Prior 1', 'Prior 3');

saveas(fig8, 'figures/fig8.pdf');
hold off;
