function x_ = minMax(x, xmin, xmax)

if x < xmin
    x_ = xmin;
elseif x > xmax
    x_ = xmax;
else
    x_ = x;

end