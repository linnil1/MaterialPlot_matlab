function plotPrint(symshow, configs, len)
    global namedict;
    syms x;
    for i = 1:length(symshow)
        f = symshow(i);
        fun(x) = configs(f{1});
        disp(namedict(f{1}));
        disp(fun);
        subplot(length(symshow), 1, i);
        fplot(fun, [0, len]);
        title(namedict(f{1}));

        % addition data
        hold on;
        terms = sumTerms(fun);
        impulusDraw(terms);
        minmaxFind(fun, terms, len);
        hold off;
    end
end

function impulusDraw(terms)
    syms x;
    for s3 = terms'
        if length(s3) ~= 3
            continue
        elseif s3(3) == -1
            stem(-s3(2) + x, s3(1));
            text(-s3(2) + x, s3(1), [char(-s3(2) + x) ',' char(s3(1))]);
        elseif s3(3) == -2
            stem(-s3(2) + x, s3(1), 'filled');
            text(-s3(2) + x, s3(1), [char(-s3(2) + x) ',' char(s3(1))]);
        end
    end
end

function minmaxFind(fun, terms, len)
    syms x;
    interval = unique(sort([x - terms(:,2)', 0, len]));
    allxy = [];
    % change to polynomial to find answer
    for i = 2:length(interval)
        a = eval(interval(i - 1));
        b = eval(interval(i));
        exfun = sym2poly(expand(fun, 'MaxExponent', a));
        root = unique([roots(exfun)' ...
            roots(polyder(exfun))' ...
            roots(polyder(polyder(exfun)))' a b]);
        root = root(a <= root & root <= b & imag(root) == 0);
        allxy = [allxy; root' polyval(exfun, root')];
    end
    allxy = unique(allxy, 'rows');
    alltext = {};
    for i = 1:length(allxy)
        alltext{i} = strcat(num2str(allxy(i, 1)), ...
            ',', num2str(allxy(i, 2))) ; 
    end
    text(allxy(:,1), allxy(:,2), alltext);
end