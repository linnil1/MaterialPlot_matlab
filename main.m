function Y = main(mat, bound, len, show, weight)
    % weight is optional

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

    % set config(store function result)
    configs = setconfig(input2Step(mat), weight);
    for f = symuse
        configs(f{1}) = recurGet(configs, f{1});
    end

    % solve
    if ~isempty(symvar(sym(mat)))
        solved = boundSolve(bound, configs);
        for f = symuse
            configs(f{1}) = subs(configs(f{1}), solved);
        end
    end

    % output
    plotPrint(symshow, configs, len);
    Y = configs;
end

% make any other place which user-input weight
% not defined to multiply 1
function wei = allWei(weight, len)
    % range: small first
    for i = 1:size(weight)
        if weight(i,2) > weight(i,3)
            weight(i,[2 3]) = weight(i,[3 2]);
        end
    end
    % assume user-input is not overlapping
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

% modify fun by multiply weight
function weifun = rebuildWei(fun, weight)
    weifun = 0;
    syms x;
    terms = sumTerms(fun);
    for t = terms'
        now_expr = t(1) * (x - t(2)) ^ t(3);
        for wei = weight'
            if wei(3) <= t(2) % out range
                continue
            % part is in range
            elseif wei(2) <= t(2) && t(2) < wei(3)
                up_fun = buildStep(wei(1) * now_expr,...
                    0, t(2), wei(3));
                weifun = weifun + up_fun;
            else % range is inside
                up_fun = buildStep(wei(1) * now_expr,...
                    0, wei(2), wei(3));
                weifun = weifun + up_fun;
            end
        end
    end
end

function fun = input2Step(mat)
    syms x;
    fun = 0;
    for r = mat'
        % you cannot input r(3)>=0
        % (different from python version)
        if r(3) < 0
            fun = fun + r(1) * stepf(x - r(2), r(3));
        else
            sym2poly(sym(r(1))); %check polynomial
            if r(3) < r(2)
                r([2 3]) = r([3 2]);
            end
            fun = fun + buildStep(r(1), r(2), r(2), r(3));
        end
    end
end

function solved = boundSolve(bound, configs)
    % get all equations
    alleq = [];
    syms x;
    for i = 1:height(bound)
        f = bound{i,1};
        alleq = [alleq(:); ...
            subs(configs(f{1}) - bound{i,3}, x, bound{i,2})];
    end
    % solved is a structure
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

% store function and name
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

    % name
    keyName =   {'F',    'V'    ,'M'     ,'dy'              ,'y',...
        'T'     ,'Fint'          ,'P'       ,'dx'            ,...
        'Tint'           ,'A'          };
    valueName = {'Force','Shear','Moment','Deflection angle','Deflection'...
        'Torque','Internal Force','Pressure','X_displacement',...
        'Internal Torque','Twist Angle'};
    global namedict;
    namedict = containers.Map(keyName, valueName);
end

% recursively get function
function formula = recurGet(configs, want)
    now = configs(want);
    if isa(now, 'function_handle')
        now = now(configs);
        configs(want) = now;
    end
    formula =  now;
end

% whose two are connect to mupad
function sf = stepf(a,n)
    sf = feval(symengine, 'Stepfunc', a, n);
end
function sf = integralStep(f)
    syms x;
    sf = feval(symengine, 'integral', f, x);
end
