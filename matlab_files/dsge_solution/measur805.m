function [ZZ,DD,DDcointadd,QQ,EE,MM,retcode] = measur805(TTT,RRR,valid,para,nvar,nlags,mspec,npara,coint,cointadd,nant);
%% description:
%% solution to DSGE model - delivers transition equation for the state variables  S_t
%% transition equation: S_t = TC+TTT S_{t-1} +RRR eps_t, where var(eps_t) = QQ
%% define the measurement equation: X_t = ZZ S_t +D+u_t
%% where u_t = eta_t+MM* eps_t with var(eta_t) = EE
%% where var(u_t) = HH = EE+MM QQ MM', cov(eps_t,u_t) = VV = QQ*MM'


retcode = 1;


if valid < 1;
    retcode = 0;

    ZZ = [];
    DD = [];
    QQ = [];
    EE = [];
    MM = [];
    DDcointadd = [];

    return
end

nstate = size(TTT,1);
DDcointadd = 0;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% step 1: assign names to the parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Parameters
    [alp,zeta_p,iota_p,del,ups,Bigphi,s2,h,ppsi,nu_l,zeta_w,iota_w,law,laf,bet,Rstarn,psi1,psi2,psi3,pistar,sigmac,rho,epsp,epsw...
    gam,Lmean,Lstar,gstar,rho_g,rho_b,rho_mu,rho_z,rho_laf,rho_law,rho_rm,rho_pist...
    sig_g,sig_b,sig_mu,sig_z,sig_laf,sig_law,sig_rm,sig_pist,eta_gz,eta_laf,eta_law...
    zstar,rstar,rkstar,wstar,wl_c,cstar,kstar,kbarstar,istar,ystar,pistflag] = getpara00_805(para);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% step 2: assign names to the columns of GAM0, GAM1 -- state variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

eval(strcat('states',num2str(mspec)));

%% additional states
y_t1 = n_end+n_exo+n_exp+1;
c_t1 = n_end+n_exo+n_exp+2;
i_t1 = n_end+n_exo+n_exp+3;
w_t1 = n_end+n_exo+n_exp+4;
pi_t1 = n_end+n_exo+n_exp+5; % Added 2013-2-7 (RH): add lagged pi_t state
L_t1  = n_end+n_exo+n_exp+6; % Added 2013-09-13 (RH): add lagged
                             % L_t state

if nstate ~= (n_end+n_exo+n_exp+7)

    retcode = 0;

    yyyyd = zeros(nvar,nvar);
    xxyyd = zeros(1+nlags*nvar,nvar);
    xxxxd = zeros(1+nlags*nvar,1+nlags*nvar);

    disp('\n\n number of states does not match in vaprio\n');
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% step 3: assign measurement equation : X_t = ZZ*S_t + DD + u_t
%% where u_t = eta_t+MM* eps_t with var(eta_t) = EE
%% where var(u_t) = HH = EE+MM QQ MM', cov(eps_t,u_t) = VV = QQ*MM'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% create system matrices for state space model
ZZ = zeros(nvar+coint,nstate);
%% constant
DD = zeros(nvar+coint,1);
%% cov(eps_t,u_t) = VV
MM = zeros(nvar+coint,nex);
%% var(eta_t) = EE
EE = zeros(nvar+coint,nvar+coint);
%% var(eps_t) = QQ
QQ =  zeros(nex,nex);



%% Output growth - Quarterly!
ZZ(1,y_t) = 1;
ZZ(1,y_t1) = -1;
ZZ(1,z_t) = 1;
DD(1) = 100*(exp(zstar)-1);

%% Hoursg
ZZ(2,L_t) = 1;
DD(2) = Lmean;

%% Labor Share/real wage growth
%     ZZ(3,L_t) = 1;
%     ZZ(3,w_t) = 1;
%     ZZ(3,y_t) = -1;
%     DD(3) = 100*log((1-alp)/(1+laf));

ZZ(3,w_t) = 1;
ZZ(3,w_t1) = -1;
ZZ(3,z_t) = 1;

DD(3) = 100*(exp(zstar)-1);

%% Inflation
ZZ(4,pi_t) = 1;
DD(4) = 100*(pistar-1);

%% Nominal interest rate
ZZ(5,R_t) = 1;
DD(5) = Rstarn;

%% Consumption Growth
ZZ(6,c_t) = 1;
ZZ(6,c_t1) = -1;
ZZ(6,z_t) = 1;
DD(6) = 100*(exp(zstar)-1);

%% Investment Growth
ZZ(7,i_t) = 1;
ZZ(7,i_t1) = -1;
ZZ(7,z_t) = 1;
DD(7) = 100*(exp(zstar)-1);


if pistflag
  %% 10 yrs infl exp
  TTT10 = (1/40)*((eye(size(TTT,1)) - TTT)\(TTT - TTT^41));
  ZZ(8,:) =  TTT10(pi_t,:);
  DD(8) = 100*(pistar-1);

end


%    if coint > 0

   %% consumption - output
%       ZZ(6,c_t) = 1; ZZ(6,y_t) = -1; DD(6) = 100*log(cstar/ystar);

   %% investment - output
%       ZZ(7,i_t) = 1; ZZ(7,y_t) = -1; DD(7) = 100*log(istar/ystar);

   %% labor share - output
%       ZZ(8,w_t) = 1; ZZ(8,y_t) = -1; DD(8) = 100*log(wstar/(ystar*Ladj));

%   end

%    if cointadd > 0

   %% output growth
%       DDcointadd = 100*(gam+(alp*log(ups)/(1-alp)));

%    end

QQ(g_sh,g_sh) = sig_g^2;
QQ(b_sh,b_sh) = sig_b^2;
QQ(mu_sh,mu_sh) = sig_mu^2;
QQ(z_sh,z_sh) = sig_z^2;
QQ(laf_sh,laf_sh) = sig_laf^2;
QQ(law_sh,law_sh) = sig_law^2;
QQ(rm_sh,rm_sh) = sig_rm^2;
QQ(pist_sh,pist_sh) = sig_pist^2;


if exist('nant','var')
    if nant > 0
        % These lines set the standard deviations for the anticipated shocks to
        % be equal to the standard deviation for the unanticipated policy
        % shock.
        for i = 1:nant
            eval(strcat('QQ(rm_shl',num2str(i),',rm_shl',num2str(i),') = sig_rm^2;'));
        end
    end
end
%keyboard;
