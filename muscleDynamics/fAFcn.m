function out = fAFcn(lambda, u)

out = 40 * lambda * sin(pi*u/2) + 133 * (1-lambda) * (1-cos(pi*u/2));

end