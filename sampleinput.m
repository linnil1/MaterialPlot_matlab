syms a b c x;
show = "F,y";
want = [a 0 -1; b 6 -1; -1+x 1 3];
len = 6;
bound = table({'V';'M';'y';'y'}, [len;len;0;len], [0;0;0;0]);

main(want, bound, len, show)