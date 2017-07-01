function plotPrint(symshow, configs, len)
    global namedict;
    syms x;
    for i = 1:length(symshow)
        f = symshow(i);
        fun(x) = configs(f{1});
        [terms, remain] = sumTerms(fun(x));

        % console output
        disp(namedict(f{1}));
        % ::print is not working
        % disp(fun);
        dispStep(terms, remain);

        % figure
        subplot(length(symshow), 1, i);
        fplot(fun, [0, len]);
        title(namedict(f{1}));
        ax = gca;
        ax.XAxisLocation = 'origin';
        hold on
            impulusDraw(terms);
        hold off
        minmaxFind(fun, terms, len);
    end
end

% custom display function
function dispStep(terms, remain)
    syms x;
    tx = '';
    if remain
        tx = char(remain);
    end
    terms = sortrows(terms,[2 3]);
    for t = terms'
        sf = sprintf('%s*<%s>%s', t(1), x - t(2), t(3));
        if logical(t(1) > 0)
            tx = [tx '  +' sf];
        else
            tx = [tx '  ' sf];
        end
    end
    disp(tx);
end

% draw force and torion
function impulusDraw(terms)
    for s3 = terms'
        if length(s3) ~= 3
            continue
        elseif s3(3) == -1
            stem(s3(2), s3(1));
            text(s3(2), s3(1), [char(s3(2)) ',' char(s3(1))]);
        elseif s3(3) == -2
            stem(s3(2), s3(1), 'filled');
            text(s3(2), s3(1), [char(s3(2)) ',' char(s3(1))]);
        end
    end
end

% fine min and max and text on plot
function minmaxFind(fun, terms, len)
    if isempty(terms)
        return
    end
    interval = unique(sort([terms(:,2), 0, len]));
    allxy = [];
    for i = 2:length(interval)
        a = eval(interval(i - 1));
        b = eval(interval(i));
        % change to polynomial to find answer
        exfun = sym2poly(expand(fun, 'MaxExponent', a));
        root = unique([roots(exfun)' ...
            roots(polyder(exfun))' ...
            roots(polyder(polyder(exfun)))' a b]);
        root = root(a <= root & root <= b & imag(root) == 0);
        allxy = [allxy; root' polyval(exfun, root')];
    end
    allxy = unique(allxy, 'rows');

    % format text and output
    alltext = {};
    for i = 1:length(allxy)
        alltext{i} = strcat(num2str(allxy(i, 1)), ...
            ',', num2str(allxy(i, 2))) ;
    end
    text(allxy(:,1), allxy(:,2), alltext);
end
