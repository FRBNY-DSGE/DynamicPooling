% ----------------------------------------------------------------
% Prepared for ANU lecture by Frank Schorfheide
% Date: 6/14/2013
% NOTE:
% - All figures are stored in "currentfolder\figures"
% - We don't use mex file for this main file. statistical toolbox is required.
% ----------------------------------------------------------------
clc; clear all; close all;
randn('state', 8386);
rand('state', 8386);
tic;

% ----------------------------------------------------------------
% Setting
% ----------------------------------------------------------------
Nrep           = 20;             % # of repitition to get statistics related to PF (RMSE)
Nparticle_Set  = [10, 25, 50]; % Try different # of particles
nSet           = length(Nparticle_Set);

ihavexls = 0; %if you have the EXCEL program, you can save the table on your disk

% ----------------------------------------------------------------
% Parameters for simulated data
% ----------------------------------------------------------------
%  y_{t} = A + B s_{t} + u,    var(u) ~ H
%  s_{t} = Phi s_{t-1} + R*ep, var(ep) ~ S2
% ----------------------------------------------------------------
A     = [0.7; 0.8];
B     = [1; 0.65];
Phi   = [0.5];
R     = 1;
H     = [0.47^2 0; 0 0.62^2];
S2    = 0.758^2;

T       = 50; %length of timeseries
out_loc = 25; %location of the outlier
out_fac = 10; %factor of the outlier

x0 = 0;      % to initialize the filter
P0 = 0.75^2; % to initialize the filter

