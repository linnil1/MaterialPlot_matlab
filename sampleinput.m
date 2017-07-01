syms a b c x;
show = "F,Fint,P,dx";
want = [a 0 -1; -10 3 -1; b 10 -1];
len = 10;
bound = table({'Fint';'dx'}, [len;len], [0;0]);
weight = [0.7 0 3 ; 0.3 3 10];

main(want, bound, len, show, weight)