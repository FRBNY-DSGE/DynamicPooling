function [LL,w,x] = logLikStatic(y,p1,p2)

w = 1;
x = 1;
LL = sum(log(y*p1 + (1-y)*p2));
