% This script reproduces Figure 6 in the original paper
% when using draws from the posterior and prior 1.
% To run this script for the static pool,
% you'll need to have run `static_recursive.m`
% so that `draws_lam` is in` `static_lambda_ss1.mat`
% and `static_lambda_ss2.mat`
%
% Written by William Chen, Aug. 2019

dynamic_vintage = '20210615'; % estimation vintage for the dynamic pool
static_vintage = '210615';    % estimation vintage for the static pool
base = ['../matlab_save_files/draws_lam_vint=' dynamic_vintage '_R_spec04'];
base_static = '../matlab_save_files/';

results_dir = '../figures/';
fn = cell(2,1); % filename vector
hist_evol_save = cell(2,1); % output png name
hist_static_save = cell(2,1);
prior = 1;
fn{1} = ''; % for matlab results
fn{2} = '_correct';
hist_evol_save{1} = ['HISTOGRAM_evol_wrongorigmatlab_matlabdraws=true_prior=1_vint=' dynamic_vintage(3:end)];
hist_static_save{1} = ['HISTOGRAM_static_wrongorigmatlab_matlabdraws=true_prior=1_vint=' dynamic_vintage(3:end)];
hist_evol_save{2} = ['HISTOGRAM_evol_right805orig904_matlabdraws=true_prior=1_vint=' dynamic_vintage(3:end)];
hist_static_save{2} = ['HISTOGRAM_static_right805orig904_matlabdraws=true_prior=1_vint=' dynamic_vintage(3:end)];
pm_ss_fn = cell(2,1); % same for static
pm_ss_fn{1} = ['static_lambda_ss1_vint=' static_vintage];
pm_ss_fn{2} = ['static_lambda_ss2_vint=' static_vintage];

datevec = 1992.25:.25:2011.5;
for i = 1:length(fn)
    fig = figure();

	% Dynamic pool
	lambda_t_evol = load([base fn{i}], 'draws_lam'); % for matlab results
    lambda_t_evol = lambda_t_evol.draws_lam;
	hist_out = hist_evol(lambda_t_evol, datevec, [0,1], 'fre-dia', 0);
	if max(zlim) > 30
		zlim([0 30]);
    end

    % save
    hgsave(fig,[results_dir,hist_evol_save{i}, '.fig']);

    fig = figure();
	% Static pool
	lambda_t_static = load([base_static pm_ss_fn{i}], 'draws_lam');
    lambda_t_static = lambda_t_static.draws_lam;
	hist_out = hist_evol(lambda_t_static, datevec, [0,1], 'fre-dia', 0);
	if max(zlim) > 30
		zlim([0 30]);
	end

    % save
    hgsave(fig,[results_dir,hist_static_save{i}, '.fig']);

    %% --------------------------------------------------------------------
    % Make these .fig files .png files!!!
    % ---------------------------------------------------------------------
    [rc list_fig] = system(['ls ',results_dir,' | grep .fig']);
        list_fig = regexp(list_fig,'\n','split');
        for j_ = 1:length(list_fig)
            tmp_file = [results_dir,list_fig{j_}];
            if exist(tmp_file,'file') && ~strcmp(list_fig{j_},'')
                h = hgload(tmp_file);
                print(h,'-r300','-dpng',strrep(tmp_file,'.fig','.png'));
                system(['rm ',tmp_file]);
            end
        end

end

disp('Done with saving plots');
