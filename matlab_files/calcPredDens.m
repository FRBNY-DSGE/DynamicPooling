%% ------------------------------------------------------------------------
% calcPredDens_Cai.m:
% -------------------------------------------------------------------------
% AUTHOR: Raiden B. Hasegawa
% ECONOMIST: Marco Del Negro
% ORIGINAL_DATE: 2013-07-12

% ARCHAEOLOGIST: Michael Cai
% EXCAVATION_DATE: 2019-01-29
% Run with matlab14a

% ARCHAEOLOGIST 2: William Chen
% EXCAVATION_DATE: 2019-06-24
% Edited scripts for release of corrigendum replication code
% ------------------------------------------------------------------------

%% ------------------------------------------------------------------------
% Set specifications: need to be set b the user!
% -------------------------------------------------------------------------

tic;                % start timer
list_path = {'Procedures/Filtering/toolbox_filtering/';...
    'Procedures/';'rtnormM/';'pool_spec/';'priors/';'model_spec/';'dsge_solution/'};

addpath(list_path{:})
spec_805;          % get model-specific specs
% spec_904;

% density_tail = 'm805_correct'; % select the desired density to compute
density_tail = 'm805_wrong'; % loads from 'input_data/preddens_input_data_density_tail';
% density_tail = 'm904';

semicond   = 1;         % (1) semiconditional OR (0) unconditional

% distr = 1;
distr = 0;
nMaxWorkers = 40;       % max number of workers to be used in parallel jobs
% nMaxWorkers = 1;       % max number of workers to be used in parallel jobs
if distr;  poolobj = parpool(nMaxWorkers); end

% Data and Output details
testName = 'output_and_inflation_annualized';
% obs_indices = [1,2,3,4,5,6,7,9]; % m805 observable indices [excludes spreads]
obs_indices = [1,2,3,4,5,6,7,8];
% obs_indices = [1,2,3,4,5,6,7,8,9]; % m904 observable indices

% alt_pol  = '003'; % '003': labor market policy rule, EMPTY: normal rule

outpath = 'input_data/';
if ~exist(outpath,'dir'); mkdir(outpath); end

[estpath,estfile] = selectEst(mspec);         % get estimation path and file

if semicond             % if semi-conditional, change save file names
  p_string='_semicond';
else
  p_string='';
end

jstep = 5;

% p_string = [p_string '_correct']; % Uncomment if using corrected data

%% ------------------------------------------------------------------------
% load estimation results and input data
% -------------------------------------------------------------------------

estResults = matfile([estpath,estfile]);
load(['input_data/preddens_input_data_', density_tail]);

vintDates  = estResults.EstOut(:,8);

%% ------------------------------------------------------------------------
% match dates of parameter estimates and data
% -------------------------------------------------------------------------

matchDates = intersect(vintDates,vintDataDates);
matchDates = cellstr(datestr(sort(datenum(matchDates))));

nBatches   = size(matchDates,1);      % number of parallel jobs

forDates   = nan(size(matchDates));

%% ------------------------------------------------------------------------
% open files for writing
% -------------------------------------------------------------------------

if exist('alt_pol','var')
    alt_pol_str = [alt_pol,'_'];
else
    alt_pol_str = '';
end

% save draws
fDraws = fopen([outpath,'predictive_density_draws_',num2str(mspec),...
    '_',alt_pol_str,matchDates{1},'_to_',matchDates{end},'_',testName,p_string],'w');

% save means
fMeans = fopen([outpath,'predictive_density_means_',num2str(mspec),...
    '_',alt_pol_str,matchDates{1},'_to_',matchDates{end},'_',testName,p_string],'w');

% save vintage dates
fVdates  = fopen([outpath,'predictive_density_vdates_',num2str(mspec),...
    '_',alt_pol_str,matchDates{1},'_to_',matchDates{end},'_',testName,p_string],'w');

% save forecast dates
fFdates  = fopen([outpath,'predictive_density_fdates_',num2str(mspec),...
    '_',alt_pol_str,matchDates{1},'_to_',matchDates{end},'_',testName,p_string],'w');

% save forecast draws
fFcast = fopen([outpath,'fcast_draws_',num2str(mspec),...
    '_',alt_pol_str,matchDates{1},'_to_',matchDates{end},'_',testName,p_string],'w');

%% ------------------------------------------------------------------------
% calculate predictive density at each vintage
% -------------------------------------------------------------------------

for J = 1:nBatches
    vintage_date = vintage_date_by_period{J}; % Holds date of data vintage
    XXall = XXall_by_period{J};               % Matrix of lagged covariates. Appears to be a holdover from VAR code and only used for fitlering the pre-sample in fnPredDens.
    YYall = YYall_by_period{J};               % Matrix of observables data
    YYfinal = YYfinal_by_period{J};           % Per-capita observables data
    r_exp = r_exp_by_period{J};               % FFR expectations
    peachdata = peachdata_by_period{J};       % FFR Nowcast

    params  = estResults.EstOut(J,1);           % modal parameters
    params  = params{1};

    parasim = estResults.EstOut(J,5);           % parameter draws
    parasim = parasim{1};
    nsim    = size(parasim,1);


    pDens = cell(nMaxWorkers,1);
    fcast = cell(nMaxWorkers,1);

    for I = 1:nMaxWorkers
        idx = ceil(nsim/(jstep*nMaxWorkers))*(I-1)+...
            (1:ceil(nsim/(jstep*nMaxWorkers)));
        idx = idx(idx<=nsim/jstep);
        if ~exist('alt_pol','var')
            JobOptions{I} = {mspec, params, parasim(idx,:), vintage_date, ...
                YYall, XXall, YYfinal, r_exp, peachdata, semicond, F, test.k};
        else
            JobOptions{I} = {mspec,params,parasim(idx,:),vintage_date,...
                YYall,XXall,YYfinal,r_exp,peachdata,semicond,F,test.k,alt_pol};
        end
    end

    tic;

    if distr % run distributive parallel jobs

        parfor I = 1:nMaxWorkers
            [pDens{I}, fcast{I}]= fnPredDens(JobOptions{I}{:});
        end

    else     % run sequentially

        for I = 1:nMaxWorkers
            [pDens{I}, fcast{I}] = fnPredDens(JobOptions{I}{:});
        end

    end

    fprintf(1,'Batch %i complete (Elapsed time is %4.2f minutes)\n',J,toc/60);

    fcast = cell2mat(fcast);
    pDens = cell2mat(pDens);

    % save draws and means
    fwrite(fDraws,pDens(:),'single');
    fwrite(fMeans,mean(pDens(:)),'single');
    fwrite(fFcast,fcast(:),'single');

    clear JobOut JobOptions pDens;
end

%% ------------------------------------------------------------------------
% save vintage and forecast dates
% -------------------------------------------------------------------------
fwrite(fVdates,datenum(matchDates),'single');
fwrite(fFdates,forDates,'single');

if distr; delete(poolobj); end % close pool
fclose('all');       % close all files

toc;                 % end timer

total_time = toc; % compute run time in seconds
