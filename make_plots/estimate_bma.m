function f = estimate_bma(data, prior)

  lambda = zeros(size(data,1), 1);
  
  lambda(1) = prior * data(1,1) / (prior * data(1,1) + (1 - prior) * data(1,2));
  
  for i = 2:size(data,1)
     lambda(i) = lambda(i-1) * data(i,1) / (lambda(i-1) * data(i,1) + (1 - lambda(i-1)) * data(i,2));
  end
  
  f = lambda;
end
