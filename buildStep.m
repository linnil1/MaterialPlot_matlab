function expr = buildStep(fun, sori, sstart, send)
    % turn polynoimal function to step function
    syms x;
    if isa(sstart, 'sym')
        sstart = eval(sstart);
    end
    if isa(send, 'sym')
        send = eval(send);
    end
    read(symengine, 'Stepfunc.mu');

    fun = subs(fun, x, x - sori);
    up_cof = taylorcoeff(fun, sstart);
    up_expr = coefftaylor(up_cof, sstart, true);
    dn_cof = taylorcoeff(-coefftaylor(up_cof, sstart), send);
    dn_expr = coefftaylor(dn_cof, send, true);
    expr = up_expr + dn_expr;
    % fplot(expr,[0 5]);
end

% build-in taylor function is not good
function cof = taylorcoeff(fun, a)
    syms x;
    num = 0;
    cof = [];
    % numberic methods
%     p = sym2poly(fun);
%     while any(p)
%         cof(end + 1) = polyval(p, a) / factorial(num);
%         p = polyder(p);
%         num = num + 1;
%     end
    % sym methods
    while logical(fun ~= 0)
        cof = [cof, subs(fun, x, a) / factorial(num)];
        fun = diff(fun ,x);
        num = num + 1;
    end
end

% convert back
function fun = coefftaylor(cof, a, ~)
    syms x;
    fun = 0;
    for i = 1:length(cof)
        if nargin < 3
            fun = fun + cof(i) * (x - a) ^ (i - 1);
        else
            fun = fun + cof(i) * stepf(x - a, i - 1);
        end
    end
end

% deplicated
function sf = stepf(a,n)
    sf = feval(symengine, 'Stepfunc', a, n);
end
