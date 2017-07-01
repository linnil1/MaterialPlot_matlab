function [funmat, remain] = sumTerms(fun)
    % turn stepfunc to matrix
    % if not stepfunc, it will be 'remain'
    syms x;
    [cof, sf] = coeffs(fun);
    sf = children(sf);
    funmat = [];
    remain = 0;
    for j = 1:length(sf)
        newrow = [cof(j) sf{j}];
        if logical(symvar(newrow(2)) ~= x) % unknow as cof
            child = children(sf{j});
            newrow = [cof(j) * child{1}, child{2}];
        end
        if length(newrow) < 3
            remain = remain + cof(j)*sf{j};
        else
            newrow(2) = x - newrow(2);
            funmat = [funmat; newrow];
        end
    end
end
