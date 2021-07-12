%% ------------------------------------------------------------------------
% pmmh2.m: particle marginal metropolis hastings (PMMH)
% A generalization of the RWMH that allows the user to calculate the
% likelihood using particle filter techniques.
% -------------------------------------------------------------------------
% AUTHOR: Raiden B. Hasegawa
% ECONOMIST: Marco Del Negro
% DATE: 2013-12-04
% -------------------------------------------------------------------------

function [draws_thet,draws_X,rej_prct,varargout] = pmmh2(pr_fcnHandle,lik_fcnHandle,...
    prop_fcnHandle,propPr_fcnHandle,thet_init,N,varargin)
%% ------------------------------------------------------------------------
% Setup prior, likelihood and proposal functions
% -------------------------------------------------------------------------
if nargin == 10
    if ~isempty(varargin{1})
        prF     = @(x) pr_fcnHandle(x,varargin{1}{:});
    else
        prF     = @(x) pr_fcnHandle(x);
    end

    if ~isempty(varargin{2})
        likF = @(x) lik_fcnHandle(x,varargin{2}{:});
    else
        likF = @(x) lik_fcnHandle(x);
    end

    if ~isempty(varargin{3})
        propF   = @(x) prop_fcnHandle(x,varargin{3}{:});
    else
        propF   = @(x) prop_fcnHandle(x);
    end

    if ~isempty(varargin{4})
        propPrF   = @(x,y) propPr_fcnHandle(x,y,varargin{3}{:});
    else
        propPrF   = @(x,y) propPr_fcnHandle(x,y);
    end

elseif nargin == 6
    prF     = @(x) pr_fcnHandle(x);
    likF    = @(x) lik_fcnHandle(x);
    propF   = @(x) prop_fcnHandle(x);
    propPrF = @(x,y) propPr_fcnHandle(x,y);

else
    error(['If you specify args for any of the function handle inputs',...
        ' you must specify args for all... you can of course set the',...
        ' args to be empty (i.e. {})']);
end

%% ------------------------------------------------------------------------
% PMMH Initialization (STEP 1)
% -------------------------------------------------------------------------
[LL_init,~,X_init] = propStep(thet_init,1);

draws_thet = nan([N,length(thet_init)]);
draws_X    = nan([N,length(X_init)]);

if nargout > 3
    draws_LL = nan([N,1]);
    if nargout > 4
        draws_pri = nan([N,1]);
    end
end

LL_last   = LL_init;
thet_last = thet_init;
X_last    = X_init;

rej = 0;

%% ------------------------------------------------------------------------
% Main PMMH Loop (STEP 2)
% -------------------------------------------------------------------------
for I = 1:N

    [LL_star, thet_star, X_star] = propStep(thet_last);
    A = accPr(thet_last,thet_star,LL_star,LL_last);

    if rand() <= A
        LL_last   = LL_star;
        thet_last = thet_star;
        X_last    = X_star;
    else
        rej = rej + 1;
    end

    draws_thet(I,:) = thet_last;
    draws_X(I,:)    = X_last;

    if nargout > 3
        draws_LL(I,:) = LL_last;
        if nargout > 4
            draws_pri(I,:) = prF(thet_last);
        end
    end
end

%% ------------------------------------------------------------------------
% Rejection Percentage
% -------------------------------------------------------------------------
rej_prct = rej/N;

%% ------------------------------------------------------------------------
% Acceptance Probability
% -------------------------------------------------------------------------
    function [acc_prob] = accPr(thet_last,thet_star,lik_star,lik_last)

        lik_ratio  = exp(lik_star-lik_last);
        pr_ratio   = exp(prF(thet_star)-prF(thet_last));
        prop_ratio = exp(propPrF(thet_last,thet_star)-propPrF(thet_star,thet_last));

        acc_prob   = min(1,lik_ratio*pr_ratio*prop_ratio);

    end

%% ------------------------------------------------------------------------
% Propose (Theta) x (X)
% -------------------------------------------------------------------------
    function [LL_star,thet_star,X_star] = propStep(thet_last,init)

        if nargin == 2 && init == 1
            thet_star = thet_last;
        else
            thet_star = propF(thet_last);
        end
        [LL_star,W,X] = likF(thet_star);

        K      = size(X,1);
        ind    = randsample(K,1,1,W(:,end));
        X_star = X(ind,:);
    end

%% ------------------------------------------------------------------------
% Save LL and prior draws
% -------------------------------------------------------------------------
if nargout > 3
    varargout{1} = draws_LL;
    if nargout > 4
        varargout{2} = draws_pri;
    end
end

end
