% MDC: Input arguments:
% mspec - the spec of the model, 805 or 904
% params - the modal parameters
% parasim - the full distribution sample of parameters
% vdate - The vintage date of the data
% YY - The main sample of data to filter s_{T|T}, P_{T|T}
% XX - A matrix of lagged data to filter s_{T0|T0}, P_{T0|T0} (the
% pre-sample)
% YYfinal - The realized data to calculate the predictive densities at
% r_exp - Rate expectations (these are provided as an argument, but are not
% used)
% peachdata - The semi-conditional data period
% peachflag - Whether or not the semi-conditional data will be used
% to get s_{T+1|T+}, P_{T+1|T+}, T+ being T data with financial variables
% F - The matrix for computing linear transforms of the data, depending on
% what averaging convention is chosen
% k - The horizon of the forecast.
function [pDens fDraw] = fnPredDens_Cai(mspec,params,parasim,vdate,YY,XX,YYfinal,r_exp,peachdata,peachflag,F,k,varargin)

%tic;

if nargin == 13
    alt_pol = varargin{1};
end

% no conintegartion
coint    = 0;
cointadd = 0;
cointall = 0;

% get various size parameters
nvar  = size(YY,2);
nlags = (size(XX,2)-1)/nvar;
npara = size(params,1);
lead  = k;
nsim  = size(parasim,1);

% initialize draw count and predictive density statistic
ct        = 1;
pDens     = nan(nsim,1);
fDraw     = nan(nsim,size(F,1));
% Calculate lagged growth rates
YY0 = zeros(nlags,size(YY,2));
for lagind = 1:nlags
    YY0(nlags-lagind+1,:) = XX(1,1+cointall+(lagind-1)*nvar+1:1+cointall+lagind*nvar);
end


for r=1:nsim

    % grab parameter draw
    params=parasim(r,:)';

    % solve model with parameter draw
    [TTT,RRR,CCC,valid] = dsgesolv(params,mspec);

    if exist('alt_pol','var')
        [TTT_alt,RRR_alt,CCC_alt,valid_alt] = dsgesolv_alt(params,mspec,0,alt_pol);
    else
        TTT_alt = TTT;
        RRR_alt = RRR;
        CCC_alt = CCC;
    end

    % calculate measurement equation with parameter draw
    [ZZ,DD,DDcointadd,QQ,EE,MM,retcode] = getmeasur(mspec,TTT,RRR,...
        valid,params,nvar,nlags,npara,coint,cointadd);

    % get number of states from TTT dimension
    nstate=size(TTT,1);

    HH = EE+MM*QQ*MM';
    VV = QQ*MM';
    VVall = [[RRR*QQ*RRR',RRR*VV];[VV'*RRR',HH]];

    % define the initial mean and variance for the state vector
    A0 = zeros(nstate,1);
    P0 = dlyap(TTT,RRR*QQ*RRR');

    %%%%%%%%%%%%%%
    % MDC Notes!
    %%%%%%%%%%%%%%

    % Outputs are:
    % pred0 and vpred0 are the s_t|t-1, P_t|t-1 for ALL t = 1:T+lead
    % (which in this case lead = 1).
    % zend and pend are s_T|T, P_T|T.
    % pyt0 is never used and neither are pred0 and vpred0,
    % so this filter is just meant to obtain the initial z, P to
    % commence the actual filter.
    % filter on presample
    [pyt0,zend,pend,pred0,vpred0] = kalcvf2NaN_lead(YY0',1,zeros(nstate,1),TTT,DD,ZZ,VVall,A0,P0);

    % unconditional forecasts
    if ~peachflag

        % Inputs are:
        % YY' - (the actual dataset)
        % lead - (the horizon of forecasts)
        % zeros(nstate, 1) - the constant in the transition eq.
        % TTT, DD, ZZ - transition and measurement equation matrices
        % VVall - the variance covariance matrix of the two shock
        % processes, \epsilon_t and u_t (structural shocks/meas. error
        % shocks)
        % zend, pend (the initial state and state covariance matrices)
        [L,zend,pend,pred,vpred]=kalcvf2NaN_lead_alt(YY',lead, ...
            zeros(nstate,1),TTT,DD,ZZ,VVall,zend,pend,zeros(nstate,1),TTT_alt);

        % Suppose lead = 1.
        % Then pred is a vector of size n_states x 1, containing s_T+1|T
        % and vpred is a matrix of size n_states x n_states, containing
        % P_T+1|T.
        % If lead > 1, then
        % pred is a stacked vector containing [s_T+1|T, ..., s_T+lead|T]
        % vpred is a 3-dim array where the final dim indexes
        % P_T+1|T, ..., P_T+lead|T.
        pred  = reshape(pred(:,end-lead+1:end),size(pred,1)*lead,1);
        vpred = vpred(:,:,end-lead+1:end);

        pDens(ct,1) = predDens(pred,vpred,TTT_alt,DD,ZZ,YYfinal,F,k);
        ct          = ct + 1;

    % forecasts conditional on (contemporaneous) FFR and Spread
    elseif peachflag

        % Kalman filter over actual sample
        [L,zend,pend,pred,vpred]=kalcvf2NaN_lead(YY',0, ...
            zeros(nstate,1),TTT,DD,ZZ,VVall,zend,pend);

        % Kalman filter over peachdata
        nstate = length(zend);
        VVall_peach = VVall;

        [L,zend,pend,pred,vpred]=kalcvf2NaN_lead_alt(peachdata',lead-1, ...
            zeros(nstate,1),TTT,DD,ZZ,VVall_peach,zend,pend,zeros(nstate,1),TTT_alt);

        % NOTE: due to conditioning on FFR and Spread the one-step ahead
        % forecasted state and cov. matrix are the final filtered states
        % (zend,pend).

        % state prediction
        pred  = reshape(pred(:,end-lead+2:end),size(pred,1)*(lead-1),1);
        pred  = [zend;pred];

        % covariance matrix prediction
        vpred = vpred(:,:,end-lead+1:end);
        vpred(:,:,1) = pend;

        % predictive density calculation
        [pDens(ct,1) fDraw(ct,:)] = predDens(pred,vpred,TTT_alt,DD,ZZ,YYfinal,F,k);
        ct = ct + 1;

    end

end

%fprintf('\n Elapsed time is %4.2f minutes',toc/60);
