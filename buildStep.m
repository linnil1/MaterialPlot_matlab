function expr = buildStep(fun, sori, sstart, send)
    syms x;
    sstart = eval(sstart);
    send = eval(send);

    read(symengine, 'Stepfunc.mu');
    fun = subs(fun, x - sori);
    up_cof = taylorcoeff(fun, sstart);
    up_expr = coefftaylor(up_cof, sstart, true);
    dn_cof = taylorcoeff(-coefftaylor(up_cof, sstart), send);
    dn_expr = coefftaylor(dn_cof, send, true);
    expr = up_expr + dn_expr;
    fplot(expr,[0 5]);
end


function cof = taylorcoeff(fun, a)
    p = sym2poly(fun);
    num = 0;
    cof = [];
    while any(p)
        cof(end + 1) = polyval(p, a) / factorial(num);
        p = polyder(p);
        num = num + 1;
    end
end

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
        
function sf = stepf(a,n)
    sf = feval(symengine, 'Stepfunc', a, n);
end