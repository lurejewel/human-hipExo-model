function y = maxWithZero( x )
% description: 
%          smooth form of the function: [max(x,0)].
%          made up by y1 in form of [e^(-x^2)*x] & y2 in form of [sigmoid(x)].

% satisfy: 
%          y(0) = 0
%          y(x) < 0,  x < 0
%          y(x) -> 0, x < 0
%          y(x) -> x, x > 0

    tmp1 = 1 / (1 + exp(-10*(x-0.3926)));
    tmp2 = 0.05 * exp(-0.1*(x-0.3926)^2) * (x-0.3926);
    y = (tmp1 + tmp2) * x;
%     y = max(x,0);

end