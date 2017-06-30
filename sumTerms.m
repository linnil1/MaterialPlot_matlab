function [funmat, remain] = sumTerms(fun)
    syms x;
    [cof, sf] = coeffs(fun);
    cof = cof(x) ; % why it is function
    sf = children(sf);
    funmat = [];
    remain = 0;
    for j = 1:length(sf)
        newrow = [cof(j) sf{j}];
        if length(newrow) < 3
            remain = remain + cof(j)*sf{j};
        else
            funmat = [funmat; newrow];
        end
    end
end