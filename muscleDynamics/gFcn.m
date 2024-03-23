function out = gFcn(lCE)
% 

if lCE > 0 && lCE <= 0.5
    out = 0.5;
elseif lCE > 0.5 && lCE <= 1.0
    out = lCE;
elseif lCE > 1.0 && lCE <= 1.5
    out = -2*lCE + 3;
elseif lCE > 1.5
    out = 0;
else
    error('muscle fiber length cannot be non-positive.');
    
end