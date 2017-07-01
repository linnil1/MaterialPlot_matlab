It is a Matlab version of

[https://github.com/linnil1/1052Material_Plot](https://github.com/linnil1/1052Material_Plot)


# some messy things

* Mupad cannot custom `::int` and I use `::diff` to achieve it
* Mupad `::expand` cannot add condition and `MaxExponent` to get condition
* Mupad `::print` not work at this method
* Mupad cannot order custom function
* Matlab cannot separate terms of sum very well
* Taylor expansion has bug at first term


# input 

```
syms a b c x;
show = "F,V,M";
want = [a 0 -1; b 6 -1; -1+x 1 3];
len = 6;
bound = table({'V';'M';'y';'y'}, [len;len;0;len], [0;0;0;0]);

main(want, bound, len, show)
```

Be care for

[a 0 -1] means a*Stepfunc(x-0, -1)

if third column is greater and equal to 0

like [b(x) 0 3] means b(x) from 0 to 3
