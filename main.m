function Y = main()
    want = 'dy';
    syms x;    
    read(symengine, 'Stepfunc.mu');
    fun(x) = stepf(x - 1, 1) + 3 * stepf(x - 2, -2);
    % fplot(fun, [0,5])
    
    % set config
    configs = setconfig(fun);
    want = strsplit(want, ',');
    for f = want
        configs(f{1}) = recurGet(configs, f{1});
    end
    disp(configs('dy'));
end

function formula = recurGet(configs, want)
    now = configs(want);
    if isa(now, 'function_handle')
        now = now(configs);
        configs(want) = now;
    end
    formula =  now;
end

function config = setconfig(f)
    syms x c1 c2;   
    % be aware of the integral is fake, it is diff in real 
    keySet =  {...
        'F', f,...
        'V', @(config)(-integralStep(recurGet(config, 'F'))),...
        'M', @(config)(-integralStep(recurGet(config, 'V'))),...
        'dy', @(config)(c1 + integralStep(recurGet(config, 'M'))),...
        'y', @(config)(c1 * x + c2 + integralStep(recurGet(config, 'dy'))),...
        'Fint', @(config)(-integralStep(recurGet(config, 'F'))),...
        'P', @()(1),...
        'dx',@(config)(integralStep(recurGet(config, 'P'))),...
        'T', f,...
        'Tint', @(config)(-integralStep(recurGet(config, 'T'))),...
        'A', @()(1)};
    len  = length(keySet);
    config = containers.Map(keySet(1:2:len), keySet(2:2:len));
end

function sf = stepf(a,n)
    sf = feval(symengine, 'Stepfunc', a, n);
end
function sf = integralStep(f)
    syms x;
    sf = feval(symengine, 'integral', f, x);
end
