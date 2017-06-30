syms a b c x;
show = "F,dy,y";
want = [a 0 -1; b 6 -1; -1 2 -2];
len = 6;
bound = table({'V';'M';'y';'y'}, [len;len;0;len], [0;0;0;0]);

main(want, bound, len, show)