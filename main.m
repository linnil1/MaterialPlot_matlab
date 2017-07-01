function Y = main(mat, bound, len, show, weight)
    % input example
    % mat [a 0 -1; b 6 -1; -1 2 -2]
    % bound table({'V'; 'M'},[len ;len], [0 ;0])
    % len 6
    % show = 'F,V,M'

    % init
    syms x;
    read(symengine, 'Stepfunc.mu');
    symshow = strsplit(show, ',');
    symuse = unique([symshow, bound{:,1}']);

    % set weight
    if nargin == 4
        weight = [1 0 len];
    end
    weight = allWei(weight, len);

    % set config
    configs = setconfig(input2Step(mat), weight);
    for f = symuse
        configs(f{1}) = recurGet(configs, f{1});
    end

    % solve
    solved = boundSolve(bound, configs);
    for f = symuse
        configs(f{1}) = subs(configs(f{1}), solved);
    end

    % output
    plotPrint(symshow, configs, len);
    Y = configs;
end

function wei = allWei(weight, len)
    weight = sortrows(weight, 2);
    wei = [];
    s = 0;
    for w = weight'
        if s < w(2)
            wei(end + 1,:) = [1 s w(2)];
        end
        wei(end + 1,:) = w;
        s = w(3);
    end
    if s < len
        wei(end + 1,:) = [1 s len];
    end
end

function weifun = rebuildWei(fun, weight)
    weifun = fun;
    for wei = weight'
        if wei(1) ~= 1
            now_expr = expand(fun, 'MaxExponent', wei(2));
            up_fun = buildStep((wei(1) - 1) * now_expr,...
                0, wei(2), wei(3));
            weifun = weifun + up_fun;
        end
    end
end

function func = input2Step(mat)
    syms f x;
    [n, ~] = size(mat);
    f = 0;
    for i = 1:n
        r = mat(i,:);
        if r(3) < 0
            f = f + r(1) * stepf(x - r(2), r(3));
        else
            f = f + buildStep(r(1), r(2), r(2), r(3));
        end
    end
    func = f;
end

function solved = boundSolve(bound, configs)
    alleq = [];
    syms x;
    for i = 1:height(bound)
        f = bound{i,1};
        alleq = [alleq(:); ...
            subs(configs(f{1}) - bound{i,3}, x, bound{i,2})];
    end
    solved = solve(alleq);
    if length(symvar(alleq)) == 1 % matlab is bad
        solved = struct(char(symvar(alleq)), solved);
    end
    % output
    names = fieldnames(solved)';
    showans = {};
    for i = names
        showans(end+1) = {char(solved.(i{1}))};
    end
    disp(cell2table(showans,'VariableNames',names(:)));
end

function formula = recurGet(configs, want)
    now = configs(want);
    if isa(now, 'function_handle')
        now = now(configs);
        configs(want) = now;
    end
    formula =  now;
end

function config = setconfig(f, weight)
    syms x c1 c2;
    % be aware of the integral is fake, it is diff in real 
    keySet =  {...
        'F', f,...
        'V', @(config)(-integralStep(recurGet(config, 'F'))),...
        'M', @(config)(-integralStep(recurGet(config, 'V'))),...
        'dy', @(config)(c1 + integralStep(recurGet(config, 'M'))),...
        'y', @(config)(c1 * x + c2 + integralStep(recurGet(config, 'dy'))),...
        'Fint', @(config)(-integralStep(recurGet(config, 'F'))),...
        'P', @(config)(rebuildWei(recurGet(config, 'Fint'), weight)),...
        'dx',@(config)(integralStep(recurGet(config, 'P'))),...
        'T', f,...
        'Tint', @(config)(-integralStep(recurGet(config, 'T'))),...
        'A', @(config)(integralStep( ...
            rebuildWei(recurGet(config, 'Tint'), weight)))};
    len  = length(keySet);
    config = containers.Map(keySet(1:2:len), keySet(2:2:len));

    %name
    keyName =   {'F',    'V'    ,'M'     ,'dy'              ,'y',...
        'T'     ,'Fint'          ,'P'       ,'dx'            ,...
        'Tint'           ,'A'          };
    valueName = {'Force','Shear','Moment','Deflection angle','Deflection'...
        'Torque','Internal Force','Pressure','X_displacement',...
        'Internal Torque','Twist Angle'};
    global namedict;
    namedict = containers.Map(keyName, valueName);
end

function sf = stepf(a,n)
    sf = feval(symengine, 'Stepfunc', a, n);
end
function sf = integralStep(f)
    syms x;
    sf = feval(symengine, 'integral', f, x);
end
