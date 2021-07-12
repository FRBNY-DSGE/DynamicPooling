%% MODEL 700 is Model 6 with real wage growth;

%dates=2011;
%MODEL SPECIFICATIONS
mspec=904;
subspec=9;
pf_mod='54';
dataset=700;

peachfile='peachdata_2012_04_17';

ovint=69;
%OOS specific settings
OOS='FULL';
fmean=1;

PLOTDRAWS=0;
lastvint=0;
vcov=0;

judge='BC';

compound=0;

first=0;

qahead=40;

nantmax=0;
nant=0;
%nantmax=10;
%nant=7;
%antlags=0;

dsge=1;
gbook=1;
bluechip=0;
roch=1;

%vindex=[59];
qvint=1;

%dates=2011;
%stime=[];%111;
%mnobss=15;

REMAX_MODE=1;

%SAVE SETTINGS
overwrite = 1;


%FORECAST SETTINGS
zerobound = 1;
bdd_int_rate = 0;

dsflag = 0;
peachflag = 0;

simple_forecast = 0;


%NEWSLETTER SETTINGS
issue_num=10;

newsletter = 0;
system = 0;
pres = 1;

useSavedMB = 0;


%PARALLEL SETTINGS
%parallelflag = 1;
%parflag = 1;
distr=1;
nMaxWorkers=20;
