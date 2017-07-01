It is a Matlab version of

[https://github.com/linnil1/1052Material_Plot](https://github.com/linnil1/1052Material_Plot)

# Usage

Call `sampleinput` will plot.

You can modify sampleinput.m

And document and the meaning of each arguments are written in Python version


# input

```
syms a b c x real;
show = "F,V,M";
want = [a 0 -1; b 6 -1; -1+x 1 3];
len = 6;
bound = table({'V';'M'}, [len;len], [0;0]);

Y = main(want, bound, len, show)
```

if you want you get M(x) value at x=3

just type `subs(Y('M'), 3)`

Be care for

1. matlab is CaseSensitive

2. [a 0 -1] means a*Stepfunc(x-0, -1)

3. if third column is greater and equal to 0

   like [b(x) 0 3] means b(x) from 0 to 3

   Warning b(x) should be polynomial of x

4. if there are no variable in want

   it will plot without solveing equation


## weight function

`weight` is for `P` `dx` `A`

usage [-4 1 3; 5 5 6]

Segment between [1, 3] will multiply by -4

Segment between [5, 6] will multiply by 5

and other place will multiply by 1

input number only

# demo picture
![demojpg](http://i.imgur.com/4iWPE1q.jpg)


# some messy things

* Mupad cannot custom `::int` and I use `::diff` to achieve it
* Mupad `::expand` cannot add condition and `MaxExponent` to get condition
* Mupad `::expand` cannot use float number as condition ( be aware of at bonudary)
* Mupad `::print` not work at this method
* Mupad cannot order custom function
* Matlab cannot separate terms of sum very well
* Taylor expansion has bug at first term
