syms a b c x real;
% which you want to plot
show = "F,Fint,P,dx";
% your given force to torque
want = [a 0 -1; -10 2 4; b 10 -1];
% len of your material
len = 10;
% your boundary condition
bound = table({'Fint';'dx'}, [len;len], [0;0]);
% A dx P will use weight(optional)
weight = [0.7 0 3 ; 0.3 3 10];

% call main to calculate
Y = main(want, bound, len, show, weight);
% disp(subs(Y('dx'),5));
