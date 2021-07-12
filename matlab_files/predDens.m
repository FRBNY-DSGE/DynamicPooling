function [pD fD] = predDens(pred,vpred,TTT,DD,ZZ,YYfinal,F,k)

% grow measurment equation to accommodate k-step ahead predictive density
ZZtil = kron(eye(k),ZZ);
DDtil = kron(ones(k,1),DD);

% map predicted states to observables
y_tk  = DDtil + ZZtil*pred;

% number of states
nS    = size(vpred,1);

% initialize covariance matrix of k-step ahead predictive density
Phat  = zeros(nS*k,nS*k);


% calculate Phat
for I = 1:k
    for J = 1:k
        tmp = vpred(:,:,min(I,J));

        e = J-I;

        if e < 0        % cov(I-step ahead, J-step ahead)
            tmp = TTT^abs(e)*tmp;
        elseif e > 0    % cov(J-step ahed, I-step ahead)
            tmp = tmp*(TTT^e)';
        end

        Phat((I-1)*nS+1:I*nS,(J-1)*nS+1:J*nS) = tmp;
    end
end

% calculate predictive density of f_{t:t+k} = F*y_{t:t+k}
pD = mvnpdf(F*reshape(YYfinal',size(YYfinal,1)*size(YYfinal,2),1),...
    F*y_tk,single(F*ZZtil*Phat*ZZtil'*F'));

fD = (F*y_tk)';
