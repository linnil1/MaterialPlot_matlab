// Define main function
Stepfunc := proc(a, n)
begin
    if bool(is(a > 0) = UNKNOWN)
        then procname(args())
    elif bool(a < 0 or n < 0)
        then 0
    else
        a ^ n
    end_if
end_proc:
//Stepfunc(-1,2), (2*Stepfunc(2,3)), Stepfunc(4,0), Stepfunc(x-4,3)
//0, 16, 1, Stepfunc(x - 4, 3)

// extend custom function
Stepfunc := funcenv(Stepfunc):
//3 * Stepfunc(x - 4, 3)
//3*Stepfunc(x-4,3)

// Define integral
Stepfunc::diff := proc(f, x)
local n, a;
begin
    a := op(f)[1];
    n := op(f)[2];
    if n = -1
        then Stepfunc(a, n + 1)
    else
        Stepfunc(a, n + 1) / (n + 1)
    end_if
end_proc:
// Define integral bcz Mupad ::int is bug
integral := (f, x) -> diff(f, x) :
//integral(3 * Stepfunc(x - 4, -1) + 4 * Stepfunc(x - 1, 5), x)
//3*Stepfunc(x - 4, 0) + (2*Stepfunc(x - 1, 6))/3

// expand
// use MaxExponent to set as option
Stepfunc::expand := proc(f, opt = MaxExponent = 0)
local n, a;
begin
    a := op(f)[1];
    n := op(f)[2];
    where := op(opt, 2);
    if bool(n < 0) or subs(a, x = where) < 0
        then 0
    else
        expand(a ^ n)
    end_if
end_proc:

//expand(Stepfunc(x - 3 , 4), MaxExponent=3)
//x^4 - 12*x^3 + 54*x^2 - 108*x + 81

// plot
//plot(Stepfunc(x - 3, 0))

// ordered
//Stepfunc(x - 3, 4) + Stepfunc(x - 1, 1)
//Stepfunc(x - 1, 1) + Stepfunc(x - 3, 4)
