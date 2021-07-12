function [alp,zeta_p,iota_p,del,ups,Bigphi,s2,h,ppsi,nu_l,zeta_w,iota_w,law,laf,bet,Rstarn,psi1,psi2,psi3,pistar,sigmac,rho,epsp,epsw...
    gam,Lmean,Lstar,gstar,rho_g,rho_b,rho_mu,rho_z,rho_laf,rho_law,rho_rm,rho_pist...
    sig_g,sig_b,sig_mu,sig_z,sig_laf,sig_law,sig_rm,sig_pist,eta_gz,eta_laf,eta_law...
    zstar,rstar,rkstar,wstar,wl_c,cstar,kstar,kbarstar,istar,ystar,pistflag] = getpara00_805(para)
  
alp = para(1);
zeta_p = para(2);
iota_p = para(3);
del = .025;
ups = 1;%exp(para(4)/100);%maybe take out para(5)fix 0
Bigphi = para(5);
s2 = para(6);
h = para(7);
ppsi = para(8);
nu_l = para(9);
zeta_w = para(10);
iota_w = para(11);
law = 1.5;
laf = [];
bet  = 1/(1+para(12)/100);
psi1 = para(13);
psi2 = para(14);
psi3 = para(15);
pistar = (para(16)/100)+1;
sigmac = para(17);
rho = para(18);
epsp = 10;
epsw = 10;
pistflag = para(19);

npara = 19; 


%% exogenous processes - level

gam = para(npara+1)/100;
Lmean = para(npara+2);
gstar = .18;

npara = npara+2;

%% exogenous processes - autocorrelation

rho_g = para(npara+1);
rho_b = para(npara+2);
rho_mu = para(npara+3);
rho_z = para(npara+4);
rho_laf = para(npara+5);
rho_law = para(npara+6);
rho_rm = para(npara+7);
rho_pist = para(npara+8);

npara = npara+8;


%% exogenous processes - standard deviation

sig_g = para(npara+1);
sig_b = para(npara+2);
sig_mu = para(npara+3);
sig_z = para(npara+4);
sig_laf = para(npara+5);
sig_law = para(npara+6);
sig_rm = para(npara+7);
sig_pist = para(npara+8);

eta_gz = para(npara+9);
eta_laf = para(npara+10);
eta_law = para(npara+11);

npara = npara+11;


%% Parameters (implicit) -- from steady state

zstar = log(gam+1)+(alp/(1-alp))*log(ups); 

rstar = (1/bet)*exp(sigmac*zstar);

Rstarn = 100*(rstar*pistar-1);

rkstar = rstar*ups - (1-del);

wstar = (alp^(alp)*(1-alp)^(1-alp)*rkstar^(-alp)/Bigphi)^(1/(1-alp));

Lstar = 1;

kstar = (alp/(1-alp))*wstar*Lstar/rkstar;

kbarstar = kstar*(gam+1)*ups^(1/(1-alp));

istar = kbarstar*( 1-((1-del)/((gam+1)*ups^(1/(1-alp)))) );

ystar = (kstar^alp)*(Lstar^(1-alp))/Bigphi;
if ystar <= 0

    disp([alp,  bet, kstar,Lstar])
    dm([ystar,Lstar,kstar,Bigphi])

end
cstar = (1-gstar)*ystar - istar;

wl_c = (wstar*Lstar/cstar)/law;