% ----------------------------------------------------------------
% FOLDER/PATH CONTROL
% ----------------------------------------------------------------
% INCLUDE FOLDERS
workpath          = pwd;
path_original     = path;
current_TOOLBOX   = genpath([workpath, '\', 'toolbox_filtering']);
addpath(current_TOOLBOX);

% SAVE PATH
chk_dir('figures');
savepath = [workpath, '\figures'];

% ----------------------------------------------------------------
%  Q1 - Simulate data
% ----------------------------------------------------------------
% s_t
s  = zeros(T+1,1);
s(1,1) = 0;
for i=2:1:T+1
    s(i,1) = Phi * s(i-1,1) + R*sqrt(S2)*randn(1,1);
end
s     = s(2:end,1);

% y_t (with and without outlier)
% yt_out2 : big shock in measurement error
cH     = chol(H)';
yt     = zeros(T,2);
for i=1:1:T
       temp_err = randn(2,1);
        yt(i,:) = (A + B*s(i,1) + cH*temp_err)';
end

% ME outlier
yt_out2 = yt;
yt_out2(out_loc,1) = yt(out_loc,1)+mean(yt(:,1))*out_fac;
yt_out2(out_loc,2) = yt(out_loc,2)+mean(yt(:,2))*out_fac;

% Figure 1 : Simulated data
f1 = figure(1);
ax = setmyfig(f1, [2.5, 1.1, 8, 8]);
subplot(2,1,1)
plot([yt(:,1:2)], 'linewidth', 3)
set(gca, 'LineWidth', 1.5);
set(gca, 'Fontsize', 13);
title('Y_{t}', 'fontsize', 20);
subplot(2,1,2)
plot([s], 'linewidth', 3, 'color', rgb('firebrick'))
set(gca, 'LineWidth', 1.5);
set(gca, 'Fontsize', 13);
title('s_{t}', 'fontsize', 20);

savefilename = ['figQ1_data.png'];
cd(savepath);
saveas(f1, savefilename);
cd(workpath);

% Figure 1a : with outlier in mesurement shock
f101 = figure(101);
ax = setmyfig(f101, [2.5, 1.1, 8, 8]);
subplot(2,1,1)
plot([yt_out2(:,1:2)], 'linewidth', 3)
set(gca, 'LineWidth', 1.5);
set(gca, 'Fontsize', 13);
title('Y_{t} (with outlier)', 'fontsize', 20);
subplot(2,1,2)
plot([s], 'linewidth', 3, 'color', rgb('firebrick'))
set(gca, 'LineWidth', 1.5);
set(gca, 'Fontsize', 13);
title('s_{t}', 'fontsize', 20);

savefilename = ['figQ1_dataout.png'];
cd(savepath);
saveas(f101, savefilename);
cd(workpath);

% ----------------------------------------------------------------
%  Q2 - Run Kalman Filter
% ----------------------------------------------------------------
[kf_s_up, kf_P_up, kf_loglik] = kalman_filter_ini(x0,P0,A,B,Phi,R,H,S2,yt);
kf_P_up = squeeze(kf_P_up);

% ----------------------------------------------------------------
%  Q3 - Plot E[s|Y_{1:t}] with 90% credible sets
% ----------------------------------------------------------------
% 90% confidence band
kf_se = zeros(T,2);
kf_se(:,1) = kf_s_up - 1.64*sqrt(kf_P_up);
kf_se(:,2) = kf_s_up + 1.64*sqrt(kf_P_up);

% Figure 2 : Overlay the true states
f2 = figure(2);
ax = setmyfig(f2, [2.5, 1.1, 8, 8]);

plot(s, 'linewidth', 3, 'linestyle', '--', 'color', rgb('red'))
hold on
plot(kf_s_up, 'linewidth', 4, 'color', 'b');
legend1 = legend('True', 'Kalman Filter');
set(legend1, 'location', 'southeast', 'fontsize', 20, 'fontname', 'Tahoma')

[ph,msg]=jbfill((1:1:T),kf_se(:,1)',kf_se(:,2)',rgb('SlateBlue'),rgb('Navy'),0,0.2);
hold off
axis([1, T, -4, 4])
set(ax, 'LineWidth', 2, 'fontsize', 20);

title('S_{t} based on Kalman Filter', 'fontsize', 25);

savefilename = ['figQ3_st_kf.png'];
cd(savepath);
saveas(f2, savefilename);
cd(workpath);

% ----------------------------------------------------------------
%  Q4a - Particle filter: No repetition but cycle over Nparticles
% ----------------------------------------------------------------
table = zeros(4, 1+nSet);
table_header_c    = cell(1, 2+nSet);
table_header_c{1} = '';
table_header_c{2} = 'KF';

pf_loglik  = zeros(T, nSet);
pf_s_up    = zeros(T, nSet);
pf_P_up    = zeros(T, nSet);
Neff       = zeros(T, nSet);
for iter_N = 1:1:nSet

    % # of particles at this iteration
    N = Nparticle_Set(iter_N);
    table_header_c{2+iter_N} = ['N = ', num2str(N)];

    % run particle filter
    ticQ4 = tic;
    [loglik, all_s_up, Neff(:,iter_N)] = PF_lin_ini(A, B, H, Phi, R, S2, N, yt, x0, P0);
    % save time information
    table(4,iter_N+1) = toc(ticQ4);

    % store results
    pf_loglik(:,iter_N) = loglik;
    pf_s_up(:,iter_N)   = mean(squeeze(all_s_up(:,1,:)),2);
    temp_pf_P_up        = zeros(T,1);
    for i=1:1:T
        temp_pf_P_up(i,1) = var(all_s_up(i,1,:));
    end
    pf_P_up(:,iter_N) = temp_pf_P_up;

end

% construct table
table_header_r = {'Loglik' 'Effective N (Mean)', 'RMSE (st, overtime)', 'Time'} ;
table(1, 1)    = sum(kf_loglik);
table(2, 1)    = 0;
% table(3, 1)    = sqrt( mean((s-kf_s_up).^2));
table(3, 1)    = 0;

for iter_N = 1:1:nSet
    table(1, iter_N+1) = sum(pf_loglik(:,iter_N));
    table(2, iter_N+1) = mean(Neff(:,iter_N));
    table(3, iter_N+1) = sqrt(mean((kf_s_up - pf_s_up(:,iter_N)).^2))  ;
end
table = [table_header_c; [table_header_r', num2cell(table)]];

% display table
disp('---------------------------------------------');
disp('Table: PF vs KF  (see the slide)');
disp('-  RMSE is based on the difference between KF and PF and average overtime.');
disp('-  Single run (no repetition)');
disp('---------------------------------------------');
disp(table);

% save to xls
if ihavexls == 1
    cd(savepath);
    xlswrite('tabQ4_pf.xlsx', table, 'Comparison', 'B2');
    cd(workpath);
end

% FIG: st
for iter_N = 1:1:nSet
    % 90% confidence band
    se = zeros(T,2);
    se(:,1) = pf_s_up(:, iter_N) - 1.64*sqrt(pf_P_up(:,iter_N));
    se(:,2) = pf_s_up(:, iter_N) + 1.64*sqrt(pf_P_up(:,iter_N));

    % plotting
    f4000 = figure(4000+iter_N);
    ax = setmyfig(f4000, [2.5, 1.1, 8, 8]);

    plot(kf_s_up, 'linewidth', 5, 'linestyle', '--', 'color', 'r')
    hold on
    plot(pf_s_up(:,iter_N), 'linewidth', 3, 'color', 'b');
    legend1 = legend('Kalman Filter', 'Particle Filter');
    set(legend1, 'location', 'southeast', 'fontsize', 20, 'fontname', 'Tahoma')
    hold on
    [ph,msg]=jbfill((1:1:T),se(:,1)',se(:,2)',rgb('SlateBlue'),rgb('Navy'),0,0.2);
    hold off
    if iter_N ==1
        axis([1, T, -5.5, 4])
    else
        axis([1, T, -4, 4])
    end
        title(['s_{t} from Particle Filter with ', num2str(Nparticle_Set(iter_N)), ...
            ' particles'], 'FontSize', 20, 'FontName', 'Tahoma')
    set(ax, 'LineWidth', 2);
    savefigname = ['figQ4_shat_np',num2str(Nparticle_Set(iter_N)), '.png'];
    cd(savepath);
    saveas(f4000, savefigname);
    cd(workpath);
end

% FIG: loglik
for iter_N = 1:1:nSet
    % plotting
    f4000 = figure(4010+iter_N);
    ax = setmyfig(f4000, [2.5, 1.1, 8, 8]);
    plot(kf_loglik, 'linewidth', 3, 'color', 'r')
    hold on
    plot(pf_loglik(:,iter_N), 'linewidth', 5, 'color', rgb('ForestGreen'), 'linestyle', '-');
    % plot(pf_loglik(:,2), 'linewidth', 2, 'color', rgb('ForestGreen'), 'linestyle', '-');
    % plot(pf_loglik(:,3), 'linewidth', 2, 'color', rgb('DarkGreen'), 'linestyle', '-');
    hold off
    axis([1, T, -8, 0])

    legend1 = legend('KF', ['PF (N = ', num2str(Nparticle_Set(iter_N)), ')']);
    set(legend1, 'location', 'southeast', 'fontsize', 20, 'fontname', 'Tahoma');
    title('Log Likelihood, p(y_{t}|Y_{1:t-1})', 'FontSize', 20, 'FontName', 'Tahoma');
    set(ax, 'LineWidth', 2);

    savefigname = ['figQ4_lik_np',num2str(Nparticle_Set(iter_N)), '.png'];
    cd(savepath);
    saveas(f4000, savefigname);
    cd(workpath);
end

% FIG: effective sample
f4000 = figure(4200);
ax = setmyfig(f4000, [2.5, 1.1, 8, 8]);

plot(Neff(:,1:nSet), 'linewidth', 3)
legend1 = legend(table_header_c(3:end));
set(legend1, 'location', 'northeast', 'fontsize', 20, 'fontname', 'tahoma')
title('ESS', 'FontSize', 20, 'FontName', 'Tahoma')
% axis([1, T, -50, 900])
set(ax, 'LineWidth', 2, 'fontsize', 20);
% set(gca, 'YTick', (0:200:1000));
savefigname = ['figQ4_ess.png'];
cd(savepath);
saveas(f4000, savefigname);
cd(workpath);

% ----------------------------------------------------------------
%  Q4b - RMSE (computed based on Nrep repitition)
% ----------------------------------------------------------------
[kf_s_up, kf_P_up, kf_loglik] = kalman_filter_ini(x0,P0,A,B,Phi,R,H,S2,yt);

pf_err_st  = zeros(T,Nrep,nSet); %error of mean estimates of states (Nrep by T)
pf_err_lk  = zeros(T,Nrep,nSet);
% tic
for j = 1:1:nSet % loop over # particle
    Nparticle = Nparticle_Set(j);
    for i = 1:1:Nrep % loop over repitition
        [loglik, all_s_up, Neff] = PF_lin_ini(A, B, H, Phi, R, S2, Nparticle, yt, x0, P0);

        pf_err_st(:,i,j) = mean(all_s_up,3) - kf_s_up;
        pf_err_lk(:,i,j) = loglik - kf_loglik;
    end
end
% toc
tab_mse_st = squeeze(mean(mean(pf_err_st.^2)))';
tab_mse_lk = mean(squeeze(sum(pf_err_lk,1)).^2);
tab_mse    = [tab_mse_st; tab_mse_lk];


% Figure: RMSE of state estimates
f4 = figure(4);
ax = setmyfig(f4, [2.5, 1.1, 8, 8]);
plot(mean(pf_err_st(:,:,1).^2,2), 'b', 'linewidth', 3)
hold on
plot(mean(pf_err_st(:,:,2).^2,2), 'color', rgb('green'), 'linewidth', 3)
plot(mean(pf_err_st(:,:,3).^2,2), 'r', 'linewidth', 3)
hold off
title('RMSE: s_{t}', 'fontsize', 20);
l = legend(table_header_c(3:end));
set(l, 'location', 'northeast', 'fontsize', 20);
set(gca, 'fontsize', 20, 'linewidth', 2);

savefilename = ['figQ4_rmse_st.png'];
cd(savepath);
saveas(f4, savefilename);
cd(workpath);

% Figure: RMSE of log-likelihood
f41 = figure(41);
ax = setmyfig(f41, [2.5, 1.1, 8, 8]);
plot(sqrt(mean(pf_err_lk(:,:,1).^2,2)), 'b', 'linewidth', 3)
hold on
plot(sqrt(mean(pf_err_lk(:,:,2).^2,2)),'color', rgb('green'), 'linewidth', 3)
plot(sqrt(mean(pf_err_lk(:,:,3).^2,2)),'r', 'linewidth', 3)
hold off
title('RMSE: Log-likelihood', 'fontsize', 20);
l = legend(table_header_c(3:end));
set(l, 'location', 'northwest', 'fontsize', 20);
set(gca, 'fontsize', 20, 'linewidth', 2);

savefilename = ['figQ4_rmse_lik.png'];
cd(savepath);
saveas(f41, savefilename);
cd(workpath);


% ----------------------------------------------------------------
%  Q5 - With/Without resampling, compare Neff
% ----------------------------------------------------------------
Nparticle = 1000;
[lik, all_s_up, Neff1]       = PF_lin_ini(A, B, H, Phi, R, S2, Nparticle, yt, x0, P0);
[lik, all_s_fore, all_s_up, Neff2, all_weights] = PF_lin_noResp(A, B, H, Phi, R, S2, Nparticle, yt, x0, P0);

% figure
f5 = figure(5);
ax = setmyfig(f5, [2.5, 1.1, 8, 8]);
plot(Neff1, '--', 'linewidth', 4, 'color', 'b')
hold on
plot(Neff2, '-', 'linewidth', 4, 'markersize', 20, 'color', 'r')
hold off
title('ESS: With and without resampling', 'fontsize', 20);
l = legend('with resampling', 'without resamplind');
set(l, 'location', 'southeast', 'fontsize', 20);
set(gca, 'LineWidth', 1.5);
set(gca, 'Fontsize', 13);

savefilename = ['figQ5_ess_noResp.png'];
cd(savepath);
saveas(f5, savefilename);
cd(workpath);

% ----------------------------------------------------------------
%  Q6 - Outlier, PF
% ----------------------------------------------------------------
Nparticle = 500;

% outlier in measurement
[kf_s_up2, kf_P_up2, kf_loglik2] = kalman_filter_ini(x0,P0,A,B,Phi,R,H,S2,yt_out2);
[loglik2, all_s_up2, Neff2]      = PF_lin_ini(A, B, H, Phi, R, S2, Nparticle, yt_out2, x0, P0);

% figure
f601 = figure(601);
ax = setmyfig(f601, [2.5, 1.1, 8, 8]);
plot(squeeze(all_s_up2), 'color', rgb('lightgrey'))
hold on
plot(kf_s_up2, 'linewidth', 3, 'color', 'g')
% plot(s, '--', 'linewidth', 2, 'color', 'r')
plot(mean(squeeze(all_s_up2),2), '--', 'linewidth', 3, 'color', 'r')
hold off
title('Outlier in 25th obs, PF vs KF', 'fontsize', 20);
set(gca, 'fontsize', 20, 'linewidth', 2);

savefilename = ['figQ6_st_pf.png'];
cd(savepath);
saveas(f601, savefilename);
cd(workpath);


% ----------------------------------------------------------------
%  Q7 - Outlier, PF-KF
% ----------------------------------------------------------------
Nparticle = 500;

% outlier in measurement
[kf_s_up4, kf_P_up4, kf_loglik4] = kalman_filter_ini(x0,P0,A,B,Phi,R,H,S2,yt_out2);
[loglik4, all_s_up4, Neff4]      = PFKF_lin_ini(A, B, H, Phi, R, S2, Nparticle, yt_out2, x0, P0);

% figure
f701 = figure(701);
ax = setmyfig(f701, [2.5, 1.1, 8, 8]);
plot(squeeze(all_s_up4), 'color', rgb('lightgrey'))
hold on
plot(kf_s_up4, 'linewidth', 3, 'color', 'g')
% plot(s, '--', 'linewidth', 2, 'color', 'r')
plot(mean(squeeze(all_s_up4),2), '--', 'linewidth', 3, 'color', 'r')
hold off
title('Outlier in 25th obs, KFPF vs KF', 'fontsize', 20);
set(gca, 'fontsize', 20, 'linewidth', 2);

savefilename = ['figQ7_st_pfkf.png'];
cd(savepath);
saveas(f701, savefilename);
cd(workpath);


% figure: ESS
f707 = figure(707);
ax = setmyfig(f707, [2.5, 1.1, 8, 8]);
plot(Neff2, '--', 'color', 'b', 'linewidth', 3);
hold on
plot(Neff4, 'color', 'r', 'linewidth', 3);
hold off
title('ESS (outlier in 25th obs)', 'fontsize', 20);
l = legend('PF', 'PF-KF');
set(l, 'location', 'southeast', 'fontsize', 20);
set(gca, 'fontsize', 20, 'linewidth', 2);

savefilename = ['figQ7_ess.png'];
cd(savepath);
saveas(f707, savefilename);
cd(workpath);


% ----------------------------------------------------------------
%  Q8 - Outlier, Assess accuracy: RMSE comparison
% ----------------------------------------------------------------
Nparticle = 500;

% figure: RMSE
pf_err_st1  = zeros(T,Nrep,nSet); %error of mean estimates of states (Nrep by T)
pf_err_lk1  = zeros(T,Nrep,nSet);

pf_err_st2  = zeros(T,Nrep,nSet); %error of mean estimates of states (Nrep by T)
pf_err_lk2  = zeros(T,Nrep,nSet);

% KF
[kf_s_up, kf_P_up, kf_loglik] = kalman_filter_ini(x0,P0,A,B,Phi,R,H,S2,yt_out2);

% PF
j=1; % we don't run loop over the # of particles
for i = 1:1:Nrep % loop over repitition
    [loglik1, all_s_up1, Neff1] = PF_lin_ini(A, B, H, Phi, R, S2, Nparticle, yt_out2, x0, P0);
    [loglik2, all_s_up2, Neff2] = PFKF_lin_ini(A, B, H, Phi, R, S2, Nparticle, yt_out2, x0, P0);

    pf_err_st1(:,i,j) = mean(all_s_up1,3) - kf_s_up;
    pf_err_st2(:,i,j) = mean(all_s_up2,3) - kf_s_up;

    pf_err_lk1(:,i,j)   = loglik1 - kf_loglik;
    pf_err_lk2(:,i,j)   = loglik2 - kf_loglik;
end

tab_mse_st1 = squeeze(mean(mean(pf_err_st1.^2)))';
tab_mse_lk1 = mean(squeeze(sum(pf_err_lk1,1)).^2);
tab_mse1    = [tab_mse_st1; tab_mse_lk1];

tab_mse_st2 = squeeze(mean(mean(pf_err_st2.^2)))';
tab_mse_lk2 = mean(squeeze(sum(pf_err_lk2,1)).^2);
tab_mse2    = [tab_mse_st2; tab_mse_lk2];

% Figure: RMSE compared to KF
f801 = figure(801);
ax = setmyfig(f801, [2.5, 1.1, 8, 8]);
plot(sqrt(mean(pf_err_st1(:,:,1).^2,2)), 'b', 'linewidth', 3)
hold on
plot(sqrt(mean(pf_err_st2(:,:,1).^2,2)),'color', rgb('red'), 'linewidth', 3)
hold off
title('RMSE: s_{t}', 'fontsize', 20)
l = legend('PF', 'PF-KF');
set(l, 'location', 'northwest', 'fontsize', 20);
set(gca, 'fontsize', 20, 'linewidth', 2);

savefilename = ['figQ8_rmse_st.png'];
cd(savepath);
saveas(f801, savefilename);
cd(workpath);

f802 = figure(802);
ax = setmyfig(f802, [2.5, 1.1, 8, 8]);
plot(sqrt(mean(pf_err_lk1(:,:,1).^2,2)), 'b', 'linewidth', 3)
hold on
plot(sqrt(mean(pf_err_lk2(:,:,1).^2,2)),'color', rgb('red'), 'linewidth', 3)
hold off
title('RMSE: Log-likelihood', 'fontsize', 20)
l = legend('PF', 'PF-KF');
set(l, 'location', 'northwest', 'fontsize', 20);
set(gca, 'fontsize', 20, 'linewidth', 2);

savefilename = ['figQ8_rmse_lik.png'];
cd(savepath);
saveas(f802, savefilename);
cd(workpath);

% Report computation time
disp('--------------------------------------');
disp(['All computation tooks : ', num2str(toc), ' sec.']);
