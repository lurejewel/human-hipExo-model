function y = minWithNum( x, thresh )
% description: 
%          smooth form of the function: [min(x,thresh)].


    y = -maxWithZero( thresh - x ) + thresh;
%     y = min(x,thresh);

end