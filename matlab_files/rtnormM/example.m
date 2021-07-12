% Example for using RTNORM
% vincent.mazet@unistra.fr, July 2012

clear all;
close all;

% Variables
a = 1;     % Left bound
b = 9;      % Right bound
mu = 2;     % "Mean"
sigma = 3;  % "Variance"

% Use N points for the plot
N = 500;
nmin = a - (b-a)/50;
nmax = b + (b-a)/50;
n = linspace(nmin,nmax,N);
dn = (nmax-nmin) / (N-1);

% Truncated Gaussian distribution
A = (a-mu)/sqrt(2)/sigma;
B = (b-mu)/sqrt(2)/sigma;
Z = sqrt(pi/2)*sigma * (erf(B)-erf(A)) ;
pdf = exp(-(n-mu).^2/2/sigma^2) / Z .* (n>=a) .* (n<=b);


%% Generate a big number of variables and plot the histogram

% Number of RV to generate
K = 1e5;

% Random variable generation
x = zeros(K,1);
for k = 1:K,
    x(k) = rtnorm(a,b,mu,sigma);
end;

% Plot the PDF and the normalized histogram
figure; hold on; box on;
h = histc(x,n);
bh = bar(n,h/K/dn,'histc');
set(bh,'EdgeColor',[0 0 .5]);
plot(n,pdf,'r');
xlabel('x');
ylabel('p(x)');
title('PDF and the normalized histogram');
legend('Norm. hist.','PDF');

%% Generate a small number of variables and plot their probability

% Number of RV to generate
K = 100;

% Random variable generation
x = zeros(K,1);
p = zeros(K,1);
for k = 1:K,
    [xk,pk] = rtnorm(a,b,mu,sigma);
    x(k) = xk;
    p(k) = pk;
end;

% Plot the PDF and the normalized histogram
figure;
plot(n,pdf,'r', x,p,'b.');
xlabel('x');
ylabel('p(x)');
title('PDF and some realizations');
legend('PDF','Some realizations');
