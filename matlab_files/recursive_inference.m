% How to use: see line 16-26
% and set `spec_file`, `savefn_tail`, and `vint` as desired

%% ------------------------------------------------------------------------
% Add necessary paths
% -------------------------------------------------------------------------
list_path = {'Procedures/Filtering/toolbox_filtering/';...
    'Procedures/';'rtnormM/';'pool_spec/';'priors/';'dsge_solution/'};

addpath(list_path{:})

%% ------------------------------------------------------------------------
% recursive_inference.m: estimate parameters recursively
% -------------------------------------------------------------------------

%% ------------------------------------------------------------------------
% Set parameters
% -------------------------------------------------------------------------
spec_file = 'R_spec06'; % R for recrusive, 04 -> prior 1, 06 -> prior 2, 13 -> prior 3
savefn_tail = '_correct'; % tail of the save filename (either '' or '_correct'), note fn in this case is NOT function but file name
vint = '20210615'; % vintage of the run date
if ~exist('spec_file','var')
    spec_file = 'R_spec01';
end
eval(spec_file);
test = testVars(testName,{},semicond);
use_parallel = false;

%% ------------------------------------------------------------------------
% load predictive densities
% -------------------------------------------------------------------------

% if semi-conditional, change save file names
if semicond
  p_string='_semicond';
else
  p_string='';
end

f904 = fopen(['input_data/predictive_density_means_904_10-Jan-1992_to_10-Apr-2011_',testName,p_string],'r');
f805 = fopen(['input_data/predictive_density_means_805_10-Jan-1992_to_10-Apr-2011_',testName,p_string, savefn_tail],'r');
p904 = fread(f904,'single');
p805 = fread(f805,'single');

% get date series
fd904 = fopen(['input_data/predictive_density_fdates_904_10-Jan-1992_to_10-Apr-2011_',testName,p_string],'r');
dt    = fread(fd904,'single');

T = length(dt);

%% ------------------------------------------------------------------------
% recursive estimation
% -------------------------------------------------------------------------
nCap = 39;
nMax = min(T,nCap);

err = cell([T 1]);
env = cell([T 1]);
ok  = nan([T 1]);

if use_parallel
	parpool(nMax)

	tic()
	parfor i_ = 1:T
	    list_args = {'parameter_inference',...
	        ['spec_file = ''',spec_file,'''; T = ',num2str(i_),...
	        '; savefn_tail = ''',savefn_tail,...
			'''; set(0,''DefaultFigureVisible'',''off'')'],...
	        {'draws_para','draws_lam','rej_prct','draws_LL','draws_pri'}};

	    [ok(i_),err{i_},env{i_}] = script_wrap_fn(list_args{:});
	end
	toc()

    poolobj = gcp('nocreate');
    delete(poolobj);
else
	for i_ = 1:T
	    list_args = {'parameter_inference',...
	        ['spec_file = ''',spec_file,'''; T = ',num2str(i_),...
	        '; savefn_tail = ''',savefn_tail,...
			'''; set(0,''DefaultFigureVisible'',''off'')'],...
	        {'draws_para','draws_lam','rej_prct','draws_LL','draws_pri'}};

	    [ok(i_),err{i_},env{i_}] = script_wrap_fn(list_args{:});
	end
	toc()
end

if any(cellfun(@(x) ~isempty(x),err))
    error('One of your parallel runs ate it big time... check the err variable for more info!');
end

%% ------------------------------------------------------------------------
% join results
% -------------------------------------------------------------------------

draws_para = NaN([N k T]);
draws_lam  = NaN([N T]);
rej_prct   = NaN([1 T]);
draws_LL   = NaN([N T]);
draws_pri  = NaN([N T]);

for j_ = 1:T

    for k_ = 1:length(env{j_})
        if strcmp(env{j_}{k_}{1},'draws_para')
            tmp = '(:,:,';
        else
            tmp = '(:,';
        end

        eval([env{j_}{k_}{1},tmp,num2str(j_),') = env{',num2str(j_),'}{',num2str(k_),'}{2};']);
    end
end
save(['../matlab_save_files/draws_para_vint=' vint '_' spec_file savefn_tail '.mat'], 'draws_para');
save(['../matlab_save_files/draws_lam_vint=' vint '_' spec_file savefn_tail '.mat'], 'draws_lam');
save(['../matlab_save_files/draws_LL_vint=' vint '_' spec_file savefn_tail '.mat'], 'draws_LL');

disp('Finished estimating dynamic prediction pool');